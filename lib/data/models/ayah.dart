class Ayah {
  final int surah;
  final int number;
  final String text;
  final String textSimple;
  const Ayah({required this.surah, required this.number, required this.text, required this.textSimple});

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'number': number,
        'text': text,
        'textSimple': textSimple,
      };

  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(
        surah: j['surah'],
        number: j['number'],
        text: j['text'],
        textSimple: j['textSimple'],
      );
}
