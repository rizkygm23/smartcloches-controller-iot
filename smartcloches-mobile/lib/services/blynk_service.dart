import 'dart:convert';
import 'package:http/http.dart' as http;

class BlynkService {
  static const String _baseUrl = 'https://blynk.cloud/external/api';
  static const String _token = 't9m61xzzdWyz0ylWlrmy_aeqIBtrZt1d';

  /// Set servo position (0 or 1) on V4
  static Future<bool> setServoPosition(int value) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/update?token=$_token&V4=$value'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Set servo speed (1-10 mapped from 0-100) on V5
  static Future<bool> setServoSpeed(int value) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/update?token=$_token&V5=$value'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get current servo position from V4
  static Future<int?> getServoStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get?token=$_token&V4'),
      );
      if (response.statusCode == 200) {
        final body = response.body.replaceAll(RegExp(r'[\[\]"]'), '');
        return int.tryParse(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current servo speed from V5
  static Future<int?> getServoSpeed() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get?token=$_token&V5'),
      );
      if (response.statusCode == 200) {
        final body = response.body.replaceAll(RegExp(r'[\[\]"]'), '');
        return int.tryParse(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current temperature from V6
  static Future<double?> getTemperature() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get?token=$_token&V6'),
      );
      if (response.statusCode == 200) {
        final body = response.body.replaceAll(RegExp(r'[\[\]"]'), '');
        return double.tryParse(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current humidity from V7
  static Future<double?> getHumidity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get?token=$_token&V7'),
      );
      if (response.statusCode == 200) {
        final body = response.body.replaceAll(RegExp(r'[\[\]"]'), '');
        return double.tryParse(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get current rain status from V8
  static Future<int?> getRainStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/get?token=$_token&V8'),
      );
      if (response.statusCode == 200) {
        final body = response.body.replaceAll(RegExp(r'[\[\]"]'), '');
        return int.tryParse(body);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get history data for a virtual pin
  /// [pin] - This should be the DATASTREAM ID (numeric) from Blynk Console
  /// [period] - "1h", "6h", "1d", "1w"
  static Future<List<Map<String, dynamic>>> getHistory(int pin, {String period = '1h'}) async {
    final url = '$_baseUrl/data/get?token=$_token&period=$period&dataStreamId=$pin&format=json';
    try {
      print('Blynk API Request: $url');
      final response = await http.get(Uri.parse(url));
      print('Blynk API Status: ${response.statusCode}');
      print('Blynk API Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          return decoded.map((e) {
            if (e is List && e.length >= 2) {
              return {
                'timestamp': e[0] is int ? e[0] : int.tryParse(e[0].toString()) ?? 0,
                'value': e[1] is num ? e[1].toDouble() : double.tryParse(e[1].toString()) ?? 0.0,
              };
            }
            return {'timestamp': 0, 'value': 0.0};
          }).where((e) => e['timestamp'] != 0).toList();
        }
      }
      return [];
    } catch (e) {
      print('Blynk History Error: $e');
      return [];
    }
  }
}
