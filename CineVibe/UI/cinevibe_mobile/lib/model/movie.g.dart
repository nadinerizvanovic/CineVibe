// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Movie _$MovieFromJson(Map<String, dynamic> json) => Movie(
  id: (json['id'] as num?)?.toInt() ?? 0,
  title: json['title'] as String? ?? '',
  releaseDate: DateTime.parse(json['releaseDate'] as String),
  description: json['description'] as String?,
  duration: (json['duration'] as num?)?.toInt() ?? 0,
  trailer: json['trailer'] as String?,
  poster: json['poster'] as String?,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: DateTime.parse(json['createdAt'] as String),
  categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
  genreId: (json['genreId'] as num?)?.toInt() ?? 0,
  directorId: (json['directorId'] as num?)?.toInt() ?? 0,
  categoryName: json['categoryName'] as String?,
  genreName: json['genreName'] as String?,
  directorName: json['directorName'] as String?,
  actors: (json['actors'] as List<dynamic>?)
      ?.map((e) => Actor.fromJson(e as Map<String, dynamic>))
      .toList(),
  productionCompanies: (json['productionCompanies'] as List<dynamic>?)
      ?.map((e) => ProductionCompany.fromJson(e as Map<String, dynamic>))
      .toList(),
  actorCount: (json['actorCount'] as num?)?.toInt(),
  productionCompanyCount: (json['productionCompanyCount'] as num?)?.toInt(),
);

Map<String, dynamic> _$MovieToJson(Movie instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'releaseDate': instance.releaseDate.toIso8601String(),
  'description': instance.description,
  'duration': instance.duration,
  'trailer': instance.trailer,
  'poster': instance.poster,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt.toIso8601String(),
  'categoryId': instance.categoryId,
  'genreId': instance.genreId,
  'directorId': instance.directorId,
  'categoryName': instance.categoryName,
  'genreName': instance.genreName,
  'directorName': instance.directorName,
  'actors': instance.actors,
  'productionCompanies': instance.productionCompanies,
  'actorCount': instance.actorCount,
  'productionCompanyCount': instance.productionCompanyCount,
};
