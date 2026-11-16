import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// تنزيل تلاوات للأوفلاين: سورة كاملة (كل آية ملف)
class DownloadService {
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

  /// تنزيل آية واحدة. يعيد true عند النجاح.
  Future<bool> downloadAyah({
    required String reciterFolder,
    required int surah,
    required int ayah,
    void Function(double progress)? onProgress,
  }) async {
    final target = File(await localPath(reciterFolder, surah, ayah));
    if (await target.exists()) return true;
    final s3 = surah.toString().padLeft(3, '0');
    final a3 = ayah.toString().padLeft(3, '0');
    final url = 'https://everyayah.com/data/$reciterFolder/$s3$a3.mp3';
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse(url));
      final resp = await req.close();
      if (resp.statusCode != 200) { client.close(); return false; }
      final total = resp.contentLength;
      await target.parent.create(recursive: true);
      final sink = target.openWrite();
      int received = 0;
      await for (final chunk in resp) {
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
    int done = 0;
    for (int a = 1; a <= ayahCount; a++) {
      final ok = await downloadAyah(reciterFolder: reciterFolder, surah: surah, ayah: a);
      if (ok) done++;
      onProgress?.call(done, ayahCount);
    }
    return done;
  }
}
