import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/providers.dart';
import '../../services/achievements_service.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageServiceProvider);
    final unlocked = AchievementsService.unlocked();
    final locked = AchievementsService.locked();

    // Heatmap: آخر 35 يوم
    final days = List.generate(35, (i) => DateTime.now().subtract(Duration(days: 34 - i)));
    final progress = Hive.box('progress').values.toList();
    int countFor(DateTime d) {
      final ds = '${d.year}-${d.month}-${d.day}';
      int n = 0;
      for (final v in progress) {
        if (v is Map) {
          final at = v['memorizedAt'];
          if (at is String && at.startsWith(ds)) n++;
        }
      }
      return n;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإنجازات والسلسلة'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.deepOrange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 40),
                  const SizedBox(width: 12),
                  Text('سلسلة: ${storage.streak} يوم متتالي', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: days.map((d) {
              final n = countFor(d);
              final color = n == 0 ? Colors.grey.shade200 : (n < 3 ? Colors.green.shade300 : (n < 7 ? Colors.green.shade500 : Colors.green.shade800));
              return Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                alignment: Alignment.center,
                child: Text('$n', style: const TextStyle(fontSize: 11, color: Colors.white)),
              );
            }).toList(),
          ),
          const Text(' (خلال 35 يوماً — كل مربع يوم)', style: TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 16),
          Text('مُحقَّق (${unlocked.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ...unlocked.map((a) => ListTile(leading: const Icon(Icons.emoji_events, color: Colors.amber), title: Text(a.title), subtitle: Text(a.description))),
          const Divider(),
          Text('قادم (${locked.length})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ...locked.map((a) => ListTile(leading: const Icon(Icons.lock_outline, color: Colors.grey), title: Text(a.title), subtitle: Text(a.description))),
        ],
      ),
    );
  }
}
