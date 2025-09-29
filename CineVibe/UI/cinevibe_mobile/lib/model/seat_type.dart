import 'package:json_annotation/json_annotation.dart';

part 'seat_type.g.dart';

@JsonSerializable()
class SeatType {
  final int id;
  final String name;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;

  const SeatType({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
  });

  factory SeatType.fromJson(Map<String, dynamic> json) => _$SeatTypeFromJson(json);
  Map<String, dynamic> toJson() => _$SeatTypeToJson(this);
}
