import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/models/reciter.dart';

class AudioScreen extends ConsumerStatefulWidget {
  const AudioScreen({super.key});
  @override
  ConsumerState<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends ConsumerState<AudioScreen> {
  String _reciterId = 'alafasy';

  @override
  void initState() {
    super.initState();
    _reciterId = ref.read(storageServiceProvider).reciterId;
  }

  @override
  Widget build(BuildContext context) {
    final audio = ref.read(audioServiceProvider);
    final storage = ref.read(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('صوت الشيوخ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _reciterId,
              decoration: const InputDecoration(labelText: 'القارئ'),
              items: Reciter.famous.map((r) => DropdownMenuItem(value: r.id, child: Text('${r.nameAr} (${r.style})'))).toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => _reciterId = v);
                storage.reciterId = v;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('اختر سورة من شاشة القراءة ثم اضغط تشغيل. التحكم بالسرعة:', textAlign: TextAlign.center),
          ),
          Slider(
            value: storage.playbackSpeed,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            label: storage.playbackSpeed.toStringAsFixed(2),
            onChanged: (v) {
              setState(() {});
              storage.playbackSpeed = v;
              audio.player.setSpeed(v);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous), onPressed: () => audio.seek(Duration.zero)),
              IconButton(icon: const Icon(Icons.play_arrow, size: 40), onPressed: () => audio.resume()),
              IconButton(icon: const Icon(Icons.pause), onPressed: () => audio.pause()),
              IconButton(icon: const Icon(Icons.stop), onPressed: () => audio.stop()),
            ],
          ),
          const SizedBox(height: 16),
          const Text('قراء عظماء (أصوات ناعمة ومؤثرة):', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
