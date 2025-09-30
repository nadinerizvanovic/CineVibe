import 'package:cinevibe_mobile/model/actor.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class ActorProvider extends BaseProvider<Actor> {
  ActorProvider() : super('Actor');

  @override
  Actor fromJson(dynamic json) {
    return Actor.fromJson(json);
  }
}
