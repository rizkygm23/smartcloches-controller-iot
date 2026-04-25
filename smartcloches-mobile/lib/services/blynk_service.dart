import 'dart:convert';
import 'package:http/http.dart' as http;

class BlynkService {
  static const String _token = 't9m61xzzdWyz0ylWlrmy_aeqIBtrZt1d';
  static const String _baseUrl = 'https://blynk.cloud/external/api';

  /// Set servo position: 1 = ON (90°), 0 = OFF (0°)
  static Future<bool> setServoPosition(int position) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/update?token=$_token&V4=$position'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Set servo speed: 0-100 (mapped to step 1-10 on Arduino)
  static Future<bool> setServoSpeed(int speed) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/update?token=$_token&V5=$speed'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Get current servo status from V4
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

  /// Get current speed value from V5
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
}
