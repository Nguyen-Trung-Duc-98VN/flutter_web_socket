// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_call_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestCallData _$TestCallDataFromJson(Map<String, dynamic> json) => TestCallData(
      status: Status.fromJson(json['status'] as Map<String, dynamic>),
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TestCallDataToJson(TestCallData instance) =>
    <String, dynamic>{
      'status': instance.status,
      'data': instance.data,
    };
