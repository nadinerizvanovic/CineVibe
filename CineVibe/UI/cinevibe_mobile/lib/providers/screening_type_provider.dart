import 'package:cinevibe_mobile/model/screening_type.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class ScreeningTypeProvider extends BaseProvider<ScreeningType> {
  ScreeningTypeProvider() : super('ScreeningType');

  @override
  ScreeningType fromJson(dynamic json) {
    return ScreeningType.fromJson(json);
  }
}
