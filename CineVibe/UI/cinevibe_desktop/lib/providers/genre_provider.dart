import 'package:cinevibe_desktop/model/genre.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class GenreProvider extends BaseProvider<Genre> {
  GenreProvider() : super("Genre");

  @override
  Genre fromJson(dynamic json) {
    return Genre.fromJson(json);
  }
}
