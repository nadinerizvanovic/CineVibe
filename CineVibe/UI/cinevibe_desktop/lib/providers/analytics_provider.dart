import 'dart:convert';
import 'package:cinevibe_desktop/model/analytics.dart';
import 'package:cinevibe_desktop/providers/base_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalyticsProvider with ChangeNotifier {
  bool _loading = false;
  String? _errorMessage;
  Analytics? _analytics;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  Analytics? get analytics => _analytics;

  Future<Analytics?> getAnalytics() async {
    try {
      _loading = true;
      _errorMessage = null;
      notifyListeners();

      final url = Uri.parse('${BaseProvider.baseUrl}Analytics');
      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _analytics = Analytics.fromJson(data);
        _loading = false;
        notifyListeners();
        return _analytics;
      } else {
        _errorMessage = 'Failed to fetch analytics data';
        _loading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}
