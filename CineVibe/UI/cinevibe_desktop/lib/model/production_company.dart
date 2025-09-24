import 'package:json_annotation/json_annotation.dart';

part 'production_company.g.dart';

@JsonSerializable()
class ProductionCompany {
  final int id;
  final String name;
  final String? description;
  final String? country;
  final bool isActive;
  final DateTime createdAt;
  final int movieCount;

  ProductionCompany({
    required this.id,
    required this.name,
    this.description,
    this.country,
    required this.isActive,
    required this.createdAt,
    required this.movieCount,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) => _$ProductionCompanyFromJson(json);

  Map<String, dynamic> toJson() => _$ProductionCompanyToJson(this);
}
