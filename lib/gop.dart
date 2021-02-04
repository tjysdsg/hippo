import 'dart:convert';
import 'dart:io';
import 'package:hippo/feedback.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:hippo/base.dart';
import 'package:hippo/constants.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart' as utils;
import 'package:oktoast/oktoast.dart' as okToast;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptGridElementInfo {
  String c;
  String initial;
  String consonant;
  int tone;
  bool initialCorr;
  bool consonantBaseCorr;
  bool consonantToneCorr;

  // String observedInitial;
  // String observedConsonant;

  TranscriptGridElementInfo({
    this.c = ' ',
    this.initial = ' ',
    this.consonant,
    this.tone = 0,
    this.initialCorr = true,
    this.consonantBaseCorr = true,
    this.consonantToneCorr = true,
  });
}

void wsSendWav({
  String host,
  int port,
  int sentenceId,
  String username,
  String token,
  String wavPath,
  String extName = 'wav',
  String lang = 'zh',
  int numChannels = 1,
  int sampleRate = 16000,
  void callback(dynamic data),
}) async {
  debugPrint('Uploading audio using username=$username, token=$token');
  var meta = {
    'ext': extName,
    'token': token,
    'username': username,
    'lang': lang,
    'sentence_id': sentenceId,
  };
  var data = File(wavPath).readAsBytesSync();
  var socket = await WebSocket.connect('ws://$host:$port/upload');
  socket.add(json.encode(meta));
  socket.add(data);
  socket.listen((msg) {
    callback(msg);
    socket.close();
  });
}

void tts({
  String host,
  int port,
  String transcript,
  void callback(Uint8List data),
}) async {
  debugPrint('Calling tts API for transcript=$transcript');
  var payload = {
    'transcript': transcript,
  };
  var socket = await WebSocket.connect('ws://$host:$port/tts');
  socket.add(json.encode(payload));
  socket.listen((dynamic msg) {
    debugPrint('Received tts response');
    callback(msg as Uint8List);
    socket.close();
  });
}

class Gop extends StatefulWidget {
  final String lessonName;
  final int sentenceId;
  final String transcript;

  Gop({
    Key key,
    @required this.lessonName,
    @required this.sentenceId,
    @required this.transcript,
  }) : super(key: key);

  @override
  _GopState createState() => _GopState();
}

class _GopState extends State<Gop> {
  /// ====== configs ====== ///
  final int _maxCharsPerRow = 5;

  /// ===================== ///

  final GlobalStateController _gsc = Get.find();
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String _wavPath;
  bool _isRecording = false;
  var _pinyin = <String>[];
  var _correctness = <List<bool>>[];

