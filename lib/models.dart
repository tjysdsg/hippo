import 'package:flutter/cupertino.dart';

class Sentence {
  int id;
  String transcript;
  String explanation;

  Sentence({
    @required this.id,
    @required this.transcript,
    @required this.explanation,
  });

  factory Sentence.fromJson(Map<String, dynamic> json) {
    return Sentence(
      id: json['id'],
      transcript: json['transcript'],
      explanation: json['explanation'],
    );
  }

  @override
  String toString() {
    return 'Sentence $id, $transcript, $explanation';
  }

  Map<String, dynamic> toDict({bool includeId = true}) {
    Map<String, dynamic> ret = {
      'transcript': transcript,
      'explanation': explanation,
    };
    if (includeId) ret['id'] = id;
    return ret;
  }
}

class Lesson {
  int id;
  String lessonName;
  List<Sentence> sentences;

  Lesson(
      {@required this.id, @required this.lessonName, @required this.sentences});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    List sentences = json['sentences'];
    return Lesson(
      id: json['id'],
      lessonName: json['lesson_name'],
      sentences: sentences.map((e) => Sentence.fromJson(e)).toList(),
    );
  }

  @override
  String toString() {
    return 'Lesson $id, $lessonName, $sentences';
  }

  Map<String, dynamic> toDict({bool includeId = true}) {
    Map<String, dynamic> ret = {
      'sentences':
          sentences.map((e) => e.toDict(includeId: includeId)).toList(),
      'lesson_name': lessonName
    };
    if (includeId) ret['id'] = id;
    return ret;
  }
}
