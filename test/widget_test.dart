import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_hifz/app.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('QuranHifzApp launches without exceptions (smoke)', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuranHifzApp()));
    await tester.pump(const Duration(milliseconds: 500));
    // لا توجد استثناءات أثناء الإقلاع
    expect(tester.takeException(), isNull);
    // تظهر شاشة الترحيب (أول صفحة في onboarding)
    expect(find.text('بسم الله'), findsOneWidget);
  });
}
