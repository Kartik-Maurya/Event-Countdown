import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';

class StorageService {
  static const String _eventsKey = 'events';
  static const String _themeKey = 'isDarkMode';
  static const String _defaultReminderKey = 'defaultReminderMinutes';

  static Future<List<Event>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_eventsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      return Event.decodeList(jsonString);
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveEvents(List<Event> events) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_eventsKey, Event.encodeList(events));
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  static Future<int> getDefaultReminderMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultReminderKey) ?? 1440;
  }

  static Future<void> setDefaultReminderMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultReminderKey, minutes);
  }
}
