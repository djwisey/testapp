import 'package:hive_flutter/hive_flutter.dart';

class SaveService {
  static const String _boxName = 'startup_empire_save';
  static const String _stateKey = 'game_state';

  Future<void> ensureReady() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(_boxName);
    }
  }

  Future<Map<dynamic, dynamic>?> loadState() async {
    await ensureReady();
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    final dynamic value = box.get(_stateKey);
    if (value is Map) {
      return value;
    }
    return null;
  }

  Future<void> saveState(Map<String, dynamic> state) async {
    await ensureReady();
    final Box<dynamic> box = Hive.box<dynamic>(_boxName);
    await box.put(_stateKey, state);
  }
}
