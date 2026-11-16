class Reciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String style;
  final String folder; // everyayah.com folder
  const Reciter({required this.id, required this.nameAr, required this.nameEn, required this.style, required this.folder});

  String get baseUrl => 'https://everyayah.com/data/$folder';

  static const List<Reciter> famous = [
    Reciter(id: 'alafasy', nameAr: 'مشاري العفاسي', nameEn: 'Mishary Alafasy', style: 'murattal', folder: 'Alafasy_128kbps'),
    Reciter(id: 'husary', nameAr: 'محمود خليل الحصري', nameEn: 'Mahmoud Khalil Al-Husary', style: 'murattal', folder: 'Husary_128kbps'),
    Reciter(id: 'minshawi', nameAr: 'محمد صديق المنشاوي', nameEn: 'Muhammad Siddiq Al-Minshawi', style: 'murattal', folder: 'Minshawi_Murattal_128kbps'),
    Reciter(id: 'abdulbasit', nameAr: 'عبد الباسط عبد الصمد', nameEn: 'Abdul Basit', style: 'mujawwad', folder: 'Abdul_Basit_Murattal_192kbps'),
    Reciter(id: 'sudais', nameAr: 'عبد الرحمن السديس', nameEn: 'Abdul Rahman Al-Sudais', style: 'murattal', folder: 'Sudais_128kbps'),
    Reciter(id: 'ghamdi', nameAr: 'سعد الغامدي', nameEn: 'Saad Al-Ghamdi', style: 'murattal', folder: 'Ghamadi_40kbps'),
  ];
}
