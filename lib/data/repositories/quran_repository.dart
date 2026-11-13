import 'package:quran/quran.dart' as q;
import '../models/ayah.dart';

class QuranRepository {
  /// Returns ayahs for a surah (1-based). Uses bundled quran package (offline).
  List<Ayah> getSurahAyahs(int surah) {
    final count = q.getVerseCount(surah);
    return List.generate(count, (i) {
      final n = i + 1;
      return Ayah(
        surah: surah,
        number: n,
        text: q.getVerse(surah, n, verseEndSymbol: true),
        textSimple: q.getVerse(surah, n, verseEndSymbol: false),
      );
    });
  }

  String surahNameAr(int surah) => q.getSurahNameArabic(surah);
  String surahNameEn(int surah) => q.getSurahName(surah);
}
