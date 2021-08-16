import 'dart:convert';

import 'package:libras/shared/models/awnser_model.dart';

class QuestionModel {

  final String title;
  final List<AwnserModel> awnsears;

  QuestionModel({ this.title, this.awnsears })
      : assert (
        awnsears.length == 4
      );

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'awnsears': awnsears.map((x) => x.toMap()).toList(),
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    return QuestionModel(
      title: map['title'],
      awnsears: List<AwnserModel>.from(map['awnsears']?.map((x) => AwnserModel.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory QuestionModel.fromJson(String source) => QuestionModel.fromMap( json.decode(source) );

}