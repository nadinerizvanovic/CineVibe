import 'package:json_annotation/json_annotation.dart';

part 'screening.g.dart';

@JsonSerializable()
class Screening {
  final int id;
  final DateTime startTime;
  final bool isActive;
  final DateTime createdAt;
  final int movieId;
  final String movieTitle;
  final int movieDuration;
  final int hallId;
  final String hallName;
  final int screeningTypeId;
  final String screeningTypeName;
  final double price;
  final DateTime endTime;
  final int occupiedSeatsCount;

  const Screening({
    required this.id,
    required this.startTime,
    required this.isActive,
    required this.createdAt,
    required this.movieId,
    required this.movieTitle,
    required this.movieDuration,
    required this.hallId,
    required this.hallName,
    required this.screeningTypeId,
    required this.screeningTypeName,
    required this.price,
    required this.endTime,
    required this.occupiedSeatsCount,
  });

  factory Screening.fromJson(Map<String, dynamic> json) => _$ScreeningFromJson(json);
  Map<String, dynamic> toJson() => _$ScreeningToJson(this);
}
