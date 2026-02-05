import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../providers/bait_recommendation_providers.dart';

/// Compact bait recommendation widget for dashboard/overview screens
/// Shows top pick with quick info
class BaitRecommendationMini extends ConsumerWidget {
  final VoidCallback? onTap;
  
  const BaitRecommendationMini({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(baitRecommendationsProvider);
    final conditions = ref.watch(fishingConditionsProvider);
    
    // Show empty state if no recommendations
    if (result == null || !conditions.canGenerateRecommendations) {
      return _EmptyState(onTap: onTap);
    }
    
    final topPick = result.topPick;
    if (topPick == null) {
      return _EmptyState(onTap: onTap);
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.lightbulb,
                    color: AppColors.teal,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Bait Recommendation',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Top Pick
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.3),
                        AppColors.teal.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('🏆', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topPick.bait.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'in ${topPick.recommendedColors.first}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                _ScoreBadge(score: topPick.score),
              ],
            ),
            const SizedBox(height: 10),
            
            // Quick Info Chips
            Row(
              children: [
                _QuickChip(
                  icon: Icons.straighten,
                  label: topPick.recommendedSize,
                ),
                const SizedBox(width: 8),
                if (topPick.recommendedWeight != null)
                  _QuickChip(
                    icon: Icons.fitness_center,
                    label: topPick.recommendedWeight!.label,
                  ),
              ],
            ),
            
            // Season/Conditions hint
            const SizedBox(height: 8),
            Text(
              '${result.conditions.season.displayName} • ${result.conditions.waterTempF.round()}°F • ${result.conditions.clarity.displayName}',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _EmptyState({this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.lightbulb_outline,
              color: AppColors.textMuted,
              size: 32,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get Bait Recommendations',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Enter conditions to see what to throw',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Set Conditions',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 12, color: AppColors.teal),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final double score;
  
  const _ScoreBadge({required this.score});
  
  @override
  Widget build(BuildContext context) {
    Color color;
    if (score >= 85) {
      color = const Color(0xFF22C55E);
    } else if (score >= 70) {
      color = const Color(0xFFEAB308);
    } else {
      color = const Color(0xFFF97316);
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${score.round()}%',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  
  const _QuickChip({
    required this.icon,
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline summary widget for showing bait recommendation in other contexts
class BaitRecommendationInline extends ConsumerWidget {
  const BaitRecommendationInline({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topPick = ref.watch(topBaitPickProvider);
    
    if (topPick == null) {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎯', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          '${topPick.bait.name} • ${topPick.recommendedColors.first}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
