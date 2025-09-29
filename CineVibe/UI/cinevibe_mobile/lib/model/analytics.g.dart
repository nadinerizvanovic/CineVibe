// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Analytics _$AnalyticsFromJson(Map<String, dynamic> json) => Analytics(
  topProducts: (json['topProducts'] as List<dynamic>)
      .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
      .toList(),
  topMovies: (json['topMovies'] as List<dynamic>)
      .map((e) => TopMovie.fromJson(e as Map<String, dynamic>))
      .toList(),
  ticketRevenue: (json['ticketRevenue'] as num).toDouble(),
  productRevenue: (json['productRevenue'] as num).toDouble(),
  bestReviewedMovie: json['bestReviewedMovie'] == null
      ? null
      : BestReviewedMovie.fromJson(
          json['bestReviewedMovie'] as Map<String, dynamic>,
        ),
  topCustomer: json['topCustomer'] == null
      ? null
      : TopCustomer.fromJson(json['topCustomer'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AnalyticsToJson(Analytics instance) => <String, dynamic>{
  'topProducts': instance.topProducts,
  'topMovies': instance.topMovies,
  'ticketRevenue': instance.ticketRevenue,
  'productRevenue': instance.productRevenue,
  'bestReviewedMovie': instance.bestReviewedMovie,
  'topCustomer': instance.topCustomer,
};

TopProduct _$TopProductFromJson(Map<String, dynamic> json) => TopProduct(
  productId: (json['productId'] as num).toInt(),
  productName: json['productName'] as String,
  totalQuantitySold: (json['totalQuantitySold'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopProductToJson(TopProduct instance) =>
    <String, dynamic>{
      'productId': instance.productId,
      'productName': instance.productName,
      'totalQuantitySold': instance.totalQuantitySold,
      'totalRevenue': instance.totalRevenue,
    };

TopMovie _$TopMovieFromJson(Map<String, dynamic> json) => TopMovie(
  movieId: (json['movieId'] as num).toInt(),
  movieTitle: json['movieTitle'] as String,
  totalTicketsSold: (json['totalTicketsSold'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
);

Map<String, dynamic> _$TopMovieToJson(TopMovie instance) => <String, dynamic>{
  'movieId': instance.movieId,
  'movieTitle': instance.movieTitle,
  'totalTicketsSold': instance.totalTicketsSold,
  'totalRevenue': instance.totalRevenue,
};

BestReviewedMovie _$BestReviewedMovieFromJson(Map<String, dynamic> json) =>
    BestReviewedMovie(
      movieId: (json['movieId'] as num).toInt(),
      movieTitle: json['movieTitle'] as String,
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      poster: json['poster'] as String?,
    );

Map<String, dynamic> _$BestReviewedMovieToJson(BestReviewedMovie instance) =>
    <String, dynamic>{
      'movieId': instance.movieId,
      'movieTitle': instance.movieTitle,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'poster': instance.poster,
    };

TopCustomer _$TopCustomerFromJson(Map<String, dynamic> json) => TopCustomer(
  userId: (json['userId'] as num).toInt(),
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  username: json['username'] as String,
  totalTicketsPurchased: (json['totalTicketsPurchased'] as num).toInt(),
  picture: json['picture'] as String?,
);

Map<String, dynamic> _$TopCustomerToJson(TopCustomer instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'totalTicketsPurchased': instance.totalTicketsPurchased,
      'picture': instance.picture,
    };
