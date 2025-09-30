// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  id: (json['id'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  seatId: (json['seatId'] as num?)?.toInt() ?? 0,
  seatNumber: json['seatNumber'] as String? ?? '',
  screeningId: (json['screeningId'] as num?)?.toInt() ?? 0,
  screeningStartTime: DateTime.parse(json['screeningStartTime'] as String),
  movieTitle: json['movieTitle'] as String? ?? '',
  hallName: json['hallName'] as String? ?? '',
  screeningTypeName: json['screeningTypeName'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String? ?? '',
  moviePoster: json['moviePoster'] as String? ?? '',
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'id': instance.id,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'seatId': instance.seatId,
  'seatNumber': instance.seatNumber,
  'screeningId': instance.screeningId,
  'screeningStartTime': instance.screeningStartTime.toIso8601String(),
  'movieTitle': instance.movieTitle,
  'hallName': instance.hallName,
  'screeningTypeName': instance.screeningTypeName,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'moviePoster': instance.moviePoster,
};
