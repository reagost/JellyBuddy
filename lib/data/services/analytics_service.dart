import 'dart:convert';
import 'storage_service.dart';

/// Local-only analytics service. Tracks basic usage counters on-device
/// via [StorageService]. No data leaves the device.
class AnalyticsService {
  static const String _storageKey = 'analytics_data';

  /// Recognised event names mapped to their counter keys.
  static const Map<String, String> _eventKeys = {
    'app_open': 'app_opens',
    'lesson_started': 'lessons_started',
    'lesson_completed': 'lessons_completed',
    'ai_query': 'ai_queries',
  };

  final StorageService _storage;

  AnalyticsService({required StorageService storage}) : _storage = storage;

  /// Increment the counter for [eventName] and update [last_active_date].
  Future<void> trackEvent(String eventName) async {
    final data = _readData();

    final counterKey = _eventKeys[eventName] ?? eventName;
    final current = data[counterKey] ?? 0;
    data[counterKey] = current + 1;

    // Always update last active date
    data['last_active_date'] = DateTime.now().toIso8601String();

    await _storage.setString(_storageKey, jsonEncode(data));
  }

  /// Returns the current analytics snapshot as a map.
  Map<String, dynamic> getAnalytics() => _readData();

  /// Returns the count for a specific event.
  int getCount(String eventName) {
    final counterKey = _eventKeys[eventName] ?? eventName;
    final data = _readData();
    return (data[counterKey] as int?) ?? 0;
  }

  Map<String, dynamic> _readData() {
    final raw = _storage.getString(_storageKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return {};
    }
  }
}
