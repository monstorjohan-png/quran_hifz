import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../services/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _backup = BackupService();
  final _exportCtrl = TextEditingController();
  final _importCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        leading: BackButton(onPressed: () => context.go('/')),
      ),
      body: ListView(
        children: [
          const ListTile(title: Text('سرعة التشغيل'), subtitle: Text('اضبط من صفحة «صوت الشيوخ»')),
          const Divider(),
          const ListTile(title: Text('تصدير التقدم (JSON)')),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload),
                  label: const Text('توليد نسخة احتياطية'),
                  onPressed: () async {
                    final json = await _backup.export();
                    setState(() => _exportCtrl.text = json);
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم التصدير')));
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _exportCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'JSON الناتج...'),
                ),
              ],
            ),
          ),
          const Divider(),
          const ListTile(title: Text('استيراد التقدم (JSON)')),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _importCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'الصق JSON...'),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.download),
                  label: const Text('استيراد'),
                  onPressed: () async {
                    try {
                      await _backup.import(_importCtrl.text);
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الاستيراد')));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          const ListTile(title: Text('النسخة'), subtitle: Text('0.2.0 (offline-first)')),
          const ListTile(title: Text('الأمان'), subtitle: Text('Encrypted storage + Network Security Config + ProGuard')),
        ],
      ),
    );
  }
}
