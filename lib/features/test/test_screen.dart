import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/repositories/quran_repository.dart';

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});
  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  final _rnd = Random();
  int _surah = 1;
  int _ayah = 1;
  String _question = '';
  List<String> _options = [];
  int _correct = 0;
  int _score = 0;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _pickQuestion();
  }

  void _pickQuestion() {
    final repo = ref.read(quranRepositoryProvider);
    _surah = surahs[_rnd.nextInt(surahs.length)].number;
    final ayahs = repo.getSurahAyahs(_surah);
    if (ayahs.length < 4) {
      _pickQuestion();
      return;
    }
    _ayah = _rnd.nextInt(ayahs.length - 1) + 1;
    final correctText = ayahs[_ayah].textSimple;
    _question = 'ما الآية التي تلي هذه الآية؟\n\n«${ayahs[_ayah - 1].textSimple}»';
    // خيارات: الصحيح + 3 مشتتات عشوائية
    final pool = <String>{correctText};
    while (pool.length < 4) {
      final other = ayahs[_rnd.nextInt(ayahs.length)].textSimple;
      if (other != correctText) pool.add(other);
    }
    _options = pool.toList()..shuffle(_rnd);
    _correct = _options.indexOf(correctText);
    setState(() {});
  }

  void _answer(int i) {
    setState(() {
      _total++;
      if (i == _correct) _score++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(i == _correct ? '✅ صحيح!' : '❌ خطأ'), duration: const Duration(milliseconds: 800)),
    );
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _pickQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار ($_score/$_total)'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
              child: Text('سورة ${surahs.firstWhere((s) => s.number == _surah).nameAr}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(_question, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, height: 1.8)),
              ),
            ),
            ..._options.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: () => _answer(e.key),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(e.value, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
