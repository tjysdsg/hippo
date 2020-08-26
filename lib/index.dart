import 'dart:convert';
import 'package:hippo/gop.dart';
import 'package:hippo/utils.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/constants.dart' as constants;
import 'package:flutter/material.dart';

class Sentence {
  int id;
  String transcript;

  Sentence({this.id, this.transcript});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(id: json['id'], transcript: json['transcript']);
  }

  @override
  String toString() {
    return 'Sentence $id, $transcript';
  }
}

class Dialog {
  int id;
  List<Sentence> sentences;

  Dialog({this.id, this.sentences});

  factory Dialog.fromJson(Map<String, dynamic> json) {
    List sentences = json['sentences'];
    return Dialog(
        id: json['id'],
        sentences: sentences.map((e) => Sentence.fromJson(e)).toList());
  }

  @override
  String toString() {
    return 'Dialog $id, $sentences';
  }
}

class Lesson {
  int id;
  String lessonName;
  List<Dialog> dialogs;

  Lesson({this.id, this.lessonName, this.dialogs});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    List dialogs = json['dialogs'];
    return Lesson(
      id: json['id'],
      lessonName: json['lesson_name'],
      dialogs: dialogs.map((e) => Dialog.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Lesson $id, $lessonName, $dialogs';
  }
}

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
  Index({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  List<Lesson> _data = [];

  _IndexState() {
    getPracticeData().then((value) {
      _data = value;
    });
  }

  refreshData() {
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
                                )));
                  },
                ))
            .toList();

        panelChildren.add(ExpansionTile(
          title: Text(
              'Lesson ${lesson.id}, ${toUnicodeString(lesson.lessonName)}, Dialog ${dialog.id}'),
          children: childListTiles,
        ));
      }
    }

    return ListView(
      children: panelChildren,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _getPracticeList(),
    );
  }
}
