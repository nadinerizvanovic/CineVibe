import 'package:cinevibe_mobile/model/production_company.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class ProductionCompanyProvider extends BaseProvider<ProductionCompany> {
  ProductionCompanyProvider() : super('ProductionCompany');

  @override
  ProductionCompany fromJson(dynamic json) {
    return ProductionCompany.fromJson(json);
  }
}
