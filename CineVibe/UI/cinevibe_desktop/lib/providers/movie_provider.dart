import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinevibe_desktop/model/movie.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';
import 'package:cinevibe_desktop/model/actor.dart';
import 'package:cinevibe_desktop/model/production_company.dart';

class MovieProvider extends BaseProvider<Movie> {
  MovieProvider() : super("Movie");

  @override
  Movie fromJson(dynamic json) {
    return Movie.fromJson(json);
  }

  // Custom actions for movie management
  Future<List<Actor>> getMovieActors(int movieId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/actors";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        return data.map((json) => Actor.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("Movie not found");
      } else {
        throw Exception("Failed to fetch movie actors. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to fetch movie actors: $e");
    }
  }

  Future<bool> assignActorToMovie(int movieId, int actorId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/actors/$actorId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to assign actor to movie: $e");
    }
  }

  Future<bool> removeActorFromMovie(int movieId, int actorId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/actors/$actorId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.delete(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to remove actor from movie: $e");
    }
  }

  Future<List<ProductionCompany>> getMovieProductionCompanies(int movieId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/production-companies";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.get(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body) as List;
        return data.map((json) => ProductionCompany.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("Movie not found");
      } else {
        throw Exception("Failed to fetch movie production companies. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to fetch movie production companies: $e");
    }
  }

  Future<bool> assignProductionCompanyToMovie(int movieId, int productionCompanyId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/production-companies/$productionCompanyId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.post(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to assign production company to movie: $e");
    }
  }

  Future<bool> removeProductionCompanyFromMovie(int movieId, int productionCompanyId) async {
    var url = "${BaseProvider.baseUrl}Movie/$movieId/production-companies/$productionCompanyId";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http.delete(uri, headers: headers).timeout(
        Duration(seconds: 30),
        onTimeout: () {
          throw Exception("Request timed out. Please check your network connection.");
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to remove production company from movie: $e");
    }
  }
}
