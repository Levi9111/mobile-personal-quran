class Verse {
  final int id;
  final int verseNumber;
  final String verseKey;
  final String textIndopak;
  final String translationText;
  final String? audioUrl;

  String get verse_key => verseKey;

  Verse({
    required this.id,
    required this.verseNumber,
    required this.verseKey,
    required this.textIndopak,
    required this.translationText,
    this.audioUrl,
  });

  factory Verse.fromJson(Map<String, dynamic> json) {
    final translationsList = json['translations'] as List<dynamic>?;
    final translation = (translationsList != null && translationsList.isNotEmpty)
        ? (translationsList.first as Map<String, dynamic>)['text'] as String? ?? ''
        : '';
    final audioObj = json['audio'] as Map<String, dynamic>?;
    final audioUrl = audioObj?['url'] as String?;

    return Verse(
      id: json['id'] as int,
      verseNumber: json['verse_number'] as int? ?? 0,
      verseKey: json['verse_key'] as String? ?? '',
      textIndopak: json['text_indopak'] as String? ?? '',
      translationText: translation,
      audioUrl: audioUrl,
    );
  }
}
