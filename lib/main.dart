import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Offline-first local storage (Hive)
  await Hive.initFlutter();
  await Hive.openBox('progress');
  await Hive.openBox('settings');
  await Hive.openBox('tasmee');

  runApp(const ProviderScope(child: QuranHifzApp()));
}
