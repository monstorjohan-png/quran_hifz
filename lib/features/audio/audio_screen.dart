import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/models/reciter.dart';
import '../../data/repositories/quran_repository.dart';
import '../../services/download_service.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});
  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  String _reciterId = 'alafasy';
  int _surah = 1;
  bool _downloading = false;
  double _dlProgress = 0;
  String _dlStatus = '';

  final _download = DownloadService();

  @override
  void initState() {
    super.initState();
    _reciterId = ref.read(storageServiceProvider).reciterId;
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final repo = ref.read(quranRepositoryProvider);
    final ayahCount = surahs.firstWhere((s) => s.number == _surah, orElse: () => surahs.first).ayahCount;
    final reciter = Reciter.famous.firstWhere((r) => r.id == _reciterId, orElse: () => Reciter.famous.first);

    return Scaffold(
      appBar: AppBar(
        title: const Text('صوت الشيوخ'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _reciterId,
              decoration: const InputDecoration(labelText: 'القارئ', border: OutlineInputBorder()),
              items: Reciter.famous.map((r) => DropdownMenuItem(value: r.id, child: Text(r.nameAr))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _reciterId = v);
                storage.reciterId = v;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _surah,
              decoration: const InputDecoration(labelText: 'السورة', border: OutlineInputBorder()),
              items: surahs.map((s) => DropdownMenuItem(value: s.number, child: Text('${s.number}. ${s.nameAr} (${s.ayahCount} آية)'))).toList(),
              onChanged: (v) => setState(() => _surah = v ?? 1),
            ),
            const SizedBox(height: 12),
            Text('السرعة: ${storage.playbackSpeed.toStringAsFixed(2)}'),
            Slider(
              value: storage.playbackSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (v) {
                setState(() {});
                storage.playbackSpeed = v;
                audio.player.setSpeed(v);
              },
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('تشغيل السورة'),
                    onPressed: () => context.go('/reader/$_surah'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    icon: Icon(_downloading ? Icons.hourglass_top : Icons.download),
                    label: Text(_downloading ? '${(_dlProgress * 100).toStringAsFixed(0)}%' : 'تنزيل للأوفلاين'),
                    onPressed: _downloading ? null : () => _downloadSurah(reciter.folder, ayahCount),
                  ),
                ),
              ],
            ),
            if (_dlStatus.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_dlStatus, style: const TextStyle(fontSize: 12))),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: Reciter.famous.map((r) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(r.nameAr),
                      subtitle: Text(r.nameEn),
                      trailing: r.id == _reciterId ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        setState(() => _reciterId = r.id);
                        storage.reciterId = r.id;
                      },
                    )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadSurah(String folder, int ayahCount) async {
    setState(() {
      _downloading = true;
      _dlProgress = 0;
      _dlStatus = 'جارٍ تنزيل السورة...';
    });
    final done = await _download.downloadSurah(
      reciterFolder: folder,
      surah: _surah,
      ayahCount: ayahCount,
      onProgress: (d, t) {
        if (mounted) {
          setState(() {
            _dlProgress = t == 0 ? 0 : d / t;
            _dlStatus = 'تم تنزيل $d من $t آية';
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _downloading = false;
        _dlStatus = 'اكتمل: $done/$ayahCount آية (أوفلاين جاهزة)';
      });
    }
  }
}
