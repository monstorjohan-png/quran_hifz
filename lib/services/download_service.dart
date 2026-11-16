import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../core/constants/surahs.dart';

/// تنزيل تلاوات للأوفلاين: آية / سورة / كل القرآن — مع إيقاف واستئناف
class DownloadService {
  /// عند ضبطها على true توقف التحميل (يستأنف لاحقاً من حيث وقف)
  bool cancelRequested = false;

  Future<Directory> _dir() async {
    final base = await getApplicationDocumentsDirectory();
    final d = Directory('${base.path}/quran_audio');
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  Future<String> localPath(String reciterFolder, int surah, int ayah) async {
    final d = await _dir();
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return '${d.path}/$reciterFolder/$surah/$s$a.mp3';
  }

  Future<bool> isDownloaded(String reciterFolder, int surah, int ayah) async {
    return File(await localPath(reciterFolder, surah, ayah)).exists();
  }

  Future<bool> downloadAyah({
    required String reciterFolder,
    required int surah,
    required int ayah,
    void Function(double progress)? onProgress,
  }) async {
    if (cancelRequested) return false;
    final target = File(await localPath(reciterFolder, surah, ayah));
    if (await target.exists()) return true; // استئناف: تخطٍّ المُنجز
    final s3 = surah.toString().padLeft(3, '0');
    final a3 = ayah.toString().padLeft(3, '0');
    final url = 'https://everyayah.com/data/$reciterFolder/$s3$a3.mp3';
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close();
      if (resp.statusCode != 200) {
        client.close();
        return false;
      }
      final total = resp.contentLength;
      await target.parent.create(recursive: true);
      final sink = target.openWrite();
      int received = 0;
      await for (final chunk in resp) {
        if (cancelRequested) {
          await sink.close();
          client.close();
          return false;
        }
        sink.add(chunk);
        received += chunk.length;
        if (onProgress != null && total > 0) onProgress(received / total);
      }
      await sink.flush();
      await sink.close();
      client.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// تنزيل سورة كاملة؛ يُرجع عدد الآيات المُنزَّلة
  Future<int> downloadSurah({
    required String reciterFolder,
    required int surah,
    required int ayahCount,
    void Function(int done, int total)? onProgress,
  }) async {
    cancelRequested = false;
    int done = 0;
    for (int a = 1; a <= ayahCount; a++) {
      if (cancelRequested) break;
      final ok = await downloadAyah(reciterFolder: reciterFolder, surah: surah, ayah: a);
      if (ok) done++;
      onProgress?.call(done, ayahCount);
    }
    return done;
  }

  /// تنزيل كل القرآن دفعة واحدة (كل السور 1..114)
  /// onProgress: (surahIndex, ayahDoneInSurah, overallDone, overallTotal)
  Future<int> downloadAllQuran({
    required String reciterFolder,
    void Function(int surah, int surahDone, int surahTotal, int overallDone, int overallTotal)? onProgress,
  }) async {
    cancelRequested = false;
    final total = surahs.fold<int>(0, (p, s) => p + s.ayahCount);
    int overallDone = 0;
    for (final s in surahs) {
      if (cancelRequested) break;
      for (int a = 1; a <= s.ayahCount; a++) {
        if (cancelRequested) break;
        final ok = await downloadAyah(reciterFolder: reciterFolder, surah: s.number, ayah: a);
        if (ok) overallDone++;
        onProgress?.call(s.number, a, s.ayahCount, overallDone, total);
      }
    }
    return overallDone;
  }
}
