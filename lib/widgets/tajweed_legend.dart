import 'package:flutter/material.dart';
import '../models/tajweed.dart';

class TajweedLegendWidget extends StatelessWidget {
  const TajweedLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: TajweedRule.values.map((rule) {
          final meta = ruleMetaMap[rule]!;
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: meta.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: meta.color.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: meta.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  meta.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: meta.color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
