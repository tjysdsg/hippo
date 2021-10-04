import 'dart:convert';
import 'package:oktoast/oktoast.dart' as okToast;
import 'package:hippo/error_code.dart';
import 'package:hippo/gop.dart';
import 'package:flutter/foundation.dart';
import 'package:hippo/lesson_editor.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/base.dart';
import 'package:flutter/material.dart';
import 'package:hippo/models.dart';
import 'package:http/http.dart';
import 'package:oktoast/oktoast.dart';

Future<List<Lesson>> getPracticeData(String url) async {
  List<Lesson> ret;
  final http.Response res = await http.get(Uri.parse('http://$url/lessons'));
  if (res.statusCode == 200) {
    List lessons = json.decode(res.body)['lessons'];
    ret = lessons.map((e) => Lesson.fromJson(e)).toList();
  } else {
    throw Exception("Failed to get a list of practices from server");
  }
  return ret;
}

Future<ErrorCode> deleteLesson(
    String url, String username, String token, int lessonId) async {
  // workaround since http.delete doesn't allow body
  var rq = Request(
    'DELETE',
    Uri.parse('http://$url/lessons'),
  );
  rq.body = json.encode({
    'username': username,
    'token': token,
    'lesson_id': lessonId,
  });
  http.Client client = http.Client();
  http.StreamedResponse res = await client.send(rq);
  client.close();

  Map body = json.decode(await res.stream.bytesToString());
  if (res.statusCode != 200) {
    throw Exception("Failed to delete lesson id=$lessonId");
  }

  return ErrorCode(errorType: body['status'], message: body['message']);
}

class Index extends StatefulWidget {
  Index({Key key, this.title, this.gsc}) : super(key: key);

  final String title;
  final GlobalStateController gsc;

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends PageState<Index> {
  List<Lesson> _data = [];

  _IndexState() {
    refreshData();
  }

  Future<void> refreshData() async {
    getPracticeData(gsc.getServerUrl()).then((value) {
      setState(() {
        _data = value;
      });
    }).catchError((e, stacktrace) {
      showToast("Error encountered: $e");
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
                                explanation: sentence.explanation,
                              )));
                },
              ))
          .toList();

      /// swipe to delete a lesson
      lessonList.add(Dismissible(
          key: Key(lesson.id.toString()),
          confirmDismiss: (DismissDirection direction) async {
            ErrorCode ec = await deleteLesson(
              gsc.getServerUrl(),
              gsc.username.toString(),
              gsc.loginToken.toString(),
              lesson.id,
            );

            if (ec.isSuccess()) {
              return true;
            } else {
              okToast.showToast('Failed to create a lesson: ${ec.toString()}');
              return false;
            }
          },
          onDismissed: (DismissDirection direction) async {
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
  Widget buildPage(BuildContext context) {
    refreshData();
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
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
