import 'package:cinevibe_mobile/model/order.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }
}
