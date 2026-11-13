import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    isOnboarded().then((v) {
      if (v && mounted) context.go('/');
    });
  }

  final _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    ('بسم الله', 'تطبيقك لحفظ كتاب الله بطرق تفاعلية'),
    ('اقرأ + استمع', 'تلاوات شيوخ عظماء (العفاسي، الحصري، المنشاوي...)'),
    ('سمّع', 'تسميع صوتي + كتابة — يعمل بدون نت (Whisper)'),
    ('تتبع', 'Spaced Repetition + خريطة حرارة + streak'),
    ('ابدأ', 'اختر سورة وابدأ حفظك'),
  ];

  Future<void> _finish() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('onboarded', true);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book, size: 96, color: Colors.green),
                      const SizedBox(height: 24),
                      Text(_pages[i].$1, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(_pages[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) => Container(
                margin: const EdgeInsets.all(4),
                width: _page == i ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _page == i ? Colors.green : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _page == _pages.length - 1 ? _finish : () => _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                  child: Text(_page == _pages.length - 1 ? 'ابدأ' : 'التالي'),
                ),
              ),
            ),
            TextButton(onPressed: _finish, child: const Text('تخطي')),
          ],
        ),
      ),
    );
  }
}

Future<bool> isOnboarded() async {
  final sp = await SharedPreferences.getInstance();
  return sp.getBool('onboarded') ?? false;
}
