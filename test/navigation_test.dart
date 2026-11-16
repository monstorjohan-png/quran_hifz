import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'package:quran_hifz/app.dart';

Future<void> _setupStorage() async {
  // محرك Hive للاختبارات (داخلياً)
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
    // Mock path_provider للتخزين المؤقت في الاختبارات
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => 'C:/Windows/Temp/quran_test_docs',
    );
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'onboarded': true});
    await _setupStorage();
  });

  testWidgets('App launches to Home without exceptions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranHifzApp()));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Launch crashed');
    // الرئيسية يجب أن تظهر
    expect(find.text('تحفيظ قرآن'), findsWidgets);
  });

  testWidgets('Navigate through tabs', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranHifzApp()));
    await tester.pump(const Duration(seconds: 1));

    // اضغط تبويب «قراءة» (BottomNavigationBar)
    await tester.tap(find.text('قراءة'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Reader tab crashed');

    // اضغط تبويب «صوت»
    await tester.tap(find.text('صوت'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Audio tab crashed');

    // اضغط تبويب «تسميع»
    await tester.tap(find.text('تسميع'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Tasmee tab crashed');

    // اضغط تبويب «تقدم»
    await tester.tap(find.text('تقدم'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Progress tab crashed');

    // اضغط تبويب «الرئيسية»
    await tester.tap(find.text('الرئيسية'));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull, reason: 'Home tab crashed');
  });
}
