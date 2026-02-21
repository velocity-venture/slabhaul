import 'package:flutter/material.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/info_chip.dart';

/// Card displaying a single bait recommendation with all details
class BaitRecommendationCard extends StatelessWidget {
  final BaitRecommendation recommendation;
  final bool isExpanded;
  final VoidCallback? onTap;

  const BaitRecommendationCard({
    super.key,
    required this.recommendation,
    this.isExpanded = false,
    this.onTap,
  });

  Color get _rankColor {
    switch (recommendation.rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.textMuted;
    }
  }

  String get _rankLabel {
    switch (recommendation.rank) {
      case 1:
        return 'TOP PICK';
      case 2:
        return '2ND CHOICE';
      case 3:
        return '3RD CHOICE';
      default:
        return '#${recommendation.rank}';
    }
  }

  IconData get _categoryIcon {
    switch (recommendation.bait.category) {
      case BaitCategory.tubeJig:
        return Icons.waves;
      case BaitCategory.softPlasticMinnow:
        return Icons.set_meal;
      case BaitCategory.curlyTailGrub:
        return Icons.tornado;
      case BaitCategory.hairJig:
        return Icons.blur_on;
      case BaitCategory.liveMinnow:
        return Icons.water;
      case BaitCategory.crankbait:
        return Icons.phishing;
      case BaitCategory.bladeBait:
        return Icons.flash_on;
      case BaitCategory.microJig:
        return Icons.bug_report;
    }
  }

  Gradient? get _cardGradient {
    if (recommendation.rank == 1) return AppGradients.rankGold;
    if (recommendation.rank <= 3) return AppGradients.tealWash;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isTopPick = recommendation.rank == 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isTopPick
          ? AppColors.card.withValues(alpha: 0.95)
          : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isTopPick
              ? _rankColor.withValues(alpha: 0.5)
              : recommendation.rank <= 3
                  ? AppColors.teal.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
          width: isTopPick ? 2 : 1,
        ),
      ),
      elevation: isTopPick ? 1 : 0,
      shadowColor: isTopPick ? const Color(0xFFFFD700).withValues(alpha: 0.3) : null,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Stack(
            children: [
              _BaitImageContainer(
                category: recommendation.bait.category,
                fallbackIcon: _categoryIcon,
                gradient: _cardGradient,
              ),
              if (recommendation.rank <= 3)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rankColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      recommendation.rank == 1 ? '#1' : '#${recommendation.rank}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  recommendation.bait.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _rankColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _rankLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _rankColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ConfidenceBadge(level: recommendation.confidenceLevel),
                  const Spacer(),
                  _ScoreGradientBadge(score: recommendation.score),
                ],
              ),
            ],
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 8),

                  // Recommended Colors
                  const _SectionHeader(
                    icon: Icons.palette,
                    title: 'Recommended Colors',
                    color: Color(0xFF60A5FA),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: recommendation.recommendedColors
                        .map((c) => InfoChip(
                              label: c,
                              color: AppColors.teal,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // Size & Weight Row
                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.straighten,
                          label: 'Size',
                          value: recommendation.recommendedSize,
                          color: const Color(0xFF818CF8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (recommendation.recommendedWeight != null)
                        Expanded(
                          child: _InfoBox(
                            icon: Icons.fitness_center,
                            label: 'Jig Weight',
                            value: recommendation.recommendedWeight!.label,
                            color: const Color(0xFFFBBF24),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Techniques
                  const _SectionHeader(
                    icon: Icons.sports,
                    title: 'Techniques',
                    color: Color(0xFF34D399),
                  ),
                  const SizedBox(height: 6),
                  ...recommendation.techniques.map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '  •  ',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              t,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Presentation Tips
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.teal.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.teal,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Presentation Tips',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...recommendation.presentationTips.map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              tip,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Why Recommended
                  if (recommendation.reasons.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const _SectionHeader(
                      icon: Icons.check_circle_outline,
                      title: 'Why This Bait?',
                      color: Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 6),
                    ...recommendation.reasons.map(
                      (r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check,
                              color: Color(0xFF22C55E),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                r,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bait image container with gradient background and icon fallback
class _BaitImageContainer extends StatelessWidget {
  final BaitCategory category;
  final IconData fallbackIcon;
  final Gradient? gradient;

  const _BaitImageContainer({
    required this.category,
    required this.fallbackIcon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient ?? LinearGradient(
          colors: [
            AppColors.teal.withValues(alpha: 0.2),
            AppColors.surface.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        category.assetPath,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          fallbackIcon,
          color: AppColors.teal,
          size: 26,
        ),
      ),
    );
  }
}

/// Score badge with gradient background
class _ScoreGradientBadge extends StatelessWidget {
  final double score;

  const _ScoreGradientBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final Gradient gradient;
    if (score >= 85) {
      gradient = AppGradients.scoreGreen;
    } else if (score >= 70) {
      gradient = AppGradients.scoreAmber;
    } else {
      gradient = const LinearGradient(
        colors: [Color(0xFFF97316), Color(0xFFEA580C)],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${score.round()}%',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String level;

  const _ConfidenceBadge({required this.level});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (level) {
      case 'High':
        color = const Color(0xFF22C55E);
        icon = Icons.verified;
        break;
      case 'Medium':
        color = const Color(0xFFEAB308);
        icon = Icons.check_circle;
        break;
      default:
        color = const Color(0xFFF97316);
        icon = Icons.help_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          '$level Confidence',
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
