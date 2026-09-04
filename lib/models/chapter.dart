class Chapter {
  final int id;
  final String nameSimple;
  final String nameArabic;
  final int versesCount;
  final String revelationPlace;
  final String translatedName;

  Chapter({
    required this.id,
    required this.nameSimple,
    required this.nameArabic,
    required this.versesCount,
    required this.revelationPlace,
    required this.translatedName,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as int,
      nameSimple: json['name_simple'] as String? ?? '',
      nameArabic: json['name_arabic'] as String? ?? '',
      versesCount: json['verses_count'] as int? ?? 0,
      revelationPlace: json['revelation_place'] as String? ?? '',
      translatedName: (json['translated_name'] as Map<String, dynamic>?)?['name'] as String? ?? '',
    );
  }
}
