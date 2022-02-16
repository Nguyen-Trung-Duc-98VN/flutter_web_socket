/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 16:48:50 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 16:55:22
 */
import 'package:flutter_web_socket/domain/entities/responses/data.dart';
import 'package:flutter_web_socket/domain/entities/responses/status.dart';
import 'package:json_annotation/json_annotation.dart';

part 'test_call_data.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TestCallData {
  TestCallData({
    required this.status,
    required this.data,
  });

  Status status;
  Data data;

  factory TestCallData.fromJson(Map<String, dynamic> json) =>
      _$TestCallDataFromJson(json);
  Map<String, dynamic> toJson() => _$TestCallDataToJson(this);
}
