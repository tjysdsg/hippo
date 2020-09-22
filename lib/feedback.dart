import 'package:flutter/material.dart';
import 'package:hippo/utils.dart' as utils;

class FeedbackPage extends StatefulWidget {
  final int sentenceId;

  FeedbackPage({Key key, @required this.sentenceId}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  @override
  Widget build(BuildContext context) {
    var feedbackInput = TextField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
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
                // TODO: send feedback to server
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
    );
  }
}
