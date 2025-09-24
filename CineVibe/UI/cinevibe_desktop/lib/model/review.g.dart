// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Review _$ReviewFromJson(Map<String, dynamic> json) => Review(
  id: (json['id'] as num?)?.toInt() ?? 0,
  rating: (json['rating'] as num?)?.toInt() ?? 1,
  comment: json['comment'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  screeningId: (json['screeningId'] as num?)?.toInt() ?? 0,
  screeningStartTime: DateTime.parse(json['screeningStartTime'] as String),
  movieTitle: json['movieTitle'] as String? ?? '',
  hallName: json['hallName'] as String? ?? '',
  screeningTypeName: json['screeningTypeName'] as String? ?? '',
  userId: (json['userId'] as num?)?.toInt() ?? 0,
  userFullName: json['userFullName'] as String? ?? '',
);

Map<String, dynamic> _$ReviewToJson(Review instance) => <String, dynamic>{
  'id': instance.id,
  'rating': instance.rating,
  'comment': instance.comment,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'screeningId': instance.screeningId,
  'screeningStartTime': instance.screeningStartTime.toIso8601String(),
  'movieTitle': instance.movieTitle,
  'hallName': instance.hallName,
  'screeningTypeName': instance.screeningTypeName,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
};
