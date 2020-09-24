import 'dart:convert';
import 'package:hippo/gop.dart';
import 'package:hippo/lesson_editor.dart';
import 'package:hippo/main.dart';
import 'package:hippo/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:hippo/models.dart';

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
    List<ExpansionTile> panelChildren = [];

    for (var i = 0; i < _data.length; ++i) {
      var lesson = _data[i];
      for (var j = 0; j < lesson.dialogs.length; ++j) {
        var dialog = lesson.dialogs[j];
        List<ListTile> childListTiles = dialog.sentences
            .map((sentence) => ListTile(
                  title: Text(toUnicodeString(sentence.transcript)),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Gop(
                                  lessonName: lesson.lessonName,
                                  dialogIdx: j,
                                  sentenceId: sentence.id,
                                  transcript: sentence.transcript,
                                )));
                  },
                ))
            .toList();

        panelChildren.add(ExpansionTile(
          title: Text(toUnicodeString(
              'Lesson ${lesson.id}, ${toUnicodeString(lesson.lessonName)}, Dialog ${dialog.id}')),
          children: childListTiles,
        ));
      }
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView(
        children: panelChildren,
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LessonEditor()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
