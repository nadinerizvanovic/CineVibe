import 'package:cinevibe_desktop/model/order.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class OrderProvider extends BaseProvider<Order> {
  OrderProvider() : super("Order");

  @override
  Order fromJson(dynamic json) {
    return Order.fromJson(json);
  }
}
