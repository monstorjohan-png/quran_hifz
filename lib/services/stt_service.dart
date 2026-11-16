import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:record/record.dart';
import 'package:whisper_ggml/whisper_ggml.dart';
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

/// STT باستخدام Android SpeechRecognizer (on-device إذا كان حزمة اللغة مثبتة)
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
/// STT بصوت حقيقي عبر Whisper.cpp — أوفلاين بعد أول تنزيل للنموذج (~142MB)
/// ملاحظة: النموذج يُنزَّل تلقائياً عند أول استخدام ثم يُخزَّن مؤقتاً
class WhisperLiveSttService implements SttService {
  final WhisperController _controller = WhisperController();
  final AudioRecorder _recorder = AudioRecorder();
  StreamController<String>? _streamController;
  WhisperLiveSession? _session;
  StreamSubscription<String>? _sub;
  bool _initOk = false;

  @override
  Future<void> init({required String modelPath}) async {
    // التهيئة تتم عند بدء الجلسة (transcribeStream)
    _initOk = true;
  }

  @override
  Stream<String> transcribeStream() {
    _streamController ??= StreamController<String>.broadcast();
    _start();
    return _streamController!.stream;
  }

  Future<void> _start() async {
    if (!_initOk || _streamController == null) return;
    try {
      final pcmStream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ));
      _session = await _controller.transcribeLive(
        model: WhisperModel.base, // base = توازن سرعة/دقة؛ small أدق (أثقل)
        pcm16Stream: pcmStream,
        lang: 'ar',
      );
      _sub = _session!.partials.listen((text) {
        _streamController?.add(text);
      });
    } catch (e) {
      _streamController?.addError('تعذّر بدء التسميع: $e');
    }
  }

  @override
  Future<String> transcribeFile(String wavPath) async {
    try {
      final result = await _controller.transcribe(
        model: WhisperModel.base,
        audioPath: wavPath,
        lang: 'ar',
      );
      return result?.transcription.text ?? '';
    } catch (_) {
      return '';
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _recorder.stop();
      final finalText = await _session?.stop();
      if (finalText != null && finalText.isNotEmpty) {
        _streamController?.add(finalText);
      }
      await _sub?.cancel();
      _session = null;
    } catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _sub?.cancel();
    await _streamController?.close();
  }
}
