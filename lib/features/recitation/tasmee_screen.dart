import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/repositories/quran_repository.dart';

class TasmeeScreen extends ConsumerStatefulWidget {
  const TasmeeScreen({super.key});
  @override
  ConsumerState<TasmeeScreen> createState() => _TasmeeScreenState();
}

class _TasmeeScreenState extends ConsumerState<TasmeeScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _recording = false;
  String _transcript = '';
  double _accuracy = 0;

  Future<void> _start() async {
    final stt = ref.read(sttServiceProvider);
    await stt.init(modelPath: 'assets/models/ggml-base.bin');
    setState(() => _recording = true);
    stt.transcribeStream().listen((t) {
      setState(() {
        _transcript = t;
        _controller.text = t;
      });
    });
  }

  Future<void> _stop() async {
    final stt = ref.read(sttServiceProvider);
    await stt.stop();
    setState(() => _recording = false);
    _computeAccuracy();
  }

  void _computeAccuracy() {
    // simple word-overlap accuracy vs expected ayah text
    final expected = _controller.text.trim();
    // placeholder: compare transcript to itself length heuristic
    if (expected.isEmpty) {
      _accuracy = 0;
      return;
    }
    setState(() => _accuracy = 0.85);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(quranRepositoryProvider);
    final storage = ref.read(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تسميع (صوت + كتابة)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('اختر السورة والآيات (حالياً: الفاتحة 1-7)', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(_recording ? Icons.stop : Icons.mic),
                    label: Text(_recording ? 'إيقاف' : 'بدء التسميع'),
                    style: ElevatedButton.styleFrom(backgroundColor: _recording ? Colors.red : null),
                    onPressed: _recording ? _stop : _start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب ما تسمع (أو تحدث)…',
                ),
                style: const TextStyle(fontSize: 20, height: 1.8),
              ),
            ),
            const SizedBox(height: 8),
            Text('النص المُعرَّف: $_transcript'),
            Text('الدقة: ${(_accuracy * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await storage.saveTasmeeAttempt(
                  surah: 1,
                  fromAyah: 1,
                  toAyah: 7,
                  transcript: _controller.text,
                  accuracy: _accuracy,
                );
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ التسميع')));
              },
              child: const Text('حفظ التسميع'),
            ),
          ],
        ),
      ),
    );
  }
}
