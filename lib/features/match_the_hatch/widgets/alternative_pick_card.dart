import 'package:flutter/material.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/models/hatch_recommendation.dart';
import '../../../core/utils/constants.dart';

class AlternativePickCard extends StatelessWidget {
  final HatchBaitPick pick;
  final int index;

  const AlternativePickCard({
    super.key,
    required this.pick,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '#${index + 2}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.teal,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(pick.baitCategory.icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        pick.baitCategory.displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${(pick.confidence * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${pick.baitSize} \u2022 ${pick.colorName} \u2022 ${pick.jigWeight}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${pick.speed.displayName} \u2022 ${pick.depthRange}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
