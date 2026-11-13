import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final stats = storage.stats();
    return Scaffold(
      appBar: AppBar(title: const Text('التقدم')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('${stats['memorizedAyahs']}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green)),
                    const Text('آية محفوظة'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('طرق التعلم (Spaced Repetition):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(leading: Icon(Icons.repeat), title: Text('مراجعة يومية (آيات الأمس)')),
            const ListTile(leading: Icon(Icons.calendar_today), title: Text('مراجعة أسبوعية')),
            const ListTile(leading: Icon(Icons.event), title: Text('مراجعة شهرية')),
          ],
        ),
      ),
    );
  }
}
