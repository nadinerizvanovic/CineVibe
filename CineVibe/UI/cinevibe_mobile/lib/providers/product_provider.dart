import 'package:cinevibe_mobile/model/product.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class ProductProvider extends BaseProvider<Product> {
  ProductProvider() : super("Product");

  @override
  Product fromJson(dynamic json) {
    return Product.fromJson(json);
  }
}
