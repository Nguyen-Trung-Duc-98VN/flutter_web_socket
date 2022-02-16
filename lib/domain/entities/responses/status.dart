/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-18 16:51:44 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-18 16:52:18
 */
import 'package:json_annotation/json_annotation.dart';

part 'status.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Status {
  Status({
    this.errorCode = -1,
    this.alertMessage = '',
    this.errorMessage = '',
  });

  int errorCode;
  String alertMessage;
  String errorMessage;

  factory Status.fromJson(Map<String, dynamic> json) => _$StatusFromJson(json);
  Map<String, dynamic> toJson() => _$StatusToJson(this);
}
