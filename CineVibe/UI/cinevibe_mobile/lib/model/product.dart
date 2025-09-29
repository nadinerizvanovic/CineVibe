import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable()
class Product {
  final int id;
  final String name;
  final double price;
  final String? picture; // Base64 encoded image
  final bool isActive;
  final DateTime createdAt;

  Product({
    this.id = 0,
    this.name = '',
    this.price = 0.0,
    this.picture,
    this.isActive = true,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
  Map<String, dynamic> toJson() => _$ProductToJson(this);
}
