import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

/// خدمة الصوت: تشغيل تلاوات الشيوخ + TTS
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Future<void> init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  /// تشغيل آية من reciter (أوفلاين إذا تم تنزيل الملف)
  Future<void> playAyah({
    required String reciterBaseUrl,
    required int surah,
    required int ayah,
  }) async {
    // Islamic Network URL pattern: {base}/{surah padded?}... actually per-ayah: {base}/{surah}{ayah padded 3}.mp3
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    final url = '$reciterBaseUrl/$s$a.mp3';
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> stop() => _player.stop();
  Future<void> seek(Duration d) => _player.seek(d);

  void dispose() => _player.dispose();
}
