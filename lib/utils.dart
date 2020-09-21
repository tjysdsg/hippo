import 'dart:convert';
import 'dart:typed_data';
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

Future<Uint8List> raw2Wav(
  List<int> data, {
  int channels = 1,
  int sampleRate = 16000,
  int bitSize = 16,
}) async {
  int byteRate = ((16 * sampleRate * channels) / 8).round();
  var size = data.length;
  var fileSize = size + 36;

  Uint8List ret = Uint8List.fromList([
    /// "RIFF"
    82, 73, 70, 70,
    fileSize & 0xff,
    (fileSize >> 8) & 0xff,
    (fileSize >> 16) & 0xff,
    (fileSize >> 24) & 0xff,

    /// WAVE
    87, 65, 86, 69,

    /// fmt
    102, 109, 116, 32,

    /// fmt chunk size 16
    16, 0, 0, 0,

    /// type of format
    1, 0,

    /// channels
    channels, 0,

    /// sample rate
    sampleRate & 0xff,
    (sampleRate >> 8) & 0xff,
    (sampleRate >> 16) & 0xff,
    (sampleRate >> 24) & 0xff,

    /// byte rate
    byteRate & 0xff,
    (byteRate >> 8) & 0xff,
    (byteRate >> 16) & 0xff,
    (byteRate >> 24) & 0xff,

    /// uhm
    ((16 * channels) / 8).round(), 0,

    /// bit size
    bitSize, 0,

    /// "data"
    100, 97, 116, 97,
    size & 0xff,
    (size >> 8) & 0xff,
    (size >> 16) & 0xff,
    (size >> 24) & 0xff,
    ...data
  ]);
  return ret;
}
