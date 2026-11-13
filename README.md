# تحفيظ قرآن — Quran Hifz (Flutter)

تطبيق Android (Flutter) لحفظ القرآن بطرق تعلم تفاعلية، مع تلاوات شيوخ، تسميع صوتي + كتابة، يعمل **بدون نت**.

## الميزات
- قراءة Quran (أوفلاين عبر حزمة `quran`)
- تلاوات شيوخ عظماء (العفاسي، الحصري، المنشاوي، عبد الباسط، السديس، الغامدي)
- طرق تعلم: استماع متكرر، تجزئة، تكرار متباعد (Spaced Repetition)، كتابة أثناء التسميع، تسميع صوتي، تجويد
- تسميع (STT) بدون نت عبر Whisper.cpp (عربي)
- كتابة الكلام أثناء التسميع + حساب دقة
- تتبع تقدم (Hive) + مراجعة يومية/أسبوعية/شهرية
- إعدادات: قارئ، سرعة تشغيل، تنزيل نماذج/تلاوات

## الإعداد (على جهازك)
1. ثبّت Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. `cd quran_hifz`
3. `flutter pub get`
4. (اختياري) تنزيل نموذج Whisper base: ضع `ggml-base.bin` في `assets/models/`
5. `flutter run` (Android device/emulator)

## تكامل Whisper.cpp (STT أوفلاين)
- استخدم `whisper_ggml` (pub.dev) أو platform channel.
- استبدل `MockSttService` بـ `WhisperSttService` في `lib/core/providers.dart`.
- نموذج عربي: `ggml-base.bin` (~142MB) أو `ggml-small.bin`.

## تلاوات أوفلاين
- استخدم CDN (islamic.network) للبث، أو نزّل MP3s إلى `assets/audio/` وحدّث `AudioService.playAyah`.

## GitHub
- هذا المشروع مهيأ لرفعه على GitHub (انظر `.gitignore`).
- `git init && git add . && git commit -m "init" && gh repo create quran_hifz --public --source=. --push`

## الطرق التفاعلية (اقتراحات مستقبلية)
- 3x3 (3 آيات × 3 تكرارات)
- تظليل آية أثناء التلاوة (word-level timing)
- اختبارات (اختيار الإكمال، ترتيب آيات)
- إشعارات مراجعة (WorkManager)
- تزامن cloud (Firebase) اختياري
- Tajweed coloring + qalqalah rules
- أصوات أطفال/نساء للتعلم
- وضع "الحفظ مع صديق" (مشاركة تقدم)

## البنية
```
lib/
  main.dart, app.dart
  core/ (theme, constants, providers)
  data/ (models, repositories)
  features/ (home, reader, audio, recitation, progress, settings)
  services/ (audio, stt, storage)
```
