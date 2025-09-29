import 'package:json_annotation/json_annotation.dart';

part 'hall.g.dart';

@JsonSerializable()
class Hall {
  final int id;
  final String name;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  final int seatCount;

  const Hall({
    required this.id,
    required this.name,
    required this.isActive,
    required this.createdAt,
    required this.seatCount,
  });

  factory Hall.fromJson(Map<String, dynamic> json) => _$HallFromJson(json);
  Map<String, dynamic> toJson() => _$HallToJson(this);
}