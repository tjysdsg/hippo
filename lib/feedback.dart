import 'package:flutter/material.dart';
import 'dart:core';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hippo/base.dart';
import 'package:hippo/main.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/utils.dart' as utils;
import 'package:oktoast/oktoast.dart';

Future<void> createFeedback(
  String url,
  String username,
  String token,
  String content,
  int sentenceId,
) async {
  final http.Response res = await http.post(
    Uri.parse('http://$url/feedback'),
    body: json.encode({
      'username': username,
      'token': token,
      'content': content,
      'sentence_id': sentenceId,
    }),
  );
  if (res.statusCode != 200) throw Exception("Failed to create feedback");
}

class FeedbackInfo {
  String content;
  String username;

  FeedbackInfo({this.content, this.username});
}

Future<List<FeedbackInfo>> getFeedback(
  String url,
  String username,
  String token,
  int sentenceId,
) async {
  var uri = Uri.http(
    url,
    '/feedback',
    {
      'sentence_id': sentenceId.toString(),
      'username': username,
      'token': token,
    },
  );
  final http.Response res = await http.get(uri);
  if (res.statusCode != 200) throw Exception("Failed to get feedback");
  List feedbacks = json.decode(res.body)['feedbacks'];
  return feedbacks
      .map((e) => FeedbackInfo(content: e['content'], username: e['username']))
      .toList();
}

class FeedbackPage extends StatefulWidget {
  final int sentenceId;

  FeedbackPage({Key key, @required this.sentenceId}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends PageState<FeedbackPage> {
  String _feedbackContent = '';

  /// always be null or empty list for student account
  var _feedbacks = <FeedbackInfo>[];

  Future<void> refreshData() async {
    getFeedback(gsc.getServerUrl(), gsc.username.value, gsc.loginToken.value,
            widget.sentenceId)
        .then((List<FeedbackInfo> feedbacks) {
      setState(() {
        _feedbacks = feedbacks;
      });
      debugPrint('Successfully retrieved all feedbacks');
    }).catchError((e, stacktrace) {
      showToast("Error encountered: $e");
    });
  }

  @override
  Widget buildPage(BuildContext context) {
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

    if (_feedbacks.isEmpty) {
      /// prevent sending http request too frequently, requires manual refresh
      refreshData();
    }

    return Scaffold(
      appBar: utils.MyAppBar(title: 'Feedback'),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: RefreshIndicator(
          onRefresh: refreshData,
          child: ListView(
            children: <Widget>[
                  Column(
                    children: [
                      feedbackInput,
                      ElevatedButton(
                        child: Text('Submit'),
                        onPressed: () async {
                          await createFeedback(
                            gsc.getServerUrl(),
                            gsc.username.value,
                            gsc.loginToken.value,
                            _feedbackContent,
                            widget.sentenceId,
                          );
                          debugPrint('Sent feedback: $_feedbackContent');
                          await refreshData();
                        },
                      ),
                    ],
                  ),
                ] +
                (_feedbacks != null
                    ? _feedbacks
                        .map((FeedbackInfo f) => Card(
                            child: MyText(utils.toUnicodeString(
                                '${f.content}\nby ${f.username}'))))
                        .toList()
                    : []),
          ),
        ),
      ),
    );
  }
}
