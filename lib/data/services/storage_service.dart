import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  late Box<String> _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _settingsBox = await Hive.openBox<String>('settings');
  }

  String? getString(String key) => _settingsBox.get(key);

  Future<void> setString(String key, String value) async {
    await _settingsBox.put(key, value);
  }

  Future<void> remove(String key) async {
    await _settingsBox.delete(key);
  }
}
