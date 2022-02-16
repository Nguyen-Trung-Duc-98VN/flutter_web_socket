// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'answer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Answer _$AnswerFromJson(Map<String, dynamic> json) => Answer(
      type: json['type'] as String? ?? '',
      sdp: json['sdp'] as String? ?? '',
    );

Map<String, dynamic> _$AnswerToJson(Answer instance) => <String, dynamic>{
      'type': instance.type,
      'sdp': instance.sdp,
    };
