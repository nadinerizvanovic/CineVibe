import 'package:json_annotation/json_annotation.dart';
import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/model/production_company.dart';


part 'movie.g.dart';

@JsonSerializable()
class Movie {
  final int id;
  final String title;
  @JsonKey(name: 'releaseDate')
  final DateTime releaseDate;
  final String? description;
  final int duration; // Duration in minutes
  final String? trailer; // URL to trailer
  final String? poster; // Base64 encoded poster image
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  
  // Foreign key IDs
  @JsonKey(name: 'categoryId')
  final int categoryId;
  @JsonKey(name: 'genreId')
  final int genreId;
  @JsonKey(name: 'directorId')
  final int directorId;
  
  // Navigation properties
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'genreName')
  final String? genreName;
  @JsonKey(name: 'directorName')
  final String? directorName;
  
  // Related entities
  final List<Actor>? actors;
  final List<ProductionCompany>? productionCompanies;
  
  // Counts
  @JsonKey(name: 'actorCount')
  final int? actorCount;
  @JsonKey(name: 'productionCompanyCount')
  final int? productionCompanyCount;

  Movie({
    this.id = 0,
    this.title = '',
    required this.releaseDate,
    this.description,
    this.duration = 0,
    this.trailer,
    this.poster,
    this.isActive = true,
    required this.createdAt,
    this.categoryId = 0,
    this.genreId = 0,
    this.directorId = 0,
    this.categoryName,
    this.genreName,
    this.directorName,
    this.actors,
    this.productionCompanies,
    this.actorCount,
    this.productionCompanyCount,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => _$MovieFromJson(json);
  Map<String, dynamic> toJson() => _$MovieToJson(this);
}
