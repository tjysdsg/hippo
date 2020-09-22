import 'package:flutter/material.dart';

class MyText extends StatefulWidget {
  final String text;
  final double fontSize;
  final Color textColor;

  MyText(
    this.text, {
    Key key,
    this.fontSize = 16,
    this.textColor = const Color.fromARGB(255, 0, 0, 0),
  }) : super(key: key);

  @override
  _MyTextState createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        fontSize: widget.fontSize,
        color: widget.textColor,
      ),
    );
  }
}
