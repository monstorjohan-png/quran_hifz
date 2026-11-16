import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/models/ayah.dart';
import '../../data/models/reciter.dart';
import '../../services/audio_service.dart';
import '../../services/download_service.dart';
import 'package:just_audio/just_audio.dart';

final _download = DownloadService();

class ReaderScreen extends ConsumerStatefulWidget {
  final int surah;
  const ReaderScreen({super.key, required this.surah});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  int? _playingAyah;
  String? _audioError;
  bool _playingAll = false;

  SurahInfo get _surahInfo => surahs.firstWhere((s) => s.number == widget.surah,
      orElse: () => surahs.first);

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(quranRepositoryProvider);
    final audio = ref.read(audioServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final ayahs = repo.getSurahAyahs(widget.surah);
    final reciter = Reciter.famous.firstWhere((r) => r.id == storage.reciterId,
        orElse: () => Reciter.famous.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(repo.surahNameAr(widget.surah)),
        leading: BackButton(onPressed: () => context.go('/')),
        actions: [
          IconButton(
            icon: const Icon(Icons.headphones),
            tooltip: 'تشغيل السورة',
            onPressed: () => _playAll(audio, reciter, ayahs),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_audioError != null)
            Container(
              width: double.infinity,
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              child: Text(_audioError!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: ayahs.length,
              itemBuilder: (_, i) {
                final a = ayahs[i];
                final memorized = storage.isMemorized(a.surah, a.number);
                final isPlaying = _playingAyah == a.number;
                return Card(
                  elevation: isPlaying ? 4 : 1,
                  color: isPlaying ? Colors.amber.shade50 : null,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          a.text,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 2.0,
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle_outline),
                              color: Colors.green.shade700,
                              onPressed: () => _toggleAyah(audio, reciter, a),
                            ),
                            IconButton(
                              icon: Icon(memorized ? Icons.check_circle : Icons.check_circle_outline),
                              color: memorized ? Colors.green : Colors.grey,
                              onPressed: () {
                                storage.markAyahMemorized(a.surah, a.number);
                                storage.bumpStreak();
                                storage.saveSrs(a.surah, a.number, {
                                  'interval': 1,
                                  'repetitions': 1,
                                  'ease': 250,
                                  'dueDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
                                });
                                setState(() {});
                              },
                            ),
                            const Spacer(),
                            Text('${a.number}', style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _playSmart(AudioService audio, Reciter reciter, Ayah a) async {
    final local = await _download.localPath(reciter.folder, a.surah, a.number);
    if (await File(local).exists()) {
      await audio.playFile(local);
    } else {
      await _playSmart(audio, reciter, a);
    }
  }

  Future<void> _toggleAyah(AudioService audio, Reciter reciter, Ayah a) async {
    if (_playingAyah == a.number) {
      await audio.pause();
      setState(() => _playingAyah = null);
      return;
    }
    setState(() {
      _playingAyah = a.number;
      _audioError = null;
    });
    try {
      await _playSmart(audio, reciter, a);
      audio.player.playerStateStream.listen((st) {
        if (st.processingState == ProcessingState.completed) {
          if (mounted) setState(() => _playingAyah = null);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _audioError = 'تعذّر تشغيل الصوت: $e');
    }
  }

  Future<void> _playAll(AudioService audio, Reciter reciter, List<Ayah> ayahs) async {
    setState(() {
      _playingAll = true;
      _audioError = null;
    });
    for (final a in ayahs) {
      if (!mounted || !_playingAll) break;
      setState(() => _playingAyah = a.number);
      try {
        await _playSmart(audio, reciter, a);
        await audio.player.playerStateStream.firstWhere(
            (s) => s.processingState == ProcessingState.completed);
      } catch (e) {
        if (mounted) setState(() => _audioError = 'تعذّر تشغيل الصوت: $e');
        break;
      }
    }
    if (mounted) setState(() {
      _playingAll = false;
      _playingAyah = null;
    });
  }
}
