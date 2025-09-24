import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super('Actor');

  @override
  Actor fromJson(dynamic json) {
    return Actor.fromJson(json);
  }
}
