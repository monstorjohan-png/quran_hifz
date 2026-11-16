import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';

/// الواجهة العامة لخدمة التعرف على الكلام
abstract class SttService {
  Future<void> init({required String modelPath});
  Stream<String> transcribeStream();
  Future<String> transcribeFile(String wavPath);
  Future<void> stop();
  Future<void> dispose();
}

/// STT باستخدام Android SpeechRecognizer (on-device إذا حزمة اللغة مثبتة)
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
