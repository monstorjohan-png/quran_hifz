/// خدمة التعرف على الكلام (STT) بدون نت — Whisper.cpp
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
    yield 'بسم الله الرحمن الرحيم';
  }
  @override
  Future<String> transcribeFile(String wavPath) async => 'بسم الله الرحمن الرحيم';
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

/// تكامل Whisper.cpp (Android) - ملاحظات:
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
