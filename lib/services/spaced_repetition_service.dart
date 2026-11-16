/// خوارزمية SM-2 (Spaced Repetition) للحفظ الذكي
class SrsRecord {
  int ease;       // EF (250 = 2.5)
  int interval;   // أيام
  int repetitions;
  DateTime dueDate;

  SrsRecord({this.ease = 250, this.interval = 0, this.repetitions = 0, required this.dueDate});

  Map<String, dynamic> toJson() => {
        'ease': ease,
        'interval': interval,
        'repetitions': repetitions,
        'dueDate': dueDate.toIso8601String(),
      };

  factory SrsRecord.fromJson(Map<String, dynamic> j) => SrsRecord(
        ease: j['ease'] ?? 250,
        interval: j['interval'] ?? 0,
        repetitions: j['repetitions'] ?? 0,
        dueDate: DateTime.parse(j['dueDate'] ?? DateTime.now().toIso8601String()),
      );
}

class SpacedRepetitionService {
  /// quality: 0 (نسيت) .. 5 (مثالي)
  SrsRecord review(SrsRecord rec, int quality) {
    if (quality < 3) {
      // نسيان: إعادة من الصفر
      return SrsRecord(ease: rec.ease, interval: 1, repetitions: 0, dueDate: DateTime.now().add(const Duration(days: 1)));
    }
    int newRep = rec.repetitions + 1;
    int newInterval;
    if (newRep == 1) {
      newInterval = 1;
    } else if (newRep == 2) {
      newInterval = 6;
    } else {
      newInterval = (rec.interval * rec.ease / 100).round();
    }
    int newEase = (rec.ease + (8 - 5 * quality + (2 - quality) * quality / 10)).round();
    if (newEase < 130) newEase = 130;
    return SrsRecord(
      ease: newEase,
      interval: newInterval,
      repetitions: newRep,
      dueDate: DateTime.now().add(Duration(days: newInterval)),
    );
  }
}
