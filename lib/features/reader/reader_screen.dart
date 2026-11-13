import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/models/ayah.dart';
import '../../data/models/reciter.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final int surah;
  const ReaderScreen({super.key, required this.surah});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  int? _playingAyah;

  SurahInfo get _surahInfo => surahs.firstWhere((s) => s.number == widget.surah, orElse: () => surahs.first);

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(quranRepositoryProvider);
    final audio = ref.read(audioServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final ayahs = repo.getSurahAyahs(widget.surah);
    final reciter = Reciter.famous.firstWhere((r) => r.id == storage.reciterId, orElse: () => Reciter.famous.first);

    return Scaffold(
      appBar: AppBar(title: Text(repo.surahNameAr(widget.surah))),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ayahs.length,
        itemBuilder: (_, i) {
          final a = ayahs[i];
          final memorized = storage.isMemorized(a.surah, a.number);
          return Card(
            color: _playingAyah == a.number ? Colors.amber.shade100 : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(a.text, textAlign: TextAlign.right, style: const TextStyle(fontSize: 22, height: 1.8)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_playingAyah == a.number ? Icons.pause : Icons.play_arrow),
                        onPressed: () async {
                          setState(() => _playingAyah = a.number);
                          await audio.playAyah(reciterBaseUrl: reciter.baseUrl, surah: a.surah, ayah: a.number);
                        },
                      ),
                      IconButton(
                        icon: Icon(memorized ? Icons.check_circle : Icons.check_circle_outline),
                        color: memorized ? Colors.green : null,
                        onPressed: () => storage.markAyahMemorized(a.surah, a.number).then((_) => setState(() {})),
                      ),
                      Text('${a.number}', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
