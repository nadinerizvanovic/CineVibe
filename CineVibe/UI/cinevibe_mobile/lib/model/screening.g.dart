// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Screening _$ScreeningFromJson(Map<String, dynamic> json) => Screening(
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
  occupiedSeatsCount: (json['occupiedSeatsCount'] as num).toInt(),
);

Map<String, dynamic> _$ScreeningToJson(Screening instance) => <String, dynamic>{
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
  'occupiedSeatsCount': instance.occupiedSeatsCount,
};
