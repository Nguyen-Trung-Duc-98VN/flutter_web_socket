/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-11 17:18:07 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-11 17:21:47
 */

import 'package:json_annotation/json_annotation.dart';

part 'request_config.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RequestConfig {
  RequestConfig({
    this.request = '',
    this.transaction = '',
    this.token = '',
  });

  String request;
  String transaction;
  String token;

  factory RequestConfig.fromJson(Map<String, dynamic> json) =>
      _$RequestConfigFromJson(json);
  Map<String, dynamic> toJson() => _$RequestConfigToJson(this);
}
