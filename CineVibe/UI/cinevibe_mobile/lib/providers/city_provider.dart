import 'package:cinevibe_mobile/providers/base_provider.dart';
import 'package:cinevibe_mobile/model/city.dart';

class CityProvider extends BaseProvider<City> {
  CityProvider() : super("City");

  @override
  City fromJson(dynamic json) {
    return City.fromJson(json);
  }
}