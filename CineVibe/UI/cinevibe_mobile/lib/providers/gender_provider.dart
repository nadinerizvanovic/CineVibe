import 'package:cinevibe_mobile/providers/base_provider.dart';
import 'package:cinevibe_mobile/model/gender.dart';

class GenderProvider extends BaseProvider<Gender> {
  GenderProvider() : super('Gender');

  @override
  Gender fromJson(dynamic json) {
    return Gender.fromJson(json);
  }
}