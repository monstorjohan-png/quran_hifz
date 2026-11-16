# 📋 التطبيق المثالي لحفظ القرآن بدون نت — كشف شامل + اقتراحات

## ✅ ما تم (مُنجز)
- Flutter 3.47, Riverpod, GoRouter, Hive
- 114 سورة (كل القرآن)
- تلاوات (everyayah.com): العفاسي، الحصري، المنشاوي، عبد الباسط، السديس، الغامدي
- STT (speech_to_text — يعمل لو كان حزمة اللغة مثبتة)
- BottomNav (5 تبويبات) + Onboarding تعليمى
- تخزين محلي (Hive) + EncryptedSharedPreferences
- ProGuard + allowBackup=false + Network Security Config

## 🔴 العيوب الحالية (فعلية)
1. **Audio يتطلب نت** (everyayah بث) — ليس أوفلاين.
2. **STT يتطلب حزمة لغة مثبتة** — ليس 100% أوفلاين.
3. **لا Word-level highlighting** (تلوين كلمة أثناء التلاوة).
4. **لا Spaced Repetition** (مراجعة ذكية).
5. **لا Offline audio download manager**.
6. **لا Tajweed coloring**.
7. **لا Notifications** (WorkManager) للمراجعة.
8. **لا Backup/Restore** (تصدير/استيراد التقدم).
9. **لا Streak/heatmap** (تحفيز).
10. **لا Tests / CI**.
11. **Release signing = debug key**.
12. **الـ logo بسيط** (يمكن تحسينه).

## 🗺 اقتراحات شاملة (لكل تفصيل)

### 1. 📖 المحتوى
- حزمة كاملة: 6236 آية + تفسير (مختصر) + تجويد + أذكار.
- **KFGQPC Uthmanic Script** (الأصل) أو **Amiri Quran** (خط OTF مثبت).
- **تفسير تفاعل**: اضغط كلمة → تفسير (عربي/إنجليزي).
- **Tajweed coloring** (إقلاب/إدغام/قلقلة) بألوان.
- **Page-by-page** (604 صفحة) + ترتيب الحافظ (ختمه).

### 2. 🎧 الصوت
- **Offline audio manager**:
  - Download per-surah/every ayah (progress bar, pause/resume).
  - Audio quality tiers (32/64/128 kbps).
- **Word-level highlighting** (everyayah has word timings? Actually audio timing per ayah. For word-level, use qiraat timing or forced alignment).
- **Playback**: loop, repeat ayah N times, speed 0.25x–2x, background play (audio_service).
- **Offline-first**: يفضّل ملف محلي على CDN.

### 3. 🎤 التسميع (STT)
- **Whisper.cpp** (منصة Android، نموذج `ggml-small.bin` ~466MB) — أوفلاين 100%، دقة عالية عربي.
- **Alternative**: Android SpeechRecognizer (يكتب ما تقول) — يعمل لو اللغة مثبتة.
- **تظليل الكلمات الخاطئة** (diff view) — أحمر/أخضر.
- **درجات**: حفظ درجات كل محاولة + graphs.
- **صوت المعلم** (TTS) ينطق الصحيح عند الخطأ.

### 4. 📊 التقدم والتحفيز
- **Spaced Repetition** (SM-2): آيات حفظت ← مراجعة يومية/أسبوعية/شهرية.
- **Streak** (أيام متتالية) + badges (افتتاح، ختم 1/2، إلخ).
- **Heatmap** (كالـ GitHub) — أيام الحفظ.
- **لوحة "آيات اليوم"**: تمرين + مراجعة.
- **إشعارات**: WorkManager (مراجعة كل يوم 8 صباحاً).

### 5. 🎨 التصميم (بسيط + تفاعلي)
- **Dark/Light** تلقائي.
- **بطء العناصر**: card كبيرة، 1 إجراء لكل شاشة.
- **تحسين UI**:
  - Home: 4 بطاقات (قراءة/صوت/تسميع/تقدم) + "السورة اليوم".
  - Reader: آية كبيرة (size 26+) + رقم آية كبير + أدوات (تشغيل/تمييز/بحث).
  - Tasmee: حلقة تسجيل كبيرة + diff view.
- **Animations**: page transition, progress bar
- **Typography**: Amiri (قراءة) + Inter (واجهة).

### 6. 🧠 طرق التعلم التفاعلية
- **3×3**: 3 آيات × 3 تكرارات.
- **آخر سورة**: اختبار (ملء فراغ، اختيار).
- **Chain**: حفظ متتابع (آية من السورة السابقة + الجديدة).
- **Listen → Repeat**: شغّل آية → كررها → سجل.
- **Write along**: اكتب الآية من الذاكرة → قارن.

### 7. 🔐 الأمان
- **Encrypted storage** (flutter_secure_storage) للبيانات الشخصية.
- **No tracking** (لا Firebase Analytics افتراضي).
- **Backup/Restore** (تصدير JSON → Drive/ملف).
- **Free from malware**: بناء من المصدر (GitHub) + مراجعة الكود.
- **ProGuard + obfuscation** (release).

### 8. 📱 Android Specific
- **WorkManager** للمراجعة (حتى لو التطبيق مغلق).
- **Audio focus** (يقطع عند اتصال).
- **Foreground service** للتلاوة الخلفية.
- **App Widget** سريع (ابدأ مراجعة "اليوم").
- **Shortcuts** (long-press على أيقونة → "تسميع الآن").
- **Adaptive icon + splash**.
- **Biometric** اختياري (قفل التطبيق).

### 9. 🧰 تقنيات
- **Flutter + Rust** (whisper bindings) أو whisper.cpp FFI.
- **SQLite** (sqflite) للترتيب الكبير.
- **Hive** للـ cache + تقدم.
- **Background audio** (just_audio_background).
- **CI** (GitHub Actions): test + build apk on push.

### 10. 🧪 الجودة
- **Unit tests**: storage, SM-2, accuracy.
- **Widget tests**: reader, tasmee, home.
- **Integration**: voice → text flow (mock).
- **Lint** (flutter_lints + custom rules).
- **Crash reporting** (Sentry اختياري).

### 11. 📦 النشر
- **Release keystore** + `flutter build apk --release`.
- **Play Store** (اختياري): app bundle.
- **README** + LICENSE (MIT/CC0 للقرآن).
- **Versioning** (semver).

## 🎯 ترتيب التنفيذ (Roadmap)
| المرحلة | المدة | الهدف |
|---|---|---|
| v0.1 | done | MVP + APK |
| v0.2 | 1 أسبوع | Offline audio manager + Whisper STT |
| v0.3 | 1 أسبوع | Spaced Repetition + Notifications |
| v0.4 | 1 أسبوع | Tajweed coloring + Word highlighting |
| v0.5 | 1 أسبوع | Tests + CI + Release |
| v1.0 | — | نشر Play Store |

## 💡 نصائح
1. **ابدأ بسيرة صغيرة** (الفاتحة + قصار السور) أولاً.
2. **حفظ بصوت عالي** (قاعل) — أفضل للذاكرة.
3. **Daily review** — 10 دقائق يومياً > 1 ساعة أسبوعياً.
4. **لا تحفظ أكثر من 4 آيات/يوم**.
