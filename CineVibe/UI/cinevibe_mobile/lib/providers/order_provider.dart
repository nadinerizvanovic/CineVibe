import 'dart:convert';
import 'package:cinevibe_mobile/model/order.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }

  /// Create order from user's cart
  Future<Order> createOrderFromCart(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId/create-from-cart";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.post(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      return fromJson(data);
    } else {
      throw Exception("Failed to create order from cart");
    }
  }

  /// Get orders by user ID
  Future<List<Order>> getOrdersByUser(int userId) async {
    var url = "${BaseProvider.baseUrl}$endpoint/user/$userId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    var response = await http.get(uri, headers: headers);
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body) as List;
      return data.map((json) => fromJson(json)).toList();
    } else {
      throw Exception("Failed to get orders");
    }
  }
}
