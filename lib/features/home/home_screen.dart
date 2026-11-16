import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/surahs.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = surahs
        .where((s) => s.nameAr.contains(_query) || s.number.toString() == _query)
        .toList();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('تحفيظ قرآن', style: TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppTheme.primary, Color(0xFF2E7D32)]),
                ),
                child: const Center(
                  child: Text('بسم الله الرحمن الرحيم',
                      style: TextStyle(color: Colors.white70, fontSize: 18)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث عن سورة...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _actionCard(context, 'قراءة', Icons.menu_book, Colors.green, () => context.go('/reader/1')),
                  _actionCard(context, 'صوت', Icons.headphones, Colors.blue, () => context.go('/audio')),
                  _actionCard(context, 'تسميع', Icons.mic, Colors.orange, () => context.go('/tasmee')),
                  _actionCard(context, 'تقدم', Icons.bar_chart, Colors.purple, () => context.go('/progress')),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(12),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.6,
              ),
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final s = filtered[i];
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.go('/reader/${s.number}'),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppTheme.primary,
                              child: Text('${s.number}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(s.nameAr, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 40) / 2,
      child: Card(
        color: color.withOpacity(0.1),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
