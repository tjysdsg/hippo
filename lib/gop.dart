import 'dart:convert';
import 'dart:io';
import 'package:hippo/feedback.dart';
import 'package:hippo/database.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:uuid/uuid.dart';
import 'package:get/get.dart';
import 'package:hippo/base.dart';
import 'package:hippo/constants.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart' as utils;
import 'package:oktoast/oktoast.dart' as okToast;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

var uuid = Uuid();

class TranscriptGridElementInfo {
  String c;
  String initial;
  String consonant;
  int tone;
  bool initialCorr;
  bool consonantBaseCorr;
  bool consonantToneCorr;

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

Future<void> wsSendWav({
  @required String host,
  @required int port,
  @required int sentenceId,
  @required String username,
  @required String token,
  @required String wavPath,
  String extName = 'wav',
  String lang = 'zh',
  int numChannels = 1,
  int sampleRate = 16000,
  @required void callback(dynamic data),
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

Future<void> downloadStdSpeech({
  @required String host,
  @required int port,
  @required String path,
  @required String transcript,
  @required void callback(Uint8List data),
}) async {
  debugPrint('Downloading standard speech for transcript=$transcript');
  var payload = {
    'transcript': transcript,
  };
  var socket = await WebSocket.connect('ws://$host:$port/$path');
  socket.add(json.encode(payload));
  socket.listen((dynamic msg) {
    if (msg is String) {
      debugPrint(msg);
    } else {
      callback(msg as Uint8List);
    }
    socket.close();
  });
}

Future<void> playAudioFromBytes(FlutterSoundPlayer audioPlayer, Uint8List data) async {
  /// save to wav file
  String path = await getStorageDir() + '/tmp_${uuid.v4()}.wav';

  var fileContent = await utils.raw2Wav(data);
  File audioFile = File(path);
  audioFile.writeAsBytesSync(fileContent);

  /// player tts
  audioPlayer.setSubscriptionDuration(Duration(milliseconds: 10));
  await audioPlayer.startPlayer(
    fromURI: audioFile.path,
    codec: Codec.pcm16WAV,
  );
}

class Gop extends StatefulWidget {
  final String lessonName;
  final int sentenceId;
  final String transcript;
  final String explanation;

  Gop({
    Key key,
    @required this.lessonName,
    @required this.sentenceId,
    @required this.transcript,
    @required this.explanation,
  }) : super(key: key);

  @override
  _GopState createState() => _GopState();
}

class _GopState extends State<Gop> {
  final int _maxCharsPerRow = 5;

  final GlobalStateController _gsc = Get.find();

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  FlutterSoundPlayer _player = FlutterSoundPlayer();
  String _wavPath;
  bool _isRecording = false;
  var _pinyin = <String>[];
  var _correctness = <List<bool>>[];
  var _observedTone = <String>[];

  /// whether the evaluation of user recording is being calculated by server
  /// if true, the record button is disable
  bool _isCalculating = false;

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
    okToast.dismissAllToast();
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
    _wavPath = '${tempDir.path}/tmp_${uuid.v4()}.wav';
    debugPrint('Recorded audio is at $_wavPath');

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

  Future<void> stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      _isRecording = false;
    });
  }

