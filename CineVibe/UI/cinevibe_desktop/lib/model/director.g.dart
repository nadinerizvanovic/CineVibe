// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'director.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Director _$DirectorFromJson(Map<String, dynamic> json) => Director(
  id: (json['id'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  fullName: json['fullName'] as String,
  nationality: json['nationality'] as String?,
  isActive: json['isActive'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  movieCount: (json['movieCount'] as num).toInt(),
);

Map<String, dynamic> _$DirectorToJson(Director instance) => <String, dynamic>{
  'id': instance.id,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'fullName': instance.fullName,
  'nationality': instance.nationality,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'movieCount': instance.movieCount,
};
