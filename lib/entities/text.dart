/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 09:38:01 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 09:41:26
 */
import 'package:json_annotation/json_annotation.dart';

part 'text.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Text {
  Text({
    this.id = '',
    this.room = '',
    this.name = '',
    this.partnerUserId = '',
    this.partnerId = 1,
    this.text = '',
    this.time = 0,
    this.isBlocked = false,
    this.event = '',
  });

  String id;
  String room;
  String name;
  String partnerUserId;
  int partnerId;
  String text;
  int time;
  bool isBlocked;
  String event;

  factory Text.fromJson(Map<String, dynamic> json) => _$TextFromJson(json);
  Map<String, dynamic> toJson() => _$TextToJson(this);
}
