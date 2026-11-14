import 'dart:async';
/// التكامل (Android): استخدم platform channel أو حزمة whisper_ggml.
/// هذا الملف يعرّف الواجهة + تطبيقاً وهمياً للتطوير.
abstract class SttService {
  Future<void> init({required String modelPath});
  /// يبدأ التسجيل ويُرجع نصاً متدفقاً (partial) ثم final
  Stream<String> transcribeStream();
  Future<String> transcribeFile(String wavPath);
  Future<void> stop();
  Future<void> dispose();
}

/// تطبيق وهمي (mock) للتطوير والاختبار — يُستبدل بـ WhisperSttService
class MockSttService implements SttService {
  @override
  Future<void> init({required String modelPath}) async {}
  @override
  Stream<String> transcribeStream() async* {
    await Future.delayed(const Duration(milliseconds: 500));
    yield 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';
    await Future.delayed(const Duration(milliseconds: 800));
    yield 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ';
    await Future.delayed(const Duration(milliseconds: 800));
    yield 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';
  }
  @override
  Future<String> transcribeFile(String wavPath) async => 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

import 'package:speech_to_text/speech_to_text.dart';

/// STT menggunakan Android SpeechRecognizer (on-device إذا كان حزمة اللغة مثبتة)
class DeviceSttService implements SttService {
  final SpeechToText _stt = SpeechToText();
  bool _available = false;
  final _controller = StreamController<String>.broadcast();

  @override
  Future<void> init({required String modelPath}) async {
    _available = await _stt.initialize(
      onError: (e) => _controller.addError(e),
    );
  }

  @override
  Stream<String> transcribeStream() {
    if (!_available) return const Stream.empty();
    _stt.listen(
      onResult: (r) => _controller.add(r.recognizedWords),
      localeId: 'ar_SA',
      partialResults: true,
    );
    return _controller.stream;
  }

  @override
  Future<String> transcribeFile(String wavPath) async => '';

  @override
  Future<void> stop() async => _stt.stop();

  @override
  Future<void> dispose() async {
    await _stt.cancel();
    await _controller.close();
  }
}
/// 1. أضف whisper.cpp كـ native lib في android/app/src/main/cpp
/// 2. نموذج ggml (base/small) في assets/models/ (عربي: ggml-base.bin ~142MB)
/// 3. استدع عبر MethodChannel('whisper') method 'transcribe' with wav path
/// 4. أو استخدم حزمة: whisper_ggml (pub.dev) التي تلف whisper.cpp
class WhisperSttService implements SttService {
  // TODO: implement via platform channel / whisper_ggml
  @override
  Future<void> init({required String modelPath}) async {
    throw UnimplementedError('WhisperSttService: integrate whisper.cpp');
  }
  @override
  Stream<String> transcribeStream() => const Stream.empty();
  @override
  Future<String> transcribeFile(String wavPath) async => '';
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}
