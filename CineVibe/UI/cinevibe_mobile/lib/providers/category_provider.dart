import 'package:cinevibe_mobile/model/category.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class CategoryProvider extends BaseProvider<Category> {
  CategoryProvider() : super('Category');

  @override
  Category fromJson(dynamic json) {
    return Category.fromJson(json);
  }
}
