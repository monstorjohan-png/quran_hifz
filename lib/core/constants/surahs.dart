/// أسماء السور (1..114) - قائمة مختصرة (اسم + عدد الآيات)
class SurahInfo {
  final int number;
  final String nameAr;
  final String nameEn;
  final int ayahCount;
  final bool meccan;
  const SurahInfo(this.number, this.nameAr, this.nameEn, this.ayahCount, this.meccan);
}

const List<SurahInfo> surahs = [
  SurahInfo(1, 'الفاتحة', 'Al-Fatiha', 7, true),
  SurahInfo(2, 'البقرة', 'Al-Baqara', 286, false),
  SurahInfo(3, 'آل عمران', 'Aal-Imran', 200, false),
  SurahInfo(4, 'النساء', 'An-Nisa', 176, false),
  SurahInfo(5, 'المائدة', 'Al-Ma\'ida', 120, false),
  SurahInfo(6, 'الأنعام', 'Al-An\'am', 165, true),
  SurahInfo(36, 'يس', 'Ya-Sin', 83, true),
  SurahInfo(55, 'الرحمن', 'Ar-Rahman', 78, false),
  SurahInfo(67, 'الملك', 'Al-Mulk', 30, true),
  SurahInfo(78, 'النبأ', 'An-Naba', 40, true),
  SurahInfo(112, 'الإخلاص', 'Al-Ikhlas', 4, true),
  SurahInfo(113, 'الفلق', 'Al-Falaq', 5, true),
  SurahInfo(114, 'الناس', 'An-Nas', 6, true),
];

/// طرق التعلم التفاعلية
enum LearningMethod {
  repeatListen,    // استماع متكرر
  chunking,        // تجزئة (3 آيات)
  spaced,          // تكرار متباعد
  writeAlong,      // كتابة أثناء التسميع
  voiceRecite,     // تسميع صوتي
  tajweed,         // تجويد
}

extension LearningMethodX on LearningMethod {
  String get label => switch (this) {
        LearningMethod.repeatListen => 'استماع متكرر',
        LearningMethod.chunking => 'تجزئة (أجزاء صغيرة)',
        LearningMethod.spaced => 'تكرار متباعد',
        LearningMethod.writeAlong => 'كتابة أثناء التسميع',
        LearningMethod.voiceRecite => 'تسميع صوتي',
        LearningMethod.tajweed => 'تجويد',
      };
}
