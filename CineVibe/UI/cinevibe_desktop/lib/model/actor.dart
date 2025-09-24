import 'package:json_annotation/json_annotation.dart';

part 'actor.g.dart';

@JsonSerializable()
class Actor {
  final int id;
  final String firstName;
  final String lastName;
  final String fullName;
  final bool isActive;
  final DateTime createdAt;
  final int movieCount;

  Actor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.isActive,
    required this.createdAt,
    required this.movieCount,
  });

  factory Actor.fromJson(Map<String, dynamic> json) => _$ActorFromJson(json);

  Map<String, dynamic> toJson() => _$ActorToJson(this);
}
