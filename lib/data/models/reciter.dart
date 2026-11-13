class Reciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String style; // murattal / mujawwad
  final String baseUrl; // CDN base for audio files
  const Reciter({required this.id, required this.nameAr, required this.nameEn, required this.style, required this.baseUrl});

  /// famous reciters with soft/beautiful voices
  static const List<Reciter> famous = [
    Reciter(id: 'alafasy', nameAr: 'مشاري العفاسي', nameEn: 'Mishary Alafasy', style: 'murattal', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy'),
    Reciter(id: 'husary', nameAr: 'محمود خليل الحصري', nameEn: 'Mahmoud Khalil Al-Husary', style: 'murattal', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.husary'),
    Reciter(id: 'minshawi', nameAr: 'محمد صديق المنشاوي', nameEn: 'Muhammad Siddiq Al-Minshawi', style: 'murattal', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.minshawi'),
    Reciter(id: 'abdulbasit', nameAr: 'عبد الباسط عبد الصمد', nameEn: 'Abdul Basit', style: 'mujawwad', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal'),
    Reciter(id: 'sudais', nameAr: 'عبد الرحمن السديس', nameEn: 'Abdul Rahman Al-Sudais', style: 'murattal', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.abdurrahmaansudais'),
    Reciter(id: 'ghamdi', nameAr: 'سعد الغامدي', nameEn: 'Saad Al-Ghamdi', style: 'murattal', baseUrl: 'https://cdn.islamic.network/quran/audio/128/ar.saoodshuraym'),
  ];
}
