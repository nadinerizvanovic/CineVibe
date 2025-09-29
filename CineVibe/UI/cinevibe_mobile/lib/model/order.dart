import 'package:json_annotation/json_annotation.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int id;
  final double totalAmount;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  @JsonKey(name: 'isActive')
  final bool isActive;
  final int userId;
  final String userFullName;
  final List<OrderItem> orderItems;
  final int totalItems;

  const Order({
    required this.id,
    required this.totalAmount,
    required this.createdAt,
    required this.isActive,
    required this.userId,
    required this.userFullName,
    required this.orderItems,
    required this.totalItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

@JsonSerializable()
class OrderItem {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  @JsonKey(name: 'createdAt')
  final DateTime createdAt;
  final int orderId;
  final int productId;
  final String productName;
  final String? productPicture;

  const OrderItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
    required this.orderId,
    required this.productId,
    required this.productName,
    this.productPicture,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
}
