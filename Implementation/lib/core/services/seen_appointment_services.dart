// lib/core/services/seen_appointments_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class SeenAppointmentsService {
  static const String _key = 'seen_appointments';

  /// Returns all seen appointment IDs
  static Future<Set<String>> getSeenIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  /// Marks a single appointment as seen
  static Future<void> markAsSeen(String appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(appointmentId)) {
      list.add(appointmentId);
      await prefs.setStringList(_key, list);
    }
  }

  /// Check if a specific appointment has been seen
  static Future<bool> isSeen(String appointmentId) async {
    final seen = await getSeenIds();
    return seen.contains(appointmentId);
  }
}