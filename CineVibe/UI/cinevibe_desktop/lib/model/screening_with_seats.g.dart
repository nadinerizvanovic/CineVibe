// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_with_seats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScreeningWithSeats _$ScreeningWithSeatsFromJson(Map<String, dynamic> json) =>
    ScreeningWithSeats(
      id: (json['id'] as num).toInt(),
      startTime: DateTime.parse(json['startTime'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String,
      movieDuration: (json['movieDuration'] as num).toInt(),
      hallId: (json['hallId'] as num).toInt(),
      hallName: json['hallName'] as String,
      screeningTypeId: (json['screeningTypeId'] as num).toInt(),
      screeningTypeName: json['screeningTypeName'] as String,
      price: (json['price'] as num).toDouble(),
      endTime: DateTime.parse(json['endTime'] as String),
      seats: (json['seats'] as List<dynamic>)
          .map((e) => SeatWithTicketInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ScreeningWithSeatsToJson(ScreeningWithSeats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startTime': instance.startTime.toIso8601String(),
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'movieDuration': instance.movieDuration,
      'hallId': instance.hallId,
      'hallName': instance.hallName,
      'screeningTypeId': instance.screeningTypeId,
      'screeningTypeName': instance.screeningTypeName,
      'price': instance.price,
      'endTime': instance.endTime.toIso8601String(),
      'seats': instance.seats,
    };

SeatWithTicketInfo _$SeatWithTicketInfoFromJson(Map<String, dynamic> json) =>
    SeatWithTicketInfo(
      id: (json['id'] as num).toInt(),
      seatNumber: json['seatNumber'] as String,
      isActive: json['isActive'] as bool,
      hallId: (json['hallId'] as num).toInt(),
      seatTypeId: (json['seatTypeId'] as num?)?.toInt(),
      seatTypeName: json['seatTypeName'] as String?,
      isOccupied: json['isOccupied'] as bool,
      ticketId: (json['ticketId'] as num?)?.toInt(),
      userFullName: json['userFullName'] as String?,
    );

Map<String, dynamic> _$SeatWithTicketInfoToJson(SeatWithTicketInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'seatNumber': instance.seatNumber,
      'isActive': instance.isActive,
      'hallId': instance.hallId,
      'seatTypeId': instance.seatTypeId,
      'seatTypeName': instance.seatTypeName,
      'isOccupied': instance.isOccupied,
      'ticketId': instance.ticketId,
      'userFullName': instance.userFullName,
    };
