import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ── Local Storage ──

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
  }

  // ── Location ──

  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  // ── User CRUD ──

  /// Register or update user in Supabase
  static Future<bool> upsertUser({
    required String username,
    double? latitude,
    double? longitude,
    bool? isRaining,
  }) async {
    try {
      final data = <String, dynamic>{
        'username': username,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (latitude != null) data['latitude'] = latitude;
      if (longitude != null) data['longitude'] = longitude;
      if (isRaining != null) data['is_raining'] = isRaining;

      await _client.from('rain_users').upsert(
        data,
        onConflict: 'username',
      );
      return true;
    } catch (e) {
      print('Supabase upsert error: $e');
      return false;
    }
  }

  /// Update rain status for a user
  static Future<bool> updateRainStatus(String username, bool isRaining) async {
    try {
      await _client.from('rain_users').update({
        'is_raining': isRaining,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('username', username);
      return true;
    } catch (e) {
      print('Supabase rain update error: $e');
      return false;
    }
  }

  /// Get user data by username
  static Future<Map<String, dynamic>?> getUser(String username) async {
    try {
      final response = await _client
          .from('rain_users')
          .select()
          .eq('username', username)
          .maybeSingle();
      return response;
    } catch (e) {
      print('Supabase get user error: $e');
      return null;
    }
  }

  // ── Distributed Rain Warning ──

  /// Check if any user within radius is raining
  static Future<List<Map<String, dynamic>>> getNearbyRainingUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
    String? excludeUsername,
  }) async {
    try {
      final response = await _client.rpc('nearby_users', params: {
        'user_lat': latitude,
        'user_lng': longitude,
        'radius_km': radiusKm,
        'exclude_username': excludeUsername,
      });

      if (response is List) {
        return response
            .where((u) => u['is_raining'] == true)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
      return [];
    } catch (e) {
      print('Supabase nearby query error: $e');
      return [];
    }
  }

  /// Get all nearby users (raining or not) for UI display
  static Future<List<Map<String, dynamic>>> getAllNearbyUsers({
    required double latitude,
    required double longitude,
    double radiusKm = 1.0,
    String? excludeUsername,
  }) async {
    try {
      final response = await _client.rpc('nearby_users', params: {
        'user_lat': latitude,
        'user_lng': longitude,
        'radius_km': radiusKm,
        'exclude_username': excludeUsername,
      });

      if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print('Supabase all nearby error: $e');
      return [];
    }
  }

  /// Get all users (for web demo)
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await _client
          .from('rain_users')
          .select()
          .order('updated_at', ascending: false);
      if (response is List) {
        return response.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print('Supabase get all error: $e');
      return [];
    }
  }
}
