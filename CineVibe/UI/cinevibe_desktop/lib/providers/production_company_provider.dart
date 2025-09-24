import 'package:cinevibe_desktop/model/production_company.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class ProductionCompanyProvider extends BaseProvider<ProductionCompany> {
  ProductionCompanyProvider() : super('ProductionCompany');

  @override
  ProductionCompany fromJson(dynamic json) {
    return ProductionCompany.fromJson(json);
  }
}
