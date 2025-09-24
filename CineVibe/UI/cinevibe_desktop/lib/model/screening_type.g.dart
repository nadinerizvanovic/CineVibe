// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'screening_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ScreeningType _$ScreeningTypeFromJson(Map<String, dynamic> json) =>
    ScreeningType(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      screeningCount: (json['screeningCount'] as num).toInt(),
    );

Map<String, dynamic> _$ScreeningTypeToJson(ScreeningType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'screeningCount': instance.screeningCount,
    };
