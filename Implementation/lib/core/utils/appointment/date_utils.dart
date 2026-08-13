import 'package:intl/intl.dart';

class AppDateUtils {
  // Generates a list of the next 30 days starting from Today
  static List<DateTime> getNext30Days() {
    final now = DateTime.now();
    return List.generate(30, (index) => now.add(Duration(days: index)));
  }

  // Generates 24 hourly slots (e.g., "09:00 AM", "10:00 AM")
  static List<String> get24HourSlots() {
    // You can start from a specific time or just list all 24 hours
    return List.generate(24, (index) {
      final DateTime time = DateTime(2024, 1, 1, index, 0); // Date doesn't matter, only time
      return DateFormat('h:00 a').format(time); // Formats as "9:00 AM"
    });
  }
}