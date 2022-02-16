/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 16:33:06 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 16:35:23
 */
import 'package:json_annotation/json_annotation.dart';

part 'room_call_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RoomCallData {
  RoomCallData({
    this.room = '',
  });

  String room;

  factory RoomCallData.fromJson(Map<String, dynamic> json) =>
      _$RoomCallDataFromJson(json);
  Map<String, dynamic> toJson() => _$RoomCallDataToJson(this);
}
