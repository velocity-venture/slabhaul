import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// Card displaying contextual fishing tips based on water level conditions
class LevelFishingTips extends StatelessWidget {
  final List<String> tips;
  final bool expanded;

  const LevelFishingTips({
    super.key,
    required this.tips,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates,
                    color: AppColors.teal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fishing Tips',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Based on current water levels',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tips list
            ...tips.asMap().entries.map((entry) {
              final index = entry.key;
              final tip = entry.value;

              if (!expanded && index > 2) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < tips.length - 1 ? 12 : 0,
                ),
                child: _TipRow(tip: tip, index: index),
              );
            }),

            // "Show more" if collapsed and more tips available
            if (!expanded && tips.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${tips.length - 3} more tips...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.teal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String tip;
  final int index;

  const _TipRow({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) {
    // Extract emoji if present at start
    String? emoji;
    String text = tip;

    final emojiRegex = RegExp(r'^(\p{Emoji})\s*', unicode: true);
    final match = emojiRegex.firstMatch(tip);
    if (match != null) {
      emoji = match.group(1);
      text = tip.substring(match.end);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emoji or bullet
        SizedBox(
          width: 24,
          child: emoji != null
              ? Text(
                  emoji,
                  style: const TextStyle(fontSize: 14),
                )
              : Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 5, left: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
        ),
        const SizedBox(width: 8),

        // Tip text
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

/// Compact version showing just 2-3 key tips inline
class LevelFishingTipsCompact extends StatelessWidget {
  final List<String> tips;
  final int maxTips;

  const LevelFishingTipsCompact({
    super.key,
    required this.tips,
    this.maxTips = 2,
  });

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) return const SizedBox.shrink();

    final displayTips = tips.take(maxTips).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, 
                  size: 14, color: AppColors.teal),
              SizedBox(width: 6),
              Text(
                'Quick Tips',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...displayTips.map((tip) {
            // Strip emoji for compact view
            final text = tip.replaceAll(
                RegExp(r'^\p{Emoji}\s*', unicode: true), '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $text',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ],
      ),
    );
  }
}
