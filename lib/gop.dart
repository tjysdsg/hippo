import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:hippo/constants.dart';
import 'package:hippo/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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

  Gop(
      {Key key,
      @required this.lessonName,
      @required this.dialogIdx,
      @required this.sentenceId})
      : super(key: key);

  @override
  _GopState createState() => _GopState();
}

class _GopState extends State<Gop> {
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  String _wavPath;
  bool _isRecording = false;

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
    // TODO: show toast
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
      // TODO: auth
      username: 'test',
      token: 'test-test-test',
      wavPath: _wavPath,
      sentenceId: widget.sentenceId,
      callback: (msg) {
        print(msg);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
          'Lesson ${widget.lessonName}, Dialog ${widget.dialogIdx + 1}',
          context),
      body: Column(
        children: [
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
