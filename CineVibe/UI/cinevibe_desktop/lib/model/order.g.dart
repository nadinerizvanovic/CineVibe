// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
  id: (json['id'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  isActive: json['isActive'] as bool,
  userId: (json['userId'] as num).toInt(),
  userFullName: json['userFullName'] as String,
  orderItems: (json['orderItems'] as List<dynamic>)
      .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalItems: (json['totalItems'] as num).toInt(),
);

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
  'id': instance.id,
  'totalAmount': instance.totalAmount,
  'createdAt': instance.createdAt.toIso8601String(),
  'isActive': instance.isActive,
  'userId': instance.userId,
  'userFullName': instance.userFullName,
  'orderItems': instance.orderItems,
  'totalItems': instance.totalItems,
};

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
  id: (json['id'] as num).toInt(),
  quantity: (json['quantity'] as num).toInt(),
  unitPrice: (json['unitPrice'] as num).toDouble(),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  orderId: (json['orderId'] as num).toInt(),
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  productPicture: json['productPicture'] as String?,
);

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
  'id': instance.id,
  'quantity': instance.quantity,
  'unitPrice': instance.unitPrice,
  'totalPrice': instance.totalPrice,
  'createdAt': instance.createdAt.toIso8601String(),
  'orderId': instance.orderId,
  'productId': instance.productId,
  'productName': instance.productName,
  'productPicture': instance.productPicture,
};
