import 'package:json_annotation/json_annotation.dart';

part 'screening_with_seats.g.dart';

@JsonSerializable()
class ScreeningWithSeats {
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
  final List<SeatWithTicketInfo> seats;

  const ScreeningWithSeats({
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
    required this.seats,
  });

  factory ScreeningWithSeats.fromJson(Map<String, dynamic> json) => _$ScreeningWithSeatsFromJson(json);
  Map<String, dynamic> toJson() => _$ScreeningWithSeatsToJson(this);
}

@JsonSerializable()
class SeatWithTicketInfo {
  final int id;
  final String seatNumber;
  final bool isActive;
  final int hallId;
  final int? seatTypeId;
  final String? seatTypeName;
  final bool isOccupied;
  final int? ticketId;
  final String? userFullName;

  const SeatWithTicketInfo({
    required this.id,
    required this.seatNumber,
    required this.isActive,
    required this.hallId,
    this.seatTypeId,
    this.seatTypeName,
    required this.isOccupied,
    this.ticketId,
    this.userFullName,
  });

  factory SeatWithTicketInfo.fromJson(Map<String, dynamic> json) => _$SeatWithTicketInfoFromJson(json);
  Map<String, dynamic> toJson() => _$SeatWithTicketInfoToJson(this);
}
