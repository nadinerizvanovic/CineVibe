import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cinevibe_desktop/model/screening.dart';
import 'package:cinevibe_desktop/model/screening_with_seats.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';

class ScreeningProvider extends BaseProvider<Screening> {
  ScreeningProvider() : super("Screening");

  @override
  Screening fromJson(dynamic json) {
    return Screening.fromJson(json);
  }

  // Custom actions for screening management
  Future<ScreeningWithSeats?> getScreeningWithSeats(int screeningId) async {
    var url = "${BaseProvider.baseUrl}Screening/$screeningId/seats";
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
        var data = jsonDecode(response.body);
        return ScreeningWithSeats.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception("Screening not found");
      } else {
        throw Exception("Failed to fetch screening with seats. Status: ${response.statusCode}");
      }
    } catch (e) {
      if (e.toString().contains("SocketException") ||
          e.toString().contains("Connection refused")) {
        throw Exception(
          "Cannot connect to server. Please check:\n1. Your computer's IP address\n2. The server is running\n3. Both devices are on the same network",
        );
      }
      throw Exception("Failed to fetch screening with seats: $e");
    }
  }
}
