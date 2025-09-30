import 'package:cinevibe_mobile/model/director.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class DirectorProvider extends BaseProvider<Director> {
  DirectorProvider() : super('Director');

  @override
  Director fromJson(dynamic json) {
    return Director.fromJson(json);
  }
}
