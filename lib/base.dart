import 'package:flutter/material.dart';

class MyText extends StatefulWidget {
  final String text;

  MyText(this.text, {Key key}) : super(key: key);

  @override
  _MyTextState createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(fontSize: 16),
    );
  }
}
