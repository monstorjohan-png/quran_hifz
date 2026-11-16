import 'package:hive_flutter/hive_flutter.dart';

/// تخزين التقدم — مقاومة لأي خطأ (التطبيق يعمل حتى لو فشل التخزين)
class StorageService {
  Box? _progressBox;
  Box? _settingsBox;
  Box? _tasmeeBox;

  Box? _box(String name) {
    try {
      if (Hive.isBoxOpen(name)) return Hive.box(name);
      return null;
    } catch (_) {
      return null;
    }
  }

  Box? get _progress => _box('progress');
  Box? get _settings => _box('settings');
  Box? get _tasmee => _box('tasmee');

  // --- Progress ---
  Future<void> markAyahMemorized(int surah, int ayah) async {
    try {
      await _progress?.put('$surah:$ayah', {
        'surah': surah,
        'ayah': ayah,
        'memorizedAt': DateTime.now().toIso8601String(),
        'reviews': 0,
      });
    } catch (_) {}
  }

  bool isMemorized(int surah, int ayah) {
    try {
      return _progress?.containsKey('$surah:$ayah') ?? false;
    } catch (_) {
      return false;
    }
  }

  Map<String, dynamic> stats() {
    try {
      return {'memorizedAyahs': _progress?.length ?? 0};
    } catch (_) {
      return {'memorizedAyahs': 0};
    }
  }

  // --- Settings ---
  String get reciterId {
    try {
      return _settings?.get('reciterId', defaultValue: 'alafasy') ?? 'alafasy';
    } catch (_) {
      return 'alafasy';
    }
  }
  set reciterId(String v) { try { _settings?.put('reciterId', v); } catch (_) {} }

  double get playbackSpeed {
    try {
      return _settings?.get('playbackSpeed', defaultValue: 1.0) ?? 1.0;
    } catch (_) {
      return 1.0;
    }
  }
  set playbackSpeed(double v) { try { _settings?.put('playbackSpeed', v); } catch (_) {} }

  // --- وضع المعلم (خطة يومية) ---
  int get dailyPlan {
    try {
      return _settings?.get('dailyPlan', defaultValue: 4) ?? 4;
    } catch (_) {
      return 4;
    }
  }
  set dailyPlan(int v) { try { _settings?.put('dailyPlan', v); } catch (_) {} }
  bool get teacherMode => false;
  set teacherMode(bool v) {}

  int get todayMemorized {
    try {
      final today = DateTime.now();
      final ds = '${today.year}-${today.month}-${today.day}';
      int n = 0;
      for (final v in (_progress?.values ?? const [])) {
        if (v is Map && (v['memorizedAt'] is String) && (v['memorizedAt'] as String).startsWith(ds)) n++;
      }
      return n;
    } catch (_) {
      return 0;
    }
  }

  // --- Streak ---
  int get streak {
    try {
      return _settings?.get('streak', defaultValue: 0) ?? 0;
    } catch (_) {
      return 0;
    }
  }
  set streak(int v) { try { _settings?.put('streak', v); } catch (_) {} }
  String? get lastStreakDate {
    try {
      return _settings?.get('lastStreakDate');
    } catch (_) {
      return null;
    }
  }
  set lastStreakDate(String? v) { try { _settings?.put('lastStreakDate', v); } catch (_) {} }

  Future<void> bumpStreak() async {
    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month}-${today.day}';
      if (lastStreakDate == todayStr) return;
      final yesterday = today.subtract(const Duration(days: 1));
      final yStr = '${yesterday.year}-${yesterday.month}-${yesterday.day}';
      streak = (lastStreakDate == yStr) ? streak + 1 : 1;
      lastStreakDate = todayStr;
    } catch (_) {}
  }

  // --- Spaced Repetition (SM-2) ---
  Map<String, dynamic>? srsRecord(int surah, int ayah) {
    try {
      final v = _progress?.get('$surah:$ayah');
      if (v is Map) return Map<String, dynamic>.from(v['srs'] ?? {});
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSrs(int surah, int ayah, Map<String, dynamic> srs) async {
    try {
      final key = '$surah:$ayah';
      final cur = Map<String, dynamic>.from(_progress?.get(key) ?? {});
      cur['srs'] = srs;
      await _progress?.put(key, cur);
    } catch (_) {}
  }

  List<Map<String, dynamic>> dueToday() {
    try {
      final now = DateTime.now();
      final out = <Map<String, dynamic>>[];
      for (final v in (_progress?.values ?? const [])) {
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
    } catch (_) {
      return [];
    }
  }

  // --- Tasmee (recitation attempts) ---
  Future<void> saveTasmeeAttempt({
    required int surah,
    required int fromAyah,
    required int toAyah,
    required String transcript,
    required double accuracy,
  }) async {
    try {
      final id = '${surah}_${fromAyah}_${toAyah}_${DateTime.now().millisecondsSinceEpoch}';
      await _tasmee?.put(id, {
        'surah': surah,
        'from': fromAyah,
        'to': toAyah,
        'transcript': transcript,
        'accuracy': accuracy,
        'at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}
