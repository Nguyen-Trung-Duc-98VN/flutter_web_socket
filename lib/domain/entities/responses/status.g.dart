// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Status _$StatusFromJson(Map<String, dynamic> json) => Status(
      errorCode: json['error_code'] as int? ?? -1,
      alertMessage: json['alert_message'] as String? ?? '',
      errorMessage: json['error_message'] as String? ?? '',
    );

Map<String, dynamic> _$StatusToJson(Status instance) => <String, dynamic>{
      'error_code': instance.errorCode,
      'alert_message': instance.alertMessage,
      'error_message': instance.errorMessage,
    };
