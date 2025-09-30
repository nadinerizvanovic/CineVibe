import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinevibe_mobile/model/hall.dart';
import 'package:cinevibe_mobile/model/seat.dart';
import 'package:cinevibe_mobile/providers/base_provider.dart';

class HallProvider extends BaseProvider<Hall> {
  HallProvider() : super("Hall");

  @override
  Hall fromJson(dynamic json) {
    return Hall.fromJson(json);
  }

  // Custom actions for hall management
  Future<List<Seat>> getHallSeats(int hallId) async {
    var url = "${BaseProvider.baseUrl}Hall/$hallId/seats";
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
        return data.map((json) => Seat.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception("Hall not found");
      } else {
        throw Exception("Failed to fetch hall seats. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to fetch hall seats: $e");
    }
  }

  Future<bool> generateSeatsForHall(int hallId, int rows, int seatsPerRow) async {
    var url = "${BaseProvider.baseUrl}Hall/$hallId/generate-seats";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({
      "rows": rows,
      "seatsPerRow": seatsPerRow,
    });

    try {
      final response = await http.post(uri, headers: headers, body: body).timeout(
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
      throw Exception("Failed to generate seats for hall: $e");
    }
  }

  Future<bool> updateHallStatus(int hallId, bool isActive) async {
    var url = "${BaseProvider.baseUrl}Hall/$hallId/status";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({"isActive": isActive});

    try {
      final response = await http.put(uri, headers: headers, body: body).timeout(
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
      throw Exception("Failed to update hall status: $e");
    }
  }
}
