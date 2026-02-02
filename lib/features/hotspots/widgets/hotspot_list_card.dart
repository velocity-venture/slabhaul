import 'package:flutter/material.dart';
import '../../../core/models/fishing_hotspot.dart';
import '../../../core/utils/constants.dart';

/// A card displaying a hotspot in the ranked list view.
class HotspotListCard extends StatelessWidget {
  final HotspotRating rating;
  final int rank;
  final VoidCallback? onTap;

  const HotspotListCard({
    super.key,
    required this.rating,
    required this.rank,
    this.onTap,
  });

  Color get _ratingColor {
    switch (rating.ratingLabel) {
      case 'Excellent':
        return AppColors.success;
      case 'Good':
        return AppColors.warning;
      case 'Fair':
        return const Color(0xFFF97316);
      case 'Off-Season':
        return AppColors.textMuted;
      default:
        return AppColors.textMuted;
    }
  }

  IconData get _structureIcon {
    switch (rating.hotspot.structureType) {
      case 'brush_pile':
        return Icons.forest;
      case 'bridge_piling':
        return Icons.account_balance;
      case 'dock':
        return Icons.directions_boat;
      case 'creek_channel':
        return Icons.water;
      case 'point':
        return Icons.navigation;
      case 'timber':
        return Icons.park;
      case 'flat':
        return Icons.waves;
      case 'ledge':
        return Icons.terrain;
      case 'hump':
        return Icons.landscape;
      case 'riprap':
        return Icons.construction;
      default:
        return Icons.local_fire_department;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hotspot = rating.hotspot;
    final color = _ratingColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: rank <= 3 ? color.withValues(alpha: 0.4) : AppColors.cardBorder,
            width: rank <= 3 ? 2 : 1,
          ),
          boxShadow: rank <= 3
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with rank, name, and score
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                children: [
                  // Rank badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: rank <= 3
                          ? color.withValues(alpha: 0.2)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: rank <= 3
                            ? color.withValues(alpha: 0.5)
                            : AppColors.cardBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '#$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: rank <= 3 ? color : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and lake
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotspot.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hotspot.lakeName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${rating.matchPercentage}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          'match',
                          style: TextStyle(
                            fontSize: 9,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick info row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  _InfoTag(
                    icon: _structureIcon,
                    label: hotspot.structureLabel,
                    color: AppColors.teal,
                  ),
                  const SizedBox(width: 8),
                  _InfoTag(
                    icon: Icons.straighten,
                    label: hotspot.depthRangeString,
                    color: AppColors.info,
                  ),
                ],
              ),
            ),

            // Techniques row
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  const Icon(
                    Icons.phishing,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      rating.suggestedTechniques.take(2).join(' • '),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Reason this spot is good (first reason only for compact view)
            if (rating.whyGoodNow.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          rating.whyGoodNow.first,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.success,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Footer with season badges
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      hotspot.seasonString,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoTag({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
