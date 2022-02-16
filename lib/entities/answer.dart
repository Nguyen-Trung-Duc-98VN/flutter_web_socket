/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-21 09:38:39 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-21 10:23:04
 */
import 'package:json_annotation/json_annotation.dart';

part 'answer.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Answer {
  Answer({
    this.type = '',
    this.sdp = '',
  });

  String type;
  String sdp;

  factory Answer.fromJson(Map<String, dynamic> json) => _$AnswerFromJson(json);
  Map<String, dynamic> toJson() => _$AnswerToJson(this);
}
