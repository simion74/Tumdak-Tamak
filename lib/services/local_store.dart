import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// Tiny wrapper around SharedPreferences so every "remember this" feature
/// in the app (profile, EQ values, which pad is on which side, sound
/// projects list, etc.) goes through one place instead of every page
/// touching SharedPreferences directly.
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ---------------- generic helpers ----------------
  Future<String?> getString(String key) async => (await _p).getString(key);
  Future<void> setString(String key, String value) async => (await _p).setString(key, value);
  Future<double?> getDouble(String key) async => (await _p).getDouble(key);
  Future<void> setDouble(String key, double value) async => (await _p).setDouble(key, value);
  Future<bool?> getBool(String key) async => (await _p).getBool(key);
  Future<void> setBool(String key, bool value) async => (await _p).setBool(key, value);

  // ---------------- profile ----------------
  static const _kProfileName = 'profile_name';
  static const _kProfileId = 'profile_unique_id';
  static const _kProfileAbout = 'profile_about';
  static const _kProfileInstrument = 'profile_fav_instrument';

  Future<String> ensureUniqueId() async {
    final p = await _p;
    var id = p.getString(_kProfileId);
    if (id == null || id.isEmpty) {
      id = _generateId();
      await p.setString(_kProfileId, id);
    }
    return id;
  }

  String _generateId() {
    final rnd = Random();
    final n = 100000 + rnd.nextInt(899999);
    return 'TT-$n';
  }

  Future<Map<String, String>> loadProfile() async {
    final p = await _p;
    return {
      'name': p.getString(_kProfileName) ?? '',
      'id': await ensureUniqueId(),
      'about': p.getString(_kProfileAbout) ?? '',
      'instrument': p.getString(_kProfileInstrument) ?? 'Tumdak',
    };
  }

  Future<void> saveProfile({required String name, required String about, required String instrument}) async {
    final p = await _p;
    await p.setString(_kProfileName, name);
    await p.setString(_kProfileAbout, about);
    await p.setString(_kProfileInstrument, instrument);
  }

  // ---------------- pad layout (Tumdak edit: swap left/right) ----------------
  Future<bool> getTumdakSwapped() async => (await _p).getBool('tumdak_swapped') ?? false;
  Future<void> setTumdakSwapped(bool value) async => (await _p).setBool('tumdak_swapped', value);

  // ---------------- EQ settings ----------------
  // Stored per soundId as "volume|rate|echo|reverb".
  Future<Map<String, double>> getEq(String soundId) async {
    final p = await _p;
    final raw = p.getString('eq_$soundId');
    if (raw == null) {
      return {'volume': 1.0, 'rate': 1.0, 'echo': 0.0, 'reverb': 0.0};
    }
    final parts = raw.split('|').map((e) => double.tryParse(e) ?? 0).toList();
    return {
      'volume': parts.isNotEmpty ? parts[0] : 1.0,
      'rate': parts.length > 1 ? parts[1] : 1.0,
      'echo': parts.length > 2 ? parts[2] : 0.0,
      'reverb': parts.length > 3 ? parts[3] : 0.0,
    };
  }

  Future<void> saveEq(String soundId, Map<String, double> eq) async {
    final p = await _p;
    final raw = '${eq['volume']}|${eq['rate']}|${eq['echo']}|${eq['reverb']}';
    await p.setString('eq_$soundId', raw);
  }

  // ---------------- sound projects (Settings page) ----------------
  static const _kProjects = 'sound_projects';
  static const _kActiveProject = 'active_project_id';

  Future<List<Map<String, String>>> loadProjects() async {
    final p = await _p;
    final raw = p.getString(_kProjects);
    if (raw == null) {
      // Seed with the built-in default project so the list is never empty.
      final seeded = [
        {'id': 'default', 'name': 'Default Project'},
      ];
      await p.setString(_kProjects, jsonEncode(seeded));
      await p.setString(_kActiveProject, 'default');
      return seeded;
    }
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map((e) => {'id': e['id'].toString(), 'name': e['name'].toString()}).toList();
  }

  Future<void> saveProjects(List<Map<String, String>> projects) async {
    final p = await _p;
    await p.setString(_kProjects, jsonEncode(projects));
  }

  Future<String> getActiveProjectId() async {
    final p = await _p;
    return p.getString(_kActiveProject) ?? 'default';
  }

  Future<void> setActiveProjectId(String id) async {
    final p = await _p;
    await p.setString(_kActiveProject, id);
  }

  // ---------------- general app settings ----------------
  Future<bool> getHapticEnabled() async => (await _p).getBool('haptic_enabled') ?? true;
  Future<void> setHapticEnabled(bool v) async => (await _p).setBool('haptic_enabled', v);

  // ---------------- Octapad custom pad layouts ----------------
  // Lets a user's Edit-mode changes (reordering pads, or swapping in a
  // different sound per pad) survive switching away to another patch and
  // switching back, and survive app restarts — keyed by patch id so each
  // built-in/custom patch remembers its own layout independently.
  // Stored as JSON: [{"label": "KICK", "soundId": "octapad_santali_kick"}, ...]
  Future<List<Map<String, String>>?> getPatchLayout(String patchId) async {
    final p = await _p;
    final raw = p.getString('octapad_layout_$patchId');
    if (raw == null) return null;
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((e) => {'label': e['label'].toString(), 'soundId': e['soundId'].toString()}).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> savePatchLayout(String patchId, List<Map<String, String>> pads) async {
    final p = await _p;
    await p.setString('octapad_layout_$patchId', jsonEncode(pads));
  }

  Future<void> clearPatchLayout(String patchId) async {
    final p = await _p;
    await p.remove('octapad_layout_$patchId');
  }
}
