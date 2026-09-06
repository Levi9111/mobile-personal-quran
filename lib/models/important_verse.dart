class ImportantVerse {
  final int id;
  final String title;
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final String verseKey;
  final String textIndopak;
  final String translation;
  final String category;
  final List<String> occasions;
  final String significance;
  final String blessings;
  final String reference;
  final String? audioUrl;

  const ImportantVerse({
    required this.id,
    required this.title,
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.verseKey,
    required this.textIndopak,
    required this.translation,
    required this.category,
    required this.occasions,
    required this.significance,
    required this.blessings,
    required this.reference,
    this.audioUrl,
  });

  factory ImportantVerse.fromJson(Map<String, dynamic> json) {
    return ImportantVerse(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      surahNumber: json['surahNumber'] as int,
      surahName: json['surahName'] as String? ?? '',
      verseNumber: json['verseNumber'] as int,
      verseKey: json['verseKey'] as String? ?? '',
      textIndopak: json['textIndopak'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      category: json['category'] as String? ?? '',
      occasions: (json['occasions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      significance: json['significance'] as String? ?? '',
      blessings: json['blessings'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      audioUrl: json['audioUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'surahNumber': surahNumber,
      'surahName': surahName,
      'verseNumber': verseNumber,
      'verseKey': verseKey,
      'textIndopak': textIndopak,
      'translation': translation,
      'category': category,
      'occasions': occasions,
      'significance': significance,
      'blessings': blessings,
      'reference': reference,
      'audioUrl': audioUrl,
    };
  }

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        surahName.toLowerCase().contains(q) ||
        verseKey.toLowerCase().contains(q) ||
        translation.toLowerCase().contains(q) ||
        category.toLowerCase().contains(q) ||
        significance.toLowerCase().contains(q) ||
        blessings.toLowerCase().contains(q) ||
        reference.toLowerCase().contains(q) ||
        occasions.any((occ) => occ.toLowerCase().contains(q));
  }
}
