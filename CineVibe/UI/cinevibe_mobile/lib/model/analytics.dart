import 'package:json_annotation/json_annotation.dart';

part 'analytics.g.dart';

@JsonSerializable()
class Analytics {
  final List<TopProduct> topProducts;
  final List<TopMovie> topMovies;
  final double ticketRevenue;
  final double productRevenue;
  final BestReviewedMovie? bestReviewedMovie;
  final TopCustomer? topCustomer;

  const Analytics({
    required this.topProducts,
    required this.topMovies,
    required this.ticketRevenue,
    required this.productRevenue,
    this.bestReviewedMovie,
    this.topCustomer,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) => _$AnalyticsFromJson(json);
  Map<String, dynamic> toJson() => _$AnalyticsToJson(this);
}

@JsonSerializable()
class TopProduct {
  final int productId;
  final String productName;
  final int totalQuantitySold;
  final double totalRevenue;

  const TopProduct({
    required this.productId,
    required this.productName,
    required this.totalQuantitySold,
    required this.totalRevenue,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) => _$TopProductFromJson(json);
  Map<String, dynamic> toJson() => _$TopProductToJson(this);
}

@JsonSerializable()
class TopMovie {
  final int movieId;
  final String movieTitle;
  final int totalTicketsSold;
  final double totalRevenue;

  const TopMovie({
    required this.movieId,
    required this.movieTitle,
    required this.totalTicketsSold,
    required this.totalRevenue,
  });

  factory TopMovie.fromJson(Map<String, dynamic> json) => _$TopMovieFromJson(json);
  Map<String, dynamic> toJson() => _$TopMovieToJson(this);
}

@JsonSerializable()
class BestReviewedMovie {
  final int movieId;
  final String movieTitle;
  final double averageRating;
  final int totalReviews;
  final String? poster;

  const BestReviewedMovie({
    required this.movieId,
    required this.movieTitle,
    required this.averageRating,
    required this.totalReviews,
    this.poster,
  });

  factory BestReviewedMovie.fromJson(Map<String, dynamic> json) => _$BestReviewedMovieFromJson(json);
  Map<String, dynamic> toJson() => _$BestReviewedMovieToJson(this);
}

@JsonSerializable()
class TopCustomer {
  final int userId;
  final String firstName;
  final String lastName;
  final String username;
  final int totalTicketsPurchased;
  final String? picture;

  const TopCustomer({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.totalTicketsPurchased,
    this.picture,
  });

  factory TopCustomer.fromJson(Map<String, dynamic> json) => _$TopCustomerFromJson(json);
  Map<String, dynamic> toJson() => _$TopCustomerToJson(this);
}
