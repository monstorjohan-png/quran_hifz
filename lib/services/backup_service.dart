import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// تصدير / استيراد التقدم (JSON) — للنسخ الاحتياطي
class BackupService {
  Future<String> export() async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'progress': Hive.box('progress').toMap(),
      'tasmee': Hive.box('tasmee').toMap(),
      'settings': Hive.box('settings').toMap(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<void> import(String json) async {
    final data = jsonDecode(json) as Map<String, dynamic>;
    if (data['progress'] is Map) {
      for (final e in (data['progress'] as Map).entries) {
        await Hive.box('progress').put(e.key, e.value);
      }
    }
    if (data['tasmee'] is Map) {
      for (final e in (data['tasmee'] as Map).entries) {
        await Hive.box('tasmee').put(e.key, e.value);
      }
    }
    if (data['settings'] is Map) {
      for (final e in (data['settings'] as Map).entries) {
        await Hive.box('settings').put(e.key, e.value);
      }
    }
  }
}
