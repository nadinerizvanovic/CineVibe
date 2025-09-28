import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinevibe_desktop/model/seat.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class SeatProvider extends BaseProvider<Seat> {
  SeatProvider() : super("Seat");

  @override
  Seat fromJson(dynamic json) {
    return Seat.fromJson(json);
  }

  // Custom actions for seat management
  Future<List<Seat>> getSeatsByHall(int hallId) async {
    var url = "${BaseProvider.baseUrl}Seat/by-hall/$hallId";
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
        throw Exception("Failed to fetch seats by hall. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to fetch seats by hall: $e");
    }
  }

  Future<bool> updateSeatType(int seatId, int? seatTypeId) async {
    var url = "${BaseProvider.baseUrl}Seat/$seatId/seat-type";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({"seatTypeId": seatTypeId});

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
      throw Exception("Failed to update seat type: $e");
    }
  }

  Future<bool> updateSeatStatus(int seatId, bool isActive) async {
    var url = "${BaseProvider.baseUrl}Seat/$seatId/status";
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
      throw Exception("Failed to update seat status: $e");
    }
  }

  Future<Map<String, List<Seat>>> getSeatsGroupedByRow(int hallId) async {
    try {
      var seats = await getSeatsByHall(hallId);

      Map<String, List<Seat>> groupedSeats = {};
      for (var seat in seats) {
        String row = seat.seatNumber.substring(0, 1); // Extract row letter
        if (!groupedSeats.containsKey(row)) {
          groupedSeats[row] = [];
        }
        groupedSeats[row]!.add(seat);
      }

      // Sort each row by seat number
      groupedSeats.forEach((key, value) {
        value.sort((a, b) {
          int numA = int.parse(a.seatNumber.substring(1));
          int numB = int.parse(b.seatNumber.substring(1));
          return numA.compareTo(numB);
        });
      });

      return groupedSeats;
    } catch (e) {
      throw Exception("Failed to group seats by row: $e");
    }
  }
}
