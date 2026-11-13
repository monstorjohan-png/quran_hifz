import 'package:hive_flutter/hive_flutter.dart';

/// تخزين التقدم (أوفلاين)
class StorageService {
  Box get _progress => Hive.box('progress');
  Box get _settings => Hive.box('settings');
  Box get _tasmee => Hive.box('tasmee');

  // --- Progress ---
  Future<void> markAyahMemorized(int surah, int ayah) async {
    final key = '$surah:$ayah';
    await _progress.put(key, {
      'surah': surah,
      'ayah': ayah,
      'memorizedAt': DateTime.now().toIso8601String(),
      'reviews': 0,
    });
  }

  bool isMemorized(int surah, int ayah) => _progress.containsKey('$surah:$ayah');

  Map<String, dynamic> stats() {
    final total = _progress.length;
    return {'memorizedAyahs': total};
  }

  // --- Settings ---
  String get reciterId => _settings.get('reciterId', defaultValue: 'alafasy');
  set reciterId(String v) => _settings.put('reciterId', v);

  double get playbackSpeed => _settings.get('playbackSpeed', defaultValue: 1.0);
  set playbackSpeed(double v) => _settings.put('playbackSpeed', v);

  // --- Tasmee (recitation attempts) ---
  Future<void> saveTasmeeAttempt({
    required int surah,
    required int fromAyah,
    required int toAyah,
    required String transcript,
    required double accuracy,
  }) async {
    final id = '${surah}_${fromAyah}_${toAyah}_${DateTime.now().millisecondsSinceEpoch}';
    await _tasmee.put(id, {
      'surah': surah,
      'from': fromAyah,
      'to': toAyah,
      'transcript': transcript,
      'accuracy': accuracy,
      'at': DateTime.now().toIso8601String(),
    });
  }
}
