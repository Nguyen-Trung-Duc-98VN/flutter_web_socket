// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      textroom: json['textroom'] as String? ?? '',
      transaction: json['transaction'] as String? ?? '',
      room: json['room'] as String? ?? '',
      text: json['text'] as String? ?? '',
      ack: json['ack'] as bool? ?? true,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'textroom': instance.textroom,
      'transaction': instance.transaction,
      'room': instance.room,
      'text': instance.text,
      'ack': instance.ack,
    };
