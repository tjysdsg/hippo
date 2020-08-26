import 'package:flutter/material.dart';

class Gop extends StatefulWidget {
  String lessonName;
  int dialogIdx;
  int sentenceId;

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Lesson ${widget.lessonName}, Dialog ${widget.dialogIdx + 1}'),
      ),
      body: null,
    );
  }
}
