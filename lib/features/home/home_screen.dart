import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/surahs.dart';
import '../core/theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('تحفيظ قرآن')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _heroCard(context),
          const SizedBox(height: 16),
          const Text('الطرق التفاعلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _methodChip(context, 'قراءة وتلاوة', Icons.menu_book, '/reader/1'),
              _methodChip(context, 'استماع للشيوخ', Icons.headphones, '/audio'),
              _methodChip(context, 'تسميع صوتي', Icons.mic, '/tasmee'),
              _methodChip(context, 'كتابة أثناء التسميع', Icons.edit, '/tasmee'),
              _methodChip(context, 'التقدم', Icons.bar_chart, '/progress'),
              _methodChip(context, 'الإعدادات', Icons.settings, '/settings'),
            ],
          ),
          const SizedBox(height: 24),
          const Text('السور', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...surahs.map((s) => Card(
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: AppTheme.primary, child: Text('${s.number}', style: const TextStyle(color: Colors.white, fontSize: 12))),
                  title: Text(s.nameAr),
                  subtitle: Text('${s.nameEn} • ${s.ayahCount} آية'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => context.go('/reader/${s.number}'),
                ),
              )),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF2E7D32)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('بسم الله الرحمن الرحيم', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('احفظ كتاب الله بطرق تفاعلية، صوت شيوخ، تسميع صوتي وكتابة — يعمل بدون نت.',
                style: TextStyle(color: Colors.white70)),
          ],
        ),
      );

  Widget _methodChip(BuildContext context, String label, IconData icon, String route) => ActionChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: () => context.go(route),
      );
}
