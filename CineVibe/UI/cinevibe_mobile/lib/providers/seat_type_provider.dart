import 'package:cinevibe_mobile/model/seat_type.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class SeatTypeProvider extends BaseProvider<SeatType> {
  SeatTypeProvider() : super("SeatType");

  @override
  SeatType fromJson(dynamic json) {
    return SeatType.fromJson(json);
  }


}
