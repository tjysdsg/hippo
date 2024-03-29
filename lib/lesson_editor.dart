import 'dart:convert';
import 'package:hippo/main.dart';
import 'package:hippo/base.dart';
import 'package:hippo/models.dart' as models;
import 'package:hippo/utils.dart';
import 'package:oktoast/oktoast.dart' as okToast;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'error_code.dart';

Future<ErrorCode> createLesson(
  String url,
  String username,
  String token,
  models.Lesson lesson,
) async {
  var payload = lesson.toDict(includeId: false);
  payload['username'] = username;
  payload['token'] = token;
  final http.Response res = await http.post(
    Uri.parse('http://$url/lessons'),
    body: json.encode(payload),
  );
  if (res.statusCode != 200) {
    throw Exception("Failed to create lesson");
  }
  Map data = json.decode(res.body);
  ErrorCode ec = ErrorCode(errorType: data['status'], message: data['message']);
  return ec;
}

class LessonEditor extends StatefulWidget {
  LessonEditor({Key key}) : super(key: key);

  @override
  _LessonEditorState createState() => _LessonEditorState();
}

class _LessonEditorState extends PageState<LessonEditor> {
  String _lessonName = '';
  List<String> _sentences = [];

  Widget buildCreateButton() {
    return ElevatedButton(
      child: Text('Create'),
      onPressed: () async {
        List sentences = _sentences
            // FIXME: creating lesson need explanation
            .map((String e) => models.Sentence(
                  id: 0,
                  transcript: e,
                  explanation: '',
                ))
            .toList();
        models.Lesson lesson = models.Lesson(
          id: 0,
          lessonName: _lessonName,
          sentences: sentences,
        );
        ErrorCode ec = await createLesson(
          gsc.getServerUrl(),
          gsc.username.toString(),
          gsc.loginToken.toString(),
          lesson,
        );
        if (ec.isSuccess()) {
          debugPrint('Created a new lesson');
          Navigator.pop(context);
        } else {
          okToast.showToast('Failed to create a lesson: ${ec.toString()}');
        }
      },
    );
  }

  // TODO: edit existing lesson
  @override
  Widget buildPage(BuildContext context) {
    List<Widget> fields = [
      /// lesson name
      TextField(
        decoration: InputDecoration(labelText: 'Lesson name'),
        onChanged: (String text) {
          setState(() {
            _lessonName = text;
          });
        },
      ),
    ];

    /// TextFields to edit or add sentences
    for (int i = 0; i <= _sentences.length; ++i) {
      fields.add(TextField(
        decoration: InputDecoration(labelText: 'Transcript'),
        onChanged: (String text) {
          /// add a new sentence
          if (i == _sentences.length) {
            setState(() {
              _sentences.add(text);
            });
          } else {
            /// modify a sentence
            setState(() {
              _sentences[i] = text;
            });
          }
        },
      ));
    }

    return Scaffold(
      appBar: MyAppBar(title: 'Create lesson'),
      body: Column(
        children: fields + [buildCreateButton()],
      ),
    );
  }
}
