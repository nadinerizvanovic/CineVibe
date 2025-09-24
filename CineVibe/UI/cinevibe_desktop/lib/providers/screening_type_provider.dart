import 'package:cinevibe_desktop/model/screening_type.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class ScreeningTypeProvider extends BaseProvider<ScreeningType> {
  ScreeningTypeProvider() : super('ScreeningType');

  @override
  ScreeningType fromJson(dynamic json) {
    return ScreeningType.fromJson(json);
  }
}
