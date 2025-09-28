import 'package:json_annotation/json_annotation.dart';

part 'seat.g.dart';

@JsonSerializable()
class Seat {
  final int id;
  final String seatNumber;
  final int hallId;
  final int? seatTypeId;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  final String? seatTypeName;

  const Seat({
    required this.id,
    required this.seatNumber,
    required this.hallId,
    this.seatTypeId,
    required this.isActive,
    required this.createdAt,
    this.seatTypeName,
  });

  factory Seat.fromJson(Map<String, dynamic> json) => _$SeatFromJson(json);
  Map<String, dynamic> toJson() => _$SeatToJson(this);
}
