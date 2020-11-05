import 'dart:convert';
import 'package:hippo/main.dart';
import 'package:hippo/models.dart' as models;
import 'package:hippo/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> createLesson(
  // String username,
  // String token,
  models.Lesson lesson,
) async {
  final http.Response res = await http.post(
    'http://${constants.ServerInfo.serverUrl}:${constants.ServerInfo.serverPort}/lessons',
    body: json.encode(lesson.toDict(includeId: false)),
  );
  if (res.statusCode != 200) throw Exception("Failed to create lesson");
  var data = json.decode(res.body);
  if (data['status'] != 0)
    throw Exception("Failed to create lesson: ${data['message']}");
}

class LessonEditor extends StatefulWidget {
  LessonEditor({Key key}) : super(key: key);

  @override
  _LessonEditorState createState() => _LessonEditorState();
}

class _LessonEditorState extends State<LessonEditor> {
  final GlobalStateController _gsc = Get.find();

  String _lessonName = '';
  List<String> _sentences = [];

  // TODO: edit existing lesson
  @override
  Widget build(BuildContext context) {
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
      appBar: buildAppBar('Create lesson', context),
      body: Column(
        children: fields +
            [
              RaisedButton(
                child: Text('Create'),
                onPressed: () async {
                  var dialogs = [
                    models.Dialog(
                        id: 0,
                        sentences: _sentences
                            .map((String e) =>
                                models.Sentence(id: 0, transcript: e))
                            .toList())
                  ];
                  models.Lesson lesson = models.Lesson(
                    id: 0,
                    lessonName: _lessonName,
                    dialogs: dialogs,
                  );
                  await createLesson(lesson);
                  debugPrint('Created a new lesson');
                  Navigator.pop(context);
                },
              )
            ],
      ),
    );
  }
}
