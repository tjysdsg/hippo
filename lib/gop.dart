import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:get/get.dart';
import 'package:hippo/base.dart';
import 'package:hippo/constants.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class TranscriptGridElementInfo {
  String c;
  String initial;
  String consonant;
  int tone;
  double initialScore;
  double consonantBaseScore;
  double consonantToneScore;

  TranscriptGridElementInfo(
      {this.c,
      this.initial,
      this.consonant,
      this.tone,
      this.initialScore,
      this.consonantBaseScore,
      this.consonantToneScore});
// String observedInitial;
// String observedConsonant;
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

class Gop extends StatefulWidget {
  final String lessonName;
  final int dialogIdx;
  final int sentenceId;

  Gop({
    Key key,
    @required this.lessonName,
    @required this.dialogIdx,
    @required this.sentenceId,
  }) : super(key: key);

  @override
  _GopState createState() => _GopState();
}

class _GopState extends State<Gop> {
  final GlobalStateController _gsc = Get.find();
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String _wavPath;
  bool _isRecording = false;
  String _transcript = '这是个测试嘻嘻';

  /// ====== configs ====== ///
  final int _maxCharsPerRow = 5;

  _GopState() {
    _recorder.openAudioSession();
  }

  @override
  void dispose() {
    if (_recorder != null) {
      _recorder.closeAudioSession();
      _recorder = null;
    }
    super.dispose();
  }

  void startRecording() async {
    if (_gsc.loginToken.toString().isEmpty) {
      showToast('Please login first');
      return;
    }

    showToast('Recording', duration: Duration(days: 1));
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
    dismissAllToast();
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
          showToast('Does not understand results returned by server');
          return;
        }
        Map res;
        try {
          res = jsonDecode(msg);
        } catch (e) {
          showToast('Cannot JSON decode results returned by server');
          return;
        }
        if (res['status'] != 0) {
          showToast(res['message']);
          print(res['message']);
          return;
        }
        print(res['data']);
      },
    );
  }

  Widget getTranscriptGridElement(TranscriptGridElementInfo info) {
    return Column(
      children: [
        Row(children: [
          MyText(info.initial.isNull ? ' ' : info.initial),
          MyText(info.consonant.isNull ? ' ' : info.consonant),
        ]),
        MyText(info.c),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> transcriptRows = [];
    List<Widget> rowElements = [];
    for (int i = 0; i < _transcript.length; ++i) {
      var ch = _transcript[i];
      if ((i + 1) % _maxCharsPerRow == 0) {
        rowElements
            .add(getTranscriptGridElement(TranscriptGridElementInfo(c: ch)));
        transcriptRows.add(Row(
          children: rowElements,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        ));
        rowElements = [];
      } else {
        rowElements
            .add(getTranscriptGridElement(TranscriptGridElementInfo(c: ch)));
      }
    }
    if (rowElements.isNotEmpty)
      transcriptRows.add(Row(
        children: rowElements,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
      ));

    var details = Column(
      children: transcriptRows,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );

    return Scaffold(
      appBar: buildAppBar(
          'Lesson ${widget.lessonName}, Dialog ${widget.dialogIdx + 1}',
          context),
      body: Column(
        children: [
          details,
          FlatButton(
            onPressed: () {
              if (_isRecording) {
                stopRecording();
                uploadAudio();
              } else {
                startRecording();
              }
            },
            child: Text('Record'),
          )
        ],
      ),
    );
  }
}
