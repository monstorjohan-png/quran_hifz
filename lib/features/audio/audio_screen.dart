import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/providers.dart';
import '../../data/models/reciter.dart';
import '../../data/repositories/quran_repository.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});
  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  String _reciterId = 'alafasy';
  int _surah = 1;

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
              items: Reciter.famous.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.nameAr}'))).toList(),
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
              items: surahs.map((s) => DropdownMenuItem(value: s.number, child: Text('${s.number}. ${s.nameAr}'))).toList(),
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
              ],
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
}
