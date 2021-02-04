import 'dart:convert';
import 'package:hippo/gop.dart';
import 'package:flutter/foundation.dart';
import 'package:hippo/lesson_editor.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:hippo/models.dart';
import 'package:http/http.dart';

Future<List<Lesson>> getPracticeData() async {
  List<Lesson> ret;
  final http.Response res = await http.get(
    'http://${constants.ServerInfo.serverUrl}:${constants.ServerInfo.serverPort}/lessons',
  );
  if (res.statusCode == 200) {
    List lessons = json.decode(res.body)['lessons'];
    ret = lessons.map((e) => Lesson.fromJson(e)).toList();
  } else {
    throw Exception("Failed to get a list of practices from server");
  }
  return ret;
}

Future<void> deleteLesson(int lessonId) async {
  // workaround since http.delete doesn't allow body
  var rq = Request(
    'DELETE',
    Uri.parse(
      'http://${constants.ServerInfo.serverUrl}:${constants.ServerInfo.serverPort}/lessons',
    ),
  );
  rq.body = json.encode({'lesson_id': lessonId});
  http.Client client = http.Client();
  http.StreamedResponse res = await client.send(rq);
  client.close();

  if (res.statusCode != 200) {
    throw Exception("Failed to delete lesson id=$lessonId");
  }
}

class Index extends StatefulWidget {
  Index({Key key, this.title, this.gsc}) : super(key: key);

  final String title;
  final GlobalStateController gsc;

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List<Lesson> _data = [];

  _IndexState() {
    refreshData();
  }

  Future<void> refreshData() async {
    getPracticeData().then((value) {
      setState(() {
        _data = value;
      });
    });
  }

  Widget _getPracticeList() {
    List<Dismissible> lessonList = [];

    for (var i = 0; i < _data.length; ++i) {
      var lesson = _data[i];
      List<ListTile> sentenceList = lesson.sentences
          .map((sentence) => ListTile(
                title: Text(toUnicodeString(sentence.transcript)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Gop(
                                lessonName: lesson.lessonName,
                                sentenceId: sentence.id,
                                transcript: sentence.transcript,
                              )));
                },
              ))
          .toList();

      lessonList.add(Dismissible(
          key: Key(lesson.id.toString()),
          onDismissed: (DismissDirection direction) async {
            /// swipe to delete lesson
            await deleteLesson(lesson.id);
            setState(() {
              _data.removeAt(i);
            });
            refreshData();
          },
          background: Container(color: Colors.red),
          child: ExpansionTile(
            title: Text(
              toUnicodeString('${lesson.lessonName}'),
            ),
            children: sentenceList,
          )));
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView(
        children: lessonList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(widget.title, context),
      body: _getPracticeList(),

      /// button to add new lessons by teachers
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LessonEditor()),
          );
          refreshData();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
