import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/tajweed.dart';
import '../theme/app_theme.dart';
import '../widgets/tajweed_text.dart';

class TajweedGuideScreen extends StatelessWidget {
  const TajweedGuideScreen({super.key});

  static const List<Map<String, dynamic>> lessons = [
    {
      "rule": TajweedRule.ghunna,
      "arabic": "الغُنَّة",
      "meaning": "Nasalisation",
      "how": "Hold a nasal hum through the nose for about two counts. The sound lives in the nose, not the mouth — pinch your nose and the sound should stop.",
      "letters": "نّ  ·  مّ",
      "conditions": [
        "Applies whenever a noon (ن) or meem (م) carries a shadda ( ّ ).",
        "This is the strongest and most obligatory ghunna — always two full counts.",
      ],
      "examples": [
        {"text": "اِنَّ", "note": "Noon with shadda — hum for two counts."},
        {"text": "ثُمَّ", "note": "Meem with shadda — nasal hold on lips."}
      ]
    },
    {
      "rule": TajweedRule.qalqalah,
      "arabic": "القَلْقَلَة",
      "meaning": "Echo / bounce",
      "how": "Bounce the letter off its articulation point so it ends with a light echo, without adding a vowel. Say a crisp 'd' as in 'ad-' and let it rebound.",
      "letters": "قُطْبُ جَدٍّ  ·  ق ط ب ج د",
      "conditions": [
        "The letter must carry a sukūn ( ْ ) in the middle of a word.",
        "Also applies when stopping on one of these letters at the end of an ayah.",
      ],
      "examples": [
        {"text": "يَدْخُلُوۡنَ", "note": "Dāl with sukūn inside the word — light bounce."},
        {"text": "اَحَدْ", "note": "Stopping on dāl at the end of ayah — stronger bounce."}
      ]
    },
    {
      "rule": TajweedRule.madd,
      "arabic": "المَدّ",
      "meaning": "Elongation",
      "how": "Stretch the vowel well beyond its natural length — four to six counts, kept steady and even. Do not waver in pitch while holding it.",
      "letters": "ا  ·  و  ·  ي",
      "conditions": [
        "Marked by the maddah sign ( ٓ ) above a madd letter.",
        "Madd wājib / jāʾiz: hold 4 to 5 counts.",
        "Madd lāzim: followed by sukūn or shadda — full 6 counts.",
      ],
      "examples": [
        {"text": "جَآءَ", "note": "Alif with maddah followed by hamzah."},
        {"text": "وَلَا الضَّآلِّيۡنَ", "note": "Followed by shadda, hold full 6 counts."}
      ]
    },
    {
      "rule": TajweedRule.idgham,
      "arabic": "الإدْغَام",
      "meaning": "Merging",
      "how": "Drop the noon sound entirely and merge it into the next letter, doubling that letter as though it carried a shadda.",
      "letters": "يَرْمَلُوْن  ·  ي ر م ل و ن",
      "conditions": [
        "Applies to noon sākin (نْ) or tanwīn followed by one of the six letters.",
        "With ghunna (ي ن م و): merge and hum for two counts.",
        "Without ghunna (ل ر): merge cleanly with no nasal sound.",
      ],
      "examples": [
        {"text": "مَنۡ يَّقُوۡلُ", "note": "Noon sākin before yāʾ — merge & hum 2 counts."},
        {"text": "مِنۡ رَّبِّهِمۡ", "note": "Noon sākin before rāʾ — merge cleanly."}
      ]
    },
    {
      "rule": TajweedRule.ikhfa,
      "arabic": "الإخْفَاء",
      "meaning": "Hiding",
      "how": "Neither pronounce the noon clearly nor merge it away. Hold the tongue short of the next letter's position and let sound pass through nose.",
      "letters": "ت ث ج د ذ ز س ش ص ض ط ظ ف ق ك",
      "conditions": [
        "Applies to noon sākin or tanwīn before any of the 15 ikhfāʾ letters.",
        "Tongue prepares for the next letter while noon is nasalised.",
      ],
      "examples": [
        {"text": "اَنۡتَ", "note": "Noon hidden & nasalised before tāʾ."},
        {"text": "مِنۡ قَبۡلُ", "note": "Nasal hum held 2 counts before qāf."}
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tajweed Colour Guide',
          style: GoogleFonts.cormorantGaramond(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              'LEARN TO RECITE',
              style: GoogleFonts.karla(
                fontSize: 11,
                letterSpacing: 3,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '5 Tajweed Colour Rules',
              style: GoogleFonts.cormorantGaramond(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Every coloured letter in the reader maps to a tajweed rule family.',
              textAlign: TextAlign.center,
              style: GoogleFonts.karla(
                fontSize: 13,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),

            ...lessons.map((lesson) {
              final rule = lesson["rule"] as TajweedRule;
              final meta = ruleMetaMap[rule]!;
              final conditions = lesson["conditions"] as List<String>;
              final examples = lesson["examples"] as List<Map<String, String>>;

              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.outline, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meta.label,
                              style: GoogleFonts.cormorantGaramond(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: meta.color,
                              ),
                            ),
                            Text(
                              (lesson["meaning"] as String).toUpperCase(),
                              style: GoogleFonts.karla(
                                fontSize: 10,
                                letterSpacing: 1.5,
                                color: theme.colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          lesson["arabic"] as String,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: 30,
                            color: theme.colorScheme.onSurface.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      lesson["how"] as String,
                      style: GoogleFonts.karla(fontSize: 13, height: 1.5),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: meta.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: meta.color.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LETTERS',
                            style: GoogleFonts.karla(
                              fontSize: 9,
                              letterSpacing: 1.5,
                              color: meta.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            lesson["letters"] as String,
                            style: GoogleFonts.scheherazadeNew(
                              fontSize: 22,
                              color: meta.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...conditions.map((cond) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6, right: 8),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: meta.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  cond,
                                  style: GoogleFonts.karla(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 14),
                    Text(
                      'EXAMPLES',
                      style: GoogleFonts.karla(
                        fontSize: 10,
                        letterSpacing: 1.5,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: examples.map((ex) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.colorScheme.outline),
                            ),
                            child: Column(
                              children: [
                                TajweedTextWidget(
                                  text: ex["text"]!,
                                  fontSize: 24,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ex["note"]!,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.karla(
                                    fontSize: 11,
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
