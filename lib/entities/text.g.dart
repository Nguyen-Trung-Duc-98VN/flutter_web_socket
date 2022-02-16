// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Text _$TextFromJson(Map<String, dynamic> json) => Text(
      id: json['id'] as String? ?? '',
      room: json['room'] as String? ?? '',
      name: json['name'] as String? ?? '',
      partnerUserId: json['partner_user_id'] as String? ?? '',
      partnerId: json['partner_id'] as int? ?? 1,
      text: json['text'] as String? ?? '',
      time: json['time'] as int? ?? 0,
      isBlocked: json['is_blocked'] as bool? ?? false,
      event: json['event'] as String? ?? '',
    );

Map<String, dynamic> _$TextToJson(Text instance) => <String, dynamic>{
      'id': instance.id,
      'room': instance.room,
      'name': instance.name,
      'partner_user_id': instance.partnerUserId,
      'partner_id': instance.partnerId,
      'text': instance.text,
      'time': instance.time,
      'is_blocked': instance.isBlocked,
      'event': instance.event,
    };
