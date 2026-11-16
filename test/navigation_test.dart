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

  testWidgets('App launches and navigates without exceptions', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranHifzApp()));
    await tester.pump(const Duration(seconds: 2));
    assert(tester.takeException() == null, 'Launch threw an exception');

    // انتقل بين التبويبات بالضغط على الأيقونات
    Future<void> tapIcon(IconData icon, String label) async {
      await tester.tap(find.byIcon(icon));
      await tester.pump(const Duration(seconds: 2));
      if (tester.takeException() != null) {
        fail('Navigation to $label threw: ${tester.takeException()}');
      }
    }

    await tapIcon(Icons.menu_book, 'قراءة');
    await tapIcon(Icons.headphones, 'صوت');
    await tapIcon(Icons.mic, 'تسميع');
    await tapIcon(Icons.bar_chart, 'تقدم');
    await tapIcon(Icons.home, 'الرئيسية');
  });
}
