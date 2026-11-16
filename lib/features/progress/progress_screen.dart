import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final stats = storage.stats();
    final due = storage.dueToday().length;
    final streak = storage.streak;

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقدم'),
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
                  child: _statCard('آيات محفوظة', '${stats['memorizedAyahs']}', Colors.green, Icons.check_circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('استحقاق مراجعة', '$due', Colors.orange, Icons.event),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _statCard('Streak', '$streak يوم', Colors.deepOrange, Icons.local_fire_department),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('طرق التعلم:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const ListTile(leading: Icon(Icons.repeat), title: Text('Spaced Repetition (SM-2)'), subtitle: Text('مراجعة ذكية للآيات المستحقة')),
            const ListTile(leading: Icon(Icons.calendar_today), title: Text('مراجعة يومية')),
            const ListTile(leading: Icon(Icons.event), title: Text('مراجعة أسبوعية')),
            const ListTile(leading: Icon(Icons.mic), title: Text('تسميع'), onLongPress: null),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon) => Card(
        color: color.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}
