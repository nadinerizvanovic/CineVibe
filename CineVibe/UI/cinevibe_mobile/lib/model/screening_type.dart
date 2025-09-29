import 'package:json_annotation/json_annotation.dart';

part 'screening_type.g.dart';

@JsonSerializable()
class ScreeningType {
  final int id;
  final String name;
  final String? description;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final int screeningCount;

  ScreeningType({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.screeningCount,
  });

  factory ScreeningType.fromJson(Map<String, dynamic> json) => _$ScreeningTypeFromJson(json);

  Map<String, dynamic> toJson() => _$ScreeningTypeToJson(this);
}
