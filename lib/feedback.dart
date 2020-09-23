import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hippo/main.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/constants.dart' as constants;
import 'package:hippo/utils.dart' as utils;

Future<void> createFeedback(
  String username,
  String token,
  String content,
  int sentenceId,
) async {
  final http.Response res = await http.post(
    'http://${constants.ServerInfo.serverUrl}:${constants.ServerInfo.serverPort}/feedback',
    body: json.encode({
      'username': username,
      'token': token,
      'content': content,
      'sentence_id': sentenceId,
    }),
  );
  if (res.statusCode != 200) throw Exception("Failed to create feedback");
}

class FeedbackPage extends StatefulWidget {
  final int sentenceId;

  FeedbackPage({Key key, @required this.sentenceId}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final GlobalStateController _gsc = Get.find();
  String _feedbackContent = '';

  @override
  Widget build(BuildContext context) {
    var feedbackInput = TextField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onChanged: (String text) {
        setState(() {
          _feedbackContent = text;
        });
      },
      decoration: new InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromARGB(255, 100, 150, 200), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide:
              BorderSide(color: Color.fromARGB(255, 100, 150, 200), width: 1.0),
        ),
      ),
    );

    return Scaffold(
      appBar: utils.buildAppBar('Feedback', context),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          children: [
            feedbackInput,
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                createFeedback(
                  _gsc.username.value,
                  _gsc.loginToken.value,
                  _feedbackContent,
                  widget.sentenceId,
                );
                debugPrint('Sent feedback: $_feedbackContent');
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
