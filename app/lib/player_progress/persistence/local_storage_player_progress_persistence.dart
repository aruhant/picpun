import 'package:shared_preferences/shared_preferences.dart';

import 'player_progress_persistence.dart';

/// An implementation of [PlayerProgressPersistence] that uses
/// `package:shared_preferences`.
class LocalStoragePlayerProgressPersistence extends PlayerProgressPersistence {
  final Future<SharedPreferences> instanceFuture =
      SharedPreferences.getInstance();

  @override
  Future<int> getHighestLevelReached() async {
    final prefs = await instanceFuture;
    return prefs.getInt('highestLevelReached') ?? 0;
  }

  @override
  Future<void> saveHighestLevelReached(int level) async {
    final prefs = await instanceFuture;
    await prefs.setInt('highestLevelReached', level);
  }

  @override
  Future<int> getCredits() async {
    final prefs = await instanceFuture;
    return prefs.getInt('credits') ?? 0;
  }

  @override
  Future<void> saveCredits(int credits) async {
    final prefs = await instanceFuture;
    await prefs.setInt('credits', credits);
  }

  @override
  Future<int> addCredits(int credits) async {
    final prefs = await instanceFuture;
    final c = prefs.getInt('credits') ?? 0;
    await prefs.setInt('credits', c);
    return c;
  }
}
