import 'dart:convert';
import 'package:cinevibe_desktop/model/hall.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';
import 'package:http/http.dart' as http;

class HallProvider extends BaseProvider<Hall> {
  HallProvider() : super("Hall");

  @override
  Hall fromJson(dynamic json) {
    return Hall.fromJson(json);
  }

  // Custom action to generate seats for a hall
  Future<bool> generateSeats(int hallId, int rows, int seatsPerRow) async {
    var url = "${BaseProvider.baseUrl}Hall/$hallId/generate-seats";
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var body = jsonEncode({
      "rows": rows,
      "seatsPerRow": seatsPerRow,
    });

    try {
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception("Request timed out. Please check your network connection.");
            },
          );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data['message'] == "Seats generated successfully";
      } else {
        print("Generate seats failed with status code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Exception during generate seats: $e");
      return false;
    }
  }

  // Custom action to get hall seats
  Future<List<Map<String, dynamic>>> getHallSeats(int hallId) async {
    var url = "${BaseProvider.baseUrl}Hall/$hallId/seats";
    var uri = Uri.parse(url);
    var headers = createHeaders();

    try {
      final response = await http
          .get(uri, headers: headers)
          .timeout(
            Duration(seconds: 30),
            onTimeout: () {
              throw Exception("Request timed out. Please check your network connection.");
            },
          );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print("Get hall seats failed with status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Exception during get hall seats: $e");
      return [];
    }
  }
}
