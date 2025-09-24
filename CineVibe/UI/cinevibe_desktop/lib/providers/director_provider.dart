import 'package:cinevibe_desktop/model/director.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class DirectorProvider extends BaseProvider<Director> {
  DirectorProvider() : super('Director');

  @override
  Director fromJson(dynamic json) {
    return Director.fromJson(json);
  }
}
