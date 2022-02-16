/*
 * @Author: NguyenTrungDuc 
 * @Date: 2022-01-19 09:37:17 
 * @Last Modified by: NguyenTrungDuc
 * @Last Modified time: 2022-01-19 09:37:40
 */
import 'package:json_annotation/json_annotation.dart';

part 'plugin_handle.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PluginHandle {
  PluginHandle();

  factory PluginHandle.fromJson(Map<String, dynamic> json) =>
      _$PluginHandleFromJson(json);
  Map<String, dynamic> toJson() => _$PluginHandleToJson(this);
}
