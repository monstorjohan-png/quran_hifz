import 'package:hive_flutter/hive_flutter.dart';

/// إنجازات / Streak / Heatmap (أوفلاين)
class Achievement {
  final String id;
  final String title;
  final String description;
  final int threshold;
  const Achievement(this.id, this.title, this.description, this.threshold);
}

class AchievementsService {
  static const List<Achievement> all = [
    Achievement('a1', 'البداية', 'احفظ أول 7 آيات', 7),
    Achievement('a2', 'الحافظ المبتدئ', 'احفظ أول 50 آية', 50),
    Achievement('a3', 'الحافظ المجتهد', 'احفظ 100 آية', 100),
    Achievement('a4', 'ربع القرآن', 'احفظ 1556 آية', 1556),
    Achievement('a5', 'نصف القرآن', 'احفظ 3118 آية', 3118),
    Achievement('a6', 'الفاتحة كاملة', 'احفظ سورة الفاتحة', 7),
    Achievement('a7', 'ختام المؤمنين', 'احفظ 1000 آية', 1000),
    Achievement('a8', 'الختم كاملاً', 'احفظ القرآن كاملاً', 6236),
  ];

  static int memorizedCount() => Hive.box('progress').length;

  static List<Achievement> unlocked() =>
      all.where((a) => memorizedCount() >= a.threshold).toList();

  static List<Achievement> locked() =>
      all.where((a) => memorizedCount() < a.threshold).toList();
}
