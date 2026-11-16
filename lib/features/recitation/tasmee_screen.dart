import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/repositories/quran_repository.dart';

class TasmeeScreen extends ConsumerStatefulWidget {
  const TasmeeScreen({super.key});
  @override
  ConsumerState<TasmeeScreen> createState() => _TasmeeScreenState();
}

class _TasmeeScreenState extends ConsumerState<TasmeeScreen> {
  final TextEditingController _controller = TextEditingController();
  int _surah = 1;
  int _fromAyah = 1;
  bool _recording = false;
  String _transcript = '';
  double _accuracy = 0;
  String _expected = '';

  @override
  void initState() {
    super.initState();
    _loadExpected();
  }

  void _loadExpected() {
    final repo = ref.read(quranRepositoryProvider);
    final ayahs = repo.getSurahAyahs(_surah);
    final from = (_fromAyah - 1).clamp(0, ayahs.length - 1);
    final to = (from + 3).clamp(0, ayahs.length);
    setState(() {
      _expected = ayahs.sublist(from, to).map((a) => a.textSimple).join(' ');
    });
  }

  Future<void> _start() async {
    final stt = ref.read(sttServiceProvider);
    await stt.init(modelPath: 'assets/models/ggml-base.bin');
    setState(() => _recording = true);
    stt.transcribeStream().listen((t) {
      if (!mounted) return;
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
    final typed = _normalize(_controller.text);
    final exp = _normalize(_expected);
    if (exp.isEmpty || typed.isEmpty) {
      setState(() => _accuracy = 0);
      return;
    }
    final expWords = exp.split(' ');
    final typedWords = typed.split(' ');
    int match = 0;
    for (final w in typedWords) {
      if (expWords.contains(w)) match++;
    }
    setState(() => _accuracy = match / expWords.length);
  }

  String _normalize(String s) => s.replaceAll(RegExp(r'[^\u0600-\u06FF\s]'), '').trim();

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسميع (صوت + كتابة)'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _surah,
                    decoration: const InputDecoration(labelText: 'السورة', border: OutlineInputBorder()),
                    items: surahs.map((s) => DropdownMenuItem(value: s.number, child: Text('${s.number}. ${s.nameAr}'))).toList(),
                    onChanged: (v) {
                      setState(() => _surah = v ?? 1);
                      _loadExpected();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    initialValue: '$_fromAyah',
                    decoration: const InputDecoration(labelText: 'من آية', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      _fromAyah = int.tryParse(v) ?? 1;
                      _loadExpected();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text('المتوقع: $_expected', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 16, height: 1.8)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(_recording ? Icons.stop : Icons.mic),
              label: Text(_recording ? 'إيقاف' : 'بدء التسميع'),
              style: ElevatedButton.styleFrom(backgroundColor: _recording ? Colors.red : Colors.green),
              onPressed: _recording ? _stop : _start,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'اكتب ما تسمع (أو تحدث)…',
                ),
                style: const TextStyle(fontSize: 20, height: 1.8),
                onChanged: (_) => _computeAccuracy(),
              ),
            ),
            const SizedBox(height: 8),
            Text('النص المُعرَّف: $_transcript', maxLines: 2, overflow: TextOverflow.ellipsis),
            Text('الدقة: ${(_accuracy * 100).toStringAsFixed(0)}%'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await storage.saveTasmeeAttempt(
                  surah: _surah,
                  fromAyah: _fromAyah,
                  toAyah: _fromAyah + 2,
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
