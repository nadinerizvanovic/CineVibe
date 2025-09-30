import 'package:cinevibe_mobile/model/review.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class ReviewProvider extends BaseProvider<Review> {
  ReviewProvider() : super("Review");

  @override
  Review fromJson(dynamic json) {
    return Review.fromJson(json);
  }
}
