// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hall.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Hall _$HallFromJson(Map<String, dynamic> json) => Hall(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  seatCount: (json['seatCount'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$HallToJson(Hall instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'seatCount': instance.seatCount,
};
