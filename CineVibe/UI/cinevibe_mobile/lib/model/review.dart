import 'package:json_annotation/json_annotation.dart';

part 'review.g.dart';

@JsonSerializable()
class Review {
  final int id;
  final int rating;
  final String? comment;
  final bool isActive;
  final DateTime createdAt;
  final int screeningId;
  final DateTime screeningStartTime;
  final String movieTitle;
  final String hallName;
  final String screeningTypeName;
  final int userId;
  final String userFullName;
  final String moviePoster;

  Review({
    this.id = 0,
    this.rating = 1,
    this.comment,
    this.isActive = true,
    required this.createdAt,
    this.screeningId = 0,
    required this.screeningStartTime,
    this.movieTitle = '',
    this.hallName = '',
    this.screeningTypeName = '',
    this.userId = 0,
    this.userFullName = '',
    this.moviePoster = '',
  });

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
  Map<String, dynamic> toJson() => _$ReviewToJson(this);
}
