// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestConfig _$RequestConfigFromJson(Map<String, dynamic> json) =>
    RequestConfig(
      request: json['request'] as String? ?? '',
      transaction: json['transaction'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );

Map<String, dynamic> _$RequestConfigToJson(RequestConfig instance) =>
    <String, dynamic>{
      'request': instance.request,
      'transaction': instance.transaction,
      'token': instance.token,
    };
