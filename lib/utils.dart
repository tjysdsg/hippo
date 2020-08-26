import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hippo/profile.dart';

Widget buildAppBar(String title, BuildContext context) {
  return AppBar(title: Text(title), actions: [
    MaterialButton(
      onPressed: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Profile()));
      },
      child: Text('Profile'),
    )
  ]);
}

String toUnicodeString(String s) {
  return utf8.decode(s.runes.toList());
}
