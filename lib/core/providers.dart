import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/audio_service.dart';
import '../services/storage_service.dart';
import '../services/stt_service.dart';
import '../data/repositories/quran_repository.dart';

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = AudioService();
  s.init();
  ref.onDispose(s.dispose);
  return s;
});

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final quranRepositoryProvider = Provider<QuranRepository>((ref) => QuranRepository());

final sttServiceProvider = Provider<SttService>((ref) => MockSttService());
