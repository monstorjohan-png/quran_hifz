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

  // --- وضع المعلم (خطة يومية) ---
  int get dailyPlan => _settings.get('dailyPlan', defaultValue: 4);
  set dailyPlan(int v) => _settings.put('dailyPlan', v);
  bool get teacherMode => _settings.get('teacherMode', defaultValue: false);
  set teacherMode(bool v) => _settings.put('teacherMode', v);
  // محفوظ اليوم (آيات اليوم)
  int get todayMemorized {
    final today = DateTime.now();
    final ds = '${today.year}-${today.month}-${today.day}';
    int n = 0;
    for (final v in _progress.values) {
      if (v is Map && (v['memorizedAt'] is String) && (v['memorizedAt'] as String).startsWith(ds)) n++;
    }
    return n;
  }

  // --- Streak ---
  int get streak => _settings.get('streak', defaultValue: 0);
  set streak(int v) => _settings.put('streak', v);
  String? get lastStreakDate => _settings.get('lastStreakDate');
  set lastStreakDate(String? v) => _settings.put('lastStreakDate', v);

  Future<void> bumpStreak() async {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    if (lastStreakDate == todayStr) return;
    final yesterday = today.subtract(const Duration(days: 1));
    final yStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
    streak = (lastStreakDate == yStr) ? streak + 1 : 1;
    lastStreakDate = todayStr;
  }

  // --- Spaced Repetition (SM-2) ---
  Map<String, dynamic>? srsRecord(int surah, int ayah) => _progress.get('$surah:$ayah')?['srs'];
  Future<void> saveSrs(int surah, int ayah, Map<String, dynamic> srs) async {
    final key = '$surah:$ayah';
    final cur = Map<String, dynamic>.from(_progress.get(key) ?? {});
    cur['srs'] = srs;
    await _progress.put(key, cur);
  }

  List<Map<String, dynamic>> dueToday() {
    final now = DateTime.now();
    final out = <Map<String, dynamic>>[];
    for (final v in _progress.values) {
      if (v is Map) {
        final srs = v['srs'];
        if (srs is Map) {
          final due = DateTime.tryParse(srs['dueDate'] ?? '');
          if (due != null && !due.isAfter(now)) {
            out.add({'surah': v['surah'], 'ayah': v['ayah']});
          }
        }
      }
    }
    return out;
  }

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
