import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/audio/audio_screen.dart';
import 'features/recitation/tasmee_screen.dart';
import 'features/progress/progress_screen.dart';
import 'features/settings/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/reader/:surah', builder: (_, s) => ReaderScreen(surah: int.parse(s.pathParameters['surah']!))),
    GoRoute(path: '/audio', builder: (_, __) => const AudioScreen()),
    GoRoute(path: '/tasmee', builder: (_, __) => const TasmeeScreen()),
    GoRoute(path: '/progress', builder: (_, __) => const ProgressScreen()),
    GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
  ],
);

class QuranHifzApp extends StatelessWidget {
  const QuranHifzApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'تحفيظ قرآن',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      localizationsDelegates: const [],
      supportedLocales: const [Locale('ar'), Locale('en')],
    );
  }
}
