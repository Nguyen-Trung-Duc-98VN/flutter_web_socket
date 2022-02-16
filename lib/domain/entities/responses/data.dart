/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 16:54:24 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 16:55:07
 */
import 'package:json_annotation/json_annotation.dart';

part 'data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Data {
  Data({
    this.room = '',
  });

  String room;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
  Map<String, dynamic> toJson() => _$DataToJson(this);
}
