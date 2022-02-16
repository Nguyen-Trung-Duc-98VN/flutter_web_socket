/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 09:26:43 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 10:12:41
 */
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Message {
  Message({
    this.textroom = '',
    this.transaction = '',
    this.room = '',
    this.text = '',
    this.ack = true,
  });

  String textroom;
  String transaction;
  String room;
  String text;
  bool ack;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}