  Future<void> uploadAudio() async {
    await wsSendWav(
      host: ServerInfo.serverUrl,
      port: ServerInfo.serverPort,
      username: _gsc.username.toString(),
      token: _gsc.loginToken.toString(),
      wavPath: _wavPath,
      sentenceId: widget.sentenceId,
      callback: (dynamic msg) {
        setState(() {
          _isCalculating = false;
        });

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
          _observedTone = List<int>.from(data[2])
              .map((int e) => Pinyin.toneNumberToString[e])
              .toList();
        });
      },
    );
    setState(() {
      _isCalculating = true;
    });
  }

  Color getPhoneColor(bool correct) {
    if (correct)
      return Color.fromARGB(255, 0, 255, 0);
    else
      return Color.fromARGB(255, 255, 0, 0);
  }

  Widget buildTranscriptGridElement(TranscriptGridElementInfo info) {
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

  /// Build a widget containing a grid showing pinyin and transcripts
  Widget buildTranscriptGrid() {
    var transcriptRows = <Widget>[];
    var rowElements = <Widget>[];
    var elements = <TranscriptGridElementInfo>[];
    bool prevElementComplete = true;
    TranscriptGridElementInfo info;
    String transcript = utils.toUnicodeString(widget.transcript);
    String explanation = utils.toUnicodeString(widget.explanation);

    // TODO: get expected pinyin from server before retrieving GOP

    /// fill in pinyin and scores for each character
    int transIdx = 0;
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

        /// skip punctuations before adding a new element
        while (Character.punctuations.contains(transcript[transIdx])) {
          elements.add(TranscriptGridElementInfo(c: transcript[transIdx]));
          ++transIdx;
        }
        info.c = transcript[transIdx++];
        elements.add(info);
        prevElementComplete = true;
      }
    }

    if (_pinyin.isEmpty) {
      elements = transcript
          .split('')
          .map((e) => TranscriptGridElementInfo(c: e))
          .toList();
    }

    /// character grid
    for (int i = 0; i < elements.length; ++i) {
      if ((i + 1) % _maxCharsPerRow == 0) {
        rowElements.add(buildTranscriptGridElement(elements[i]));
        transcriptRows.add(Row(
          children: rowElements,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
        ));
        rowElements = [];
      } else {
        rowElements.add(buildTranscriptGridElement(elements[i]));
      }
    }
    if (rowElements.isNotEmpty)
      transcriptRows.add(Row(
        children: rowElements,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
      ));

    /// explanation
    transcriptRows.add(MyText(explanation));

    // TODO: move these buttons to buildActionButtons()
    /// standard speech button
    var stdSpeechButton = ElevatedButton(
      child: Text('Hear'),
      onPressed: () async {
        await downloadStdSpeech(
          host: ServerInfo.serverUrl,
          port: ServerInfo.serverPort,
          path: "std-speech",
          transcript: transcript,
          callback: (Uint8List data) async {
            await playAudioFromBytes(_player, data);
          },
        );
      },
    );

    /// tts button
    var ttsButton = ElevatedButton(
      child: Text('Text2Speech'),
      onPressed: () async {
        /// get tts from server
        await downloadStdSpeech(
          host: ServerInfo.serverUrl,
          port: ServerInfo.serverPort,
          path: "tts",
          transcript: transcript,
          callback: (Uint8List data) async {
            await playAudioFromBytes(_player, data);
          },
        );
      },
    );

    /// feedback button
    var feedbackButton = ElevatedButton(
      child: Text('Feedback'),
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FeedbackPage(
                      sentenceId: widget.sentenceId,
                    )));
      },
    );

    /// msc button panel
    Row mscButtonPanel = Row(
      children: [
        stdSpeechButton,
        ttsButton,
        feedbackButton,
      ],
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
    transcriptRows.add(mscButtonPanel);

    /// help button
    transcriptRows.add(ElevatedButton(
      child: Text('Help'),
      onPressed: () {
        createFeedback(
          _gsc.username.toString(),
          _gsc.loginToken.toString(),
          "Need help",
          widget.sentenceId,
        );
        okToast.showToast("Help is on the way", duration: Duration(seconds: 2));
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FeedbackPage(
                      sentenceId: widget.sentenceId,
                    )));
      },
    ));

    _observedTone.removeWhere((String e) => e.isEmpty || e == ' ');
    debugPrint(_observedTone.toString());

    if (_observedTone.isNotEmpty) {
      transcriptRows.add(MyText(
        "Your tones:",
        fontSize: 20,
      ));
      transcriptRows.add(MyText(
        _observedTone.join(" "),
        fontSize: 50,
      ));
    }

    return Column(
      children: transcriptRows,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }

  /// Build a widget containing main action buttons, e.g. record, replay, ...
  Widget buildActionButtons() {
    List<Widget> btns = [
      SizedBox(
        width: 100,
        child: ElevatedButton(
          /// stop/record button
          onPressed: _isCalculating
              ? null
              : () async {
                  if (_isRecording) {
                    await stopRecording();
                    okToast.showToast('Please wait...',
                        duration: Duration(days: 1));
                    await uploadAudio();
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
              child: ElevatedButton(
                onPressed: () async {
                  okToast.dismissAllToast();
                  await stopRecording();
                },
                child: Text('Cancel'),
              )));
    }

    /// replay button
    if (_wavPath != null && _wavPath != '') {
      btns.add(SizedBox(
          width: 100,
          child: ElevatedButton(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: btns,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils.buildAppBar(
        utils.toUnicodeString('${widget.lessonName}'),
        context,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            buildTranscriptGrid(),
            buildActionButtons(),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
