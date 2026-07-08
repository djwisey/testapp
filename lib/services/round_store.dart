import 'package:hive_flutter/hive_flutter.dart';

import '../models/golf_models.dart';

class RoundStore {
  static const String _boxName = 'golf_round_tracker';
  static const String _roundsKey = 'rounds';
  static const String _activeKey = 'active_round';
  static const String _profileKey = 'profile';

  Future<Box<dynamic>> _box() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.initFlutter();
      await Hive.openBox<dynamic>(_boxName);
    }
    return Hive.box<dynamic>(_boxName);
  }

  Future<UserProfile> loadProfile() async {
    final dynamic raw = (await _box()).get(_profileKey);
    return raw is Map ? UserProfile.fromJson(raw) : UserProfile.defaultProfile();
  }

  Future<void> saveProfile(UserProfile profile) async => (await _box()).put(_profileKey, profile.toJson());

  Future<GolfRound?> loadActiveRound() async {
    final dynamic raw = (await _box()).get(_activeKey);
    return raw is Map ? GolfRound.fromJson(raw) : null;
  }

  Future<void> saveActiveRound(GolfRound? round) async {
    final Box<dynamic> box = await _box();
    if (round == null) await box.delete(_activeKey); else await box.put(_activeKey, round.toJson());
  }

  Future<List<GolfRound>> loadCompletedRounds() async {
    final dynamic raw = (await _box()).get(_roundsKey, defaultValue: <dynamic>[]);
    return (raw as List? ?? const <dynamic>[]).whereType<Map>().map(GolfRound.fromJson).toList();
  }

  Future<void> saveCompletedRounds(List<GolfRound> rounds) async => (await _box()).put(_roundsKey, rounds.map((GolfRound r) => r.toJson()).toList());
}
