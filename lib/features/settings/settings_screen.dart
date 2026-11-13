import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.read(storageServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            value: false,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text('سرعة التشغيل'),
            subtitle: Text(storage.playbackSpeed.toStringAsFixed(2)),
          ),
          const ListTile(
            title: Text('تنزيل نموذج Whisper (أوفلاين)'),
            subtitle: Text('ggml-base.bin ~142MB — ضعه في assets/models/'),
          ),
          const ListTile(
            title: Text('تنزيل تلاوات (أوفلاين)'),
            subtitle: Text('استخدم islamicaudio أو quranicaudio CDN'),
          ),
        ],
      ),
    );
  }
}
