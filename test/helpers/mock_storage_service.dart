import 'package:jelly_buddy/data/services/storage_service.dart';

/// In-memory implementation of StorageService for testing.
/// Uses a simple Map instead of Hive.
class MockStorageService extends StorageService {
  final Map<String, String> _store = {};

  @override
  String? getString(String key) => _store[key];

  @override
  Future<void> setString(String key, String value) async {
    _store[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _store.remove(key);
  }

  /// Helper to clear all stored data between tests.
  void clear() {
    _store.clear();
  }

  /// Helper to inspect stored data in tests.
  Map<String, String> get store => Map.unmodifiable(_store);
}