  _GopState() {
    _recorder.openAudioSession();
    _player.openAudioSession();
  }

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder.closeAudioSession();
      _recorder = null;
    }
    if (_player != null) {
      _player.closeAudioSession();
      _player = null;
    }
    super.dispose();
  }

  void startRecording() async {
    if (_gsc.loginToken.toString().isEmpty) {
      okToast.showToast('Please login first');
      return;
    }

    okToast.showToast('Recording', duration: Duration(days: 1));
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted)
      throw RecordingPermissionException("Microphone permission not granted");

    Directory tempDir = await getTemporaryDirectory();
    _wavPath = '${tempDir.path}/tmp.wav';
    File outputFile = File(_wavPath);
    await _recorder.startRecorder(
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
        numChannels: 1,
        toFile: outputFile.path);
    setState(() {
      _isRecording = true;
    });
  }

  void stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  void uploadAudio() {
    wsSendWav(
      host: ServerInfo.serverUrl,
      port: ServerInfo.serverPort,
      username: _gsc.username.toString(),
      token: _gsc.loginToken.toString(),
      wavPath: _wavPath,
      sentenceId: widget.sentenceId,
      callback: (dynamic msg) {
        if (!(msg is String)) {
          okToast.showToast('Does not understand results returned by server');
          return;
        }
        Map res;
        try {
          res = jsonDecode(msg);
        } catch (e) {
          okToast.showToast('Cannot JSON decode results returned by server');
          return;
        }
        if (res['status'] != 0) {
          okToast.showToast(res['message']);
          print(res['message']);
          return;
        }
        List data = res['data'];
        print(data);
        okToast.dismissAllToast();
        setState(() {
          _pinyin = List<String>.from(data[0]);
          _correctness = List<List>.from(data[1])
              .map((List e) => (List<bool>.from(e)))
              .toList();
        });
      },
    );
  }

  Color getPhoneColor(bool correct) {
    if (correct)
      return Color.fromARGB(255, 0, 255, 0);
    else
      return Color.fromARGB(255, 255, 0, 0);
  }

  Widget getTranscriptGridElement(TranscriptGridElementInfo info) {
    String initial = info.initial ?? '';
    String consonant = info.consonant ?? '';
    String pinyinTone = '';
    String consonantBase = '';
    if (consonant != '') {
      int tone = Pinyin.consonant2Tone[consonant];
      int tonePos = Pinyin.consonant2TonePos[consonant];
      if (tonePos == 0) {
        pinyinTone +=
            Pinyin.toneNumberToString[tone] + ' ' * (consonant.length - 1);
      } else {
        pinyinTone +=
            ' ' * (consonant.length - 1) + Pinyin.toneNumberToString[tone];
      }
      consonantBase = Pinyin.consonant2Base[consonant];
    }

    var pinyinDisplay = Column(
      children: [
        Row(
          children: [
            /// placeholder to align with initial
            MyText(
              ' ' * initial.length,
              fontSize: 20,
            ),

            /// tone
            MyText(
              pinyinTone,
              fontSize: 20,
              textColor: getPhoneColor(info.consonantToneCorr),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),

        /// base pinyin
        Row(
          children: [
            MyText(
              info.initial ?? '',
              fontSize: 20,
              textColor: getPhoneColor(info.initialCorr),
            ),
            MyText(
              consonantBase,
              fontSize: 20,
              textColor: getPhoneColor(info.consonantBaseCorr),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ],
    );
    return Column(
      children: [
        pinyinDisplay,
        MyText(
          info.c,
          fontSize: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var transcriptRows = <Widget>[];
    var rowElements = <Widget>[];
    var elements = <TranscriptGridElementInfo>[];
    bool prevElementComplete = true;
    TranscriptGridElementInfo info;
    String transcript = utils.toUnicodeString(widget.transcript);

    /// fill in pinyin and scores for each character
    for (int i = 0; i < _pinyin.length; ++i) {
      if (prevElementComplete) info = TranscriptGridElementInfo();

      String pinyin = _pinyin[i];
      if (Pinyin.initials.contains(pinyin)) {
        info.initial = pinyin;
        info.initialCorr = _correctness[i][0];
        prevElementComplete = false;
      } else {
        info.consonant = pinyin;
        info.consonantBaseCorr = _correctness[i][0];
        info.consonantToneCorr = _correctness[i][1];
        elements.add(info);
        prevElementComplete = true;
      }
    }

    // TODO: get expected pinyin from server before retrieving GOP
    if (_pinyin.isEmpty) {
      elements =
          transcript.split('').map((e) => TranscriptGridElementInfo()).toList();
    }

    /// add to grid
    for (int i = 0; i < elements.length; ++i) {
      elements[i].c = transcript[i];
      if ((i + 1) % _maxCharsPerRow == 0) {
        rowElements.add(getTranscriptGridElement(elements[i]));
        transcriptRows.add(Row(
          children: rowElements,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
        ));
        rowElements = [];
      } else {
        rowElements.add(getTranscriptGridElement(elements[i]));
      }
    }
    if (rowElements.isNotEmpty)
      transcriptRows.add(Row(
        children: rowElements,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ));

    /// tts button
    transcriptRows.add(RaisedButton(
      child: Text('hear'),
      onPressed: () {
        /// get tts from server
        tts(
          host: ServerInfo.serverUrl,
          port: ServerInfo.serverPort,
          transcript: transcript,
          callback: (Uint8List data) async {
            /// save tts result to wav file
            debugPrint('Receiving tts audio data');
            String path =
                (await getExternalStorageDirectory()).path + '/tmp.wav';
            var fileContent = await utils.raw2Wav(data);
            File ttsFile = File(path);
            ttsFile.writeAsBytesSync(fileContent);
            debugPrint('tts results written to $path');

            /// player tts
            debugPrint('playing tts');
            _player.setSubscriptionDuration(Duration(milliseconds: 10));
            await _player.startPlayer(
              fromURI: ttsFile.path,
              codec: Codec.pcm16WAV,
              whenFinished: () {
                debugPrint('played tts');
              },
            );
          },
        );
      },
    ));

    /// feedback button
    transcriptRows.add(RaisedButton(
      child: Text('feedback?'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FeedbackPage(
                      sentenceId: widget.sentenceId,
                    )));
      },
    ));
    var details = Column(
      children: transcriptRows,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    List<Widget> btns = [
      SizedBox(
        width: 100,
        child: RaisedButton(
          /// stop/record button
          onPressed: () {
            if (_isRecording) {
              stopRecording();
              okToast.showToast('Please wait...', duration: Duration(days: 1));
              uploadAudio();
            } else {
              startRecording();
            }
          },
          child: Text(_isRecording ? 'Stop' : 'Record'),
        ),
      )
    ];

    /// cancel button
    if (_isRecording) {
      btns.insert(
          0,
          SizedBox(
              width: 100,
              child: RaisedButton(
                onPressed: () {
                  stopRecording();
                },
                child: Text('Cancel'),
              )));
    }

    /// replay button
    if (_wavPath != null && _wavPath != '') {
      btns.add(SizedBox(
          width: 100,
          child: RaisedButton(
            onPressed: () async {
              debugPrint('replaying user voice');
              _player.setSubscriptionDuration(Duration(milliseconds: 10));
              await _player.startPlayer(
                fromURI: _wavPath,
                codec: Codec.pcm16WAV,
                whenFinished: () {
                  debugPrint('replayed user voice');
                },
              );
            },
            child: Text('Replay'),
          )));
    }

    /// ==================================== ///
    return Scaffold(
      appBar: utils.buildAppBar(
        utils.toUnicodeString('${widget.lessonName}'),
        context,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            details,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: btns,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
