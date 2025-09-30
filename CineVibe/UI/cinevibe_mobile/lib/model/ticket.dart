import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final int id;
  final bool isActive;
  final DateTime createdAt;
  final int seatId;
  final String seatNumber;
  final int screeningId;
  final DateTime screeningStartTime;
  final String movieTitle;
  final String hallName;
  final String screeningTypeName;
  final int userId;
  final String userFullName;
  final String moviePoster;

  Ticket({
    this.id = 0,
    this.isActive = true,
    required this.createdAt,
    this.seatId = 0,
    this.seatNumber = '',
    this.screeningId = 0,
    required this.screeningStartTime,
    this.movieTitle = '',
    this.hallName = '',
    this.screeningTypeName = '',
    this.userId = 0,
    this.userFullName = '',
    this.moviePoster = '',
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
