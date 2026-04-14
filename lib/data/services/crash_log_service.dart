import 'dart:convert';
import 'storage_service.dart';

/// Local-only crash log service that persists crash entries in Hive via
/// [StorageService]. Keeps the last [_maxEntries] entries in FIFO order.
/// No cloud upload — all data stays on device.
class CrashLogService {
  static const String _storageKey = 'crash_logs';
  static const int _maxEntries = 50;
  static const int _maxStackLines = 10;

  final StorageService _storage;

  CrashLogService({required StorageService storage}) : _storage = storage;

  /// Log an error with an optional [stackTrace]. The stack trace is truncated
  /// to the first [_maxStackLines] lines.
  Future<void> logError(dynamic error, StackTrace? stackTrace) async {
    final entries = getRecentCrashes();

    final truncatedStack = _truncateStack(stackTrace);

    entries.add({
      'timestamp': DateTime.now().toIso8601String(),
      'error': error.toString(),
      'stackTrace': truncatedStack,
    });

    // Keep only the last _maxEntries (FIFO)
    while (entries.length > _maxEntries) {
      entries.removeAt(0);
    }

    await _storage.setString(_storageKey, jsonEncode(entries));
  }

  /// Returns all stored crash entries, newest last.
  List<Map<String, String>> getRecentCrashes() {
    final raw = _storage.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Map<String, String>.from(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Remove all stored crash logs.
  Future<void> clearLogs() async {
    await _storage.remove(_storageKey);
  }

  String _truncateStack(StackTrace? stackTrace) {
    if (stackTrace == null) return '';
    final lines = stackTrace.toString().split('\n');
    final limited = lines.take(_maxStackLines).join('\n');
    return limited;
  }
}
