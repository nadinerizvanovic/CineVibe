// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Seat _$SeatFromJson(Map<String, dynamic> json) => Seat(
  id: (json['id'] as num).toInt(),
  seatNumber: json['seatNumber'] as String,
  hallId: (json['hallId'] as num).toInt(),
  seatTypeId: (json['seatTypeId'] as num?)?.toInt(),
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  seatTypeName: json['seatTypeName'] as String?,
);

Map<String, dynamic> _$SeatToJson(Seat instance) => <String, dynamic>{
  'id': instance.id,
  'seatNumber': instance.seatNumber,
  'hallId': instance.hallId,
  'seatTypeId': instance.seatTypeId,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'seatTypeName': instance.seatTypeName,
};
