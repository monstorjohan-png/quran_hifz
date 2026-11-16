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
  bool _paused = false;
  bool _allMode = false;
  double _dlProgress = 0;
  String _dlStatus = '';
  bool _cancelRequested = false;

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
                    icon: Icon(_downloading && !_allMode ? Icons.hourglass_top : Icons.download),
                    label: Text(_downloading && !_allMode ? '${(_dlProgress * 100).toStringAsFixed(0)}%' : 'تنزيل السورة'),
                    onPressed: _downloading ? null : () => _downloadSurah(reciter.folder, ayahCount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                    icon: const Icon(Icons.download_for_offline),
                    label: const Text('تنزيل كل القرآن (دفعة واحدة)'),
                    onPressed: _downloading ? null : () => _downloadAll(reciter.folder),
                  ),
                ),
                const SizedBox(width: 8),
                if (_downloading)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.pause),
                    label: const Text('إيقاف'),
                    onPressed: () {
                      _download.cancelRequested = true;
                      setState(() => _paused = true);
                    },
                  ),
              ],
            ),
            if (_downloading || _dlStatus.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  LinearProgressIndicator(value: _dlProgress),
                  const SizedBox(height: 4),
                  Text(_dlStatus, style: const TextStyle(fontSize: 12)),
                  if (_paused) const Text('متوقف مؤقتاً — اضغط «تنزيل» للاستئناف من حيث توقفت',
                      style: TextStyle(fontSize: 11, color: Colors.orange)),
                ],
              ),
            ),
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
      _paused = false;
      _allMode = false;
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
            _dlStatus = 'تنزيل $d من $t آية';
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _downloading = false;
        _dlStatus = _paused ? 'متوقف — $done/$ayahCount آية' : 'اكتمل: $done/$ayahCount آية';
      });
    }
  }

  Future<void> _downloadAll(String folder) async {
    final total = surahs.fold<int>(0, (p, s) => p + s.ayahCount);
    setState(() {
      _downloading = true;
      _paused = false;
      _allMode = true;
      _dlProgress = 0;
      _dlStatus = 'جارٍ تنزيل كل القرآن ($total آية) — يمكن الإيقاف والاستئناف';
    });
    final done = await _download.downloadAllQuran(
      reciterFolder: folder,
      onProgress: (surah, sDone, sTotal, overall, overallTotal) {
        if (mounted) {
          setState(() {
            _dlProgress = overallTotal == 0 ? 0 : overall / overallTotal;
            _dlStatus = 'سورة $surah: $sDone/$sTotal آية — الإجمالي: $overall/$overallTotal';
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _downloading = false;
        _dlStatus = _paused
            ? 'توقف عند $done/$total آية — اضغط «تنزيل كل القرآن» للاستئناف من حيث توقفت'
            : 'اكتمل القرآن كاملاً أوفلاين: $done/$total آية 🎉';
      });
    }
  }
}
