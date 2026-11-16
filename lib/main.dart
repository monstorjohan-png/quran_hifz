import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first local storage (Hive)
  await Hive.initFlutter();
  await Hive.openBox('progress');
  await Hive.openBox('settings');
  await Hive.openBox('tasmee');

  // إشعارات المراجعة اليومية (أوفلاين)
  final notif = NotificationService();
  await notif.init();
  await notif.scheduleDailyReview(hour: 8, minute: 0);

  runApp(const ProviderScope(child: QuranHifzApp()));
}
