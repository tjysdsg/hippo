import 'package:flutter/cupertino.dart';

class Sentence {
  int id;
  String transcript;

  Sentence({@required this.id, @required this.transcript});

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(id: json['id'], transcript: json['transcript']);
  }

  @override
  String toString() {
    return 'Sentence $id, $transcript';
  }

  Map<String, dynamic> toDict({bool includeId = true}) {
    Map<String, dynamic> ret = {'transcript': transcript};
    if (includeId) ret['id'] = id;
    return ret;
  }
}

class Dialog {
  int id;
  List<Sentence> sentences;

  Dialog({@required this.id, @required this.sentences});

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

  Map<String, dynamic> toDict({bool includeId = true}) {
    Map<String, dynamic> ret = {
      'sentences': sentences.map((e) => e.toDict(includeId: includeId)).toList()
    };
    if (includeId) ret['id'] = id;
    return ret;
  }
}

class Lesson {
  int id;
  String lessonName;
  List<Dialog> dialogs;

  Lesson(
      {@required this.id, @required this.lessonName, @required this.dialogs});

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

  Map<String, dynamic> toDict({bool includeId = true}) {
    Map<String, dynamic> ret = {
      'dialogs': dialogs.map((e) => e.toDict(includeId: includeId)).toList(),
      'lesson_name': lessonName
    };
    if (includeId) ret['id'] = id;
    return ret;
  }
}
