import 'package:json_annotation/json_annotation.dart';

part 'hall.g.dart';

@JsonSerializable()
class Hall {
  final int id;
  final String name;
  final bool isActive;
  final DateTime createdAt;
  final int seatCount;

  Hall({
    this.id = 0,
    this.name = '',
    this.isActive = true,
    required this.createdAt,
    this.seatCount = 0,
  });

  factory Hall.fromJson(Map<String, dynamic> json) => _$HallFromJson(json);
  Map<String, dynamic> toJson() => _$HallToJson(this);
}
