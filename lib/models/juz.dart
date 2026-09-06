/// Information representing one of the 30 Juz (Para) in the Holy Quran.
class JuzInfo {
  final int juzNumber;
  final String nameArabic;
  final String nameTransliteration;
  final int startSurahId;
  final String startSurahName;
  final int startVerseNumber;
  final int endSurahId;
  final String endSurahName;
  final int endVerseNumber;

  const JuzInfo({
    required this.juzNumber,
    required this.nameArabic,
    required this.nameTransliteration,
    required this.startSurahId,
    required this.startSurahName,
    required this.startVerseNumber,
    required this.endSurahId,
    required this.endSurahName,
    required this.endVerseNumber,
  });

  String get rangeDescription =>
      '$startSurahName $startSurahId:$startVerseNumber – $endSurahName $endSurahId:$endVerseNumber';

  static final List<JuzInfo> all30Juz = [
    const JuzInfo(juzNumber: 1, nameArabic: 'آلم', nameTransliteration: 'Alif Lam Meem', startSurahId: 1, startSurahName: 'Al-Fatihah', startVerseNumber: 1, endSurahId: 2, endSurahName: 'Al-Baqarah', endVerseNumber: 141),
    const JuzInfo(juzNumber: 2, nameArabic: 'سَيَقُولُ', nameTransliteration: 'Sayaqulu', startSurahId: 2, startSurahName: 'Al-Baqarah', startVerseNumber: 142, endSurahId: 2, endSurahName: 'Al-Baqarah', endVerseNumber: 252),
    const JuzInfo(juzNumber: 3, nameArabic: 'تِلْكَ الرُّسُلُ', nameTransliteration: 'Tilkar Rusul', startSurahId: 2, startSurahName: 'Al-Baqarah', startVerseNumber: 253, endSurahId: 3, endSurahName: 'Ali \'Imran', endVerseNumber: 92),
    const JuzInfo(juzNumber: 4, nameArabic: 'لَنْ تَنَالُوا', nameTransliteration: 'Lan Tanalu', startSurahId: 3, startSurahName: 'Ali \'Imran', startVerseNumber: 93, endSurahId: 4, endSurahName: 'An-Nisa', endVerseNumber: 23),
    const JuzInfo(juzNumber: 5, nameArabic: 'وَالْمُحْصَنَاتُ', nameTransliteration: 'Wal Muhsanat', startSurahId: 4, startSurahName: 'An-Nisa', startVerseNumber: 24, endSurahId: 4, endSurahName: 'An-Nisa', endVerseNumber: 147),
    const JuzInfo(juzNumber: 6, nameArabic: 'لَا يُحِبُّ اللهُ', nameTransliteration: 'La Yuhibbullah', startSurahId: 4, startSurahName: 'An-Nisa', startVerseNumber: 148, endSurahId: 5, endSurahName: 'Al-Ma\'idah', endVerseNumber: 81),
    const JuzInfo(juzNumber: 7, nameArabic: 'وَإِذَا سَمِعُوا', nameTransliteration: 'Wa Iza Sami\'u', startSurahId: 5, startSurahName: 'Al-Ma\'idah', startVerseNumber: 82, endSurahId: 6, endSurahName: 'Al-An\'am', endVerseNumber: 110),
    const JuzInfo(juzNumber: 8, nameArabic: 'وَلَوْ أَنَّنَا', nameTransliteration: 'Wa Law Annana', startSurahId: 6, startSurahName: 'Al-An\'am', startVerseNumber: 111, endSurahId: 7, endSurahName: 'Al-A\'raf', endVerseNumber: 87),
    const JuzInfo(juzNumber: 9, nameArabic: 'قَالَ الْمَلَأُ', nameTransliteration: 'Qalal Mala\'u', startSurahId: 7, startSurahName: 'Al-A\'raf', startVerseNumber: 88, endSurahId: 8, endSurahName: 'Al-Anfal', endVerseNumber: 40),
    const JuzInfo(juzNumber: 10, nameArabic: 'وَاعْلَمُوا', nameTransliteration: 'Wa\'lamu', startSurahId: 8, startSurahName: 'Al-Anfal', startVerseNumber: 41, endSurahId: 9, endSurahName: 'At-Tawbah', endVerseNumber: 92),
    const JuzInfo(juzNumber: 11, nameArabic: 'يَعْتَذِرُونَ', nameTransliteration: 'Ya\'taziroon', startSurahId: 9, startSurahName: 'At-Tawbah', startVerseNumber: 93, endSurahId: 11, endSurahName: 'Hud', endVerseNumber: 5),
    const JuzInfo(juzNumber: 12, nameArabic: 'وَمَا مِنْ دَابَّةٍ', nameTransliteration: 'Wa Mamin Dabbah', startSurahId: 11, startSurahName: 'Hud', startVerseNumber: 6, endSurahId: 12, endSurahName: 'Yusuf', endVerseNumber: 52),
    const JuzInfo(juzNumber: 13, nameArabic: 'وَمَا أُبَرِّئُ', nameTransliteration: 'Wa Ma Ubarri\'u', startSurahId: 12, startSurahName: 'Yusuf', startVerseNumber: 53, endSurahId: 14, endSurahName: 'Ibrahim', endVerseNumber: 52),
    const JuzInfo(juzNumber: 14, nameArabic: 'رُبَمَا', nameTransliteration: 'Rubama', startSurahId: 15, startSurahName: 'Al-Hijr', startVerseNumber: 1, endSurahId: 16, endSurahName: 'An-Nahl', endVerseNumber: 128),
    const JuzInfo(juzNumber: 15, nameArabic: 'سُبْحَانَ الَّذِي', nameTransliteration: 'Subhanallazi', startSurahId: 17, startSurahName: 'Al-Isra', startVerseNumber: 1, endSurahId: 18, endSurahName: 'Al-Kahf', endVerseNumber: 74),
    const JuzInfo(juzNumber: 16, nameArabic: 'قَالَ أَلَمْ', nameTransliteration: 'Qala Alam', startSurahId: 18, startSurahName: 'Al-Kahf', startVerseNumber: 75, endSurahId: 20, endSurahName: 'Taha', endVerseNumber: 135),
    const JuzInfo(juzNumber: 17, nameArabic: 'اقْتَرَبَ', nameTransliteration: 'Iqtaraba', startSurahId: 21, startSurahName: 'Al-Anbiya', startVerseNumber: 1, endSurahId: 22, endSurahName: 'Al-Hajj', endVerseNumber: 78),
    const JuzInfo(juzNumber: 18, nameArabic: 'قَدْ أَفْلَحَ', nameTransliteration: 'Qad Aflaha', startSurahId: 23, startSurahName: 'Al-Mu\'minun', startVerseNumber: 1, endSurahId: 25, endSurahName: 'Al-Furqan', endVerseNumber: 20),
    const JuzInfo(juzNumber: 19, nameArabic: 'وَقَالَ الَّذِينَ', nameTransliteration: 'Wa Qalal Lazina', startSurahId: 25, startSurahName: 'Al-Furqan', startVerseNumber: 21, endSurahId: 27, endSurahName: 'An-Naml', endVerseNumber: 55),
    const JuzInfo(juzNumber: 20, nameArabic: 'أَمَّنْ خَلَقَ', nameTransliteration: 'Amman Khalaqa', startSurahId: 27, startSurahName: 'An-Naml', startVerseNumber: 56, endSurahId: 29, endSurahName: 'Al-\'Ankabut', endVerseNumber: 45),
    const JuzInfo(juzNumber: 21, nameArabic: 'اتْلُ مَا أُوحِيَ', nameTransliteration: 'Utlu Ma Oohiya', startSurahId: 29, startSurahName: 'Al-\'Ankabut', startVerseNumber: 46, endSurahId: 33, endSurahName: 'Al-Ahzab', endVerseNumber: 30),
    const JuzInfo(juzNumber: 22, nameArabic: 'وَمَنْ يَقْنُتْ', nameTransliteration: 'Wa Man Yaqnut', startSurahId: 33, startSurahName: 'Al-Ahzab', startVerseNumber: 31, endSurahId: 36, endSurahName: 'Yaseen', endVerseNumber: 27),
    const JuzInfo(juzNumber: 23, nameArabic: 'وَمَا لِيَ', nameTransliteration: 'Wa Maliya', startSurahId: 36, startSurahName: 'Yaseen', startVerseNumber: 28, endSurahId: 39, endSurahName: 'Az-Zumar', endVerseNumber: 31),
    const JuzInfo(juzNumber: 24, nameArabic: 'فَمَنْ أَظْلَمُ', nameTransliteration: 'Faman Azlamu', startSurahId: 39, startSurahName: 'Az-Zumar', startVerseNumber: 32, endSurahId: 41, endSurahName: 'Fussilat', endVerseNumber: 46),
    const JuzInfo(juzNumber: 25, nameArabic: 'إِلَيْهِ يُرَدُّ', nameTransliteration: 'Ilayhi Yuraddu', startSurahId: 41, startSurahName: 'Fussilat', startVerseNumber: 47, endSurahId: 45, endSurahName: 'Al-Jathiyah', endVerseNumber: 37),
    const JuzInfo(juzNumber: 26, nameArabic: 'حم', nameTransliteration: 'Ha Meem', startSurahId: 46, startSurahName: 'Al-Ahqaf', startVerseNumber: 1, endSurahId: 51, endSurahName: 'Adh-Dhariyat', endVerseNumber: 30),
    const JuzInfo(juzNumber: 27, nameArabic: 'قَالَ فَمَا خَطْبُكُمْ', nameTransliteration: 'Qala Fama Khatbukum', startSurahId: 51, startSurahName: 'Adh-Dhariyat', startVerseNumber: 31, endSurahId: 57, endSurahName: 'Al-Hadid', endVerseNumber: 29),
    const JuzInfo(juzNumber: 28, nameArabic: 'قَدْ سَمِعَ اللهُ', nameTransliteration: 'Qad Sami\'allah', startSurahId: 58, startSurahName: 'Al-Mujadila', startVerseNumber: 1, endSurahId: 66, endSurahName: 'At-Tahrim', endVerseNumber: 12),
    const JuzInfo(juzNumber: 29, nameArabic: 'تَبَارَكَ الَّذِي', nameTransliteration: 'Tabarakallazi', startSurahId: 67, startSurahName: 'Al-Mulk', startVerseNumber: 1, endSurahId: 77, endSurahName: 'Al-Mursalat', endVerseNumber: 50),
    const JuzInfo(juzNumber: 30, nameArabic: 'عَمَّ', nameTransliteration: 'Amma Yatasa\'aloon', startSurahId: 78, startSurahName: 'An-Naba', startVerseNumber: 1, endSurahId: 114, endSurahName: 'An-Nas', endVerseNumber: 6),
  ];
}
