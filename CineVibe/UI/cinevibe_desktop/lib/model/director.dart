import 'package:json_annotation/json_annotation.dart';

part 'director.g.dart';

@JsonSerializable()
class Director {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String? nationality;
  final bool isActive;
  final DateTime createdAt;
  final int movieCount;

  Director({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.nationality,
    required this.isActive,
    required this.createdAt,
    required this.movieCount,
  });

  factory Director.fromJson(Map<String, dynamic> json) => _$DirectorFromJson(json);

  Map<String, dynamic> toJson() => _$DirectorToJson(this);
}
