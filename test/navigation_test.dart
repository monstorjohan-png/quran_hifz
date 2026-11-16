import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:quran_hifz/app.dart';

Future<void> _setupStorage() async {
  await Hive.initFlutter();
  for (final name in ['progress', 'settings', 'tasmee']) {
    if (!Hive.isBoxOpen(name)) {
      await Hive.openBox(name);
    }
  }
}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => 'C:/Windows/Temp/quran_test_docs',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    await _setupStorage();
  });

  testWidgets('Diagnose launch screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranHifzApp()));
    await tester.pump(const Duration(seconds: 2));
    debugPrint('takeException: ${tester.takeException()}');
    debugPrint('has بسم الله: ${find.text('بسم الله').evaluate().isNotEmpty}');
    debugPrint('has تحفيظ قرآن: ${find.text('تحفيظ قرآن').evaluate().isNotEmpty}');
    debugPrint('has حدث خطأ: ${find.textContaining('حدث خطأ').evaluate().isNotEmpty}');
    // اطبع أول نصوص تظهر في الشجرة
    final texts = tester.widgetList(find.byType(Text)).map((w) => (w as Text).data).whereType<String>().toList();
    debugPrint('TEXTS: ${texts.take(20).join(' | ')}');
  });
}
