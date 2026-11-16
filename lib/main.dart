import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Show errors instead of a blank white screen
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('FlutterError: ${details.exception}');
  };
  ErrorWidget.builder = (details) => Scaffold(
        backgroundColor: Colors.red.shade50,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'حدث خطأ:\n${details.exception}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

  // Offline-first local storage (Hive)
  try {
    await Hive.initFlutter();
    await Hive.openBox('progress');
    await Hive.openBox('settings');
    await Hive.openBox('tasmee');
  } catch (e) {
    debugPrint('Hive init failed: $e');
  }

  // Daily review notification (best-effort — don't crash app if it fails)
  try {
    final notif = NotificationService();
    await notif.init();
    await notif.scheduleDailyReview(hour: 8, minute: 0);
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  runApp(const ProviderScope(child: QuranHifzApp()));
}
