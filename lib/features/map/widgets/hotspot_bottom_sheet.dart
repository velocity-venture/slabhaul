import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slabhaul/core/models/fishing_hotspot.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/shared/widgets/info_chip.dart';
import 'package:slabhaul/features/map/providers/hotspot_providers.dart';

/// A draggable bottom sheet displaying details for the selected hotspot.
/// Shows why the spot ranks well, techniques, and seasonal patterns.
class HotspotBottomSheet extends ConsumerWidget {
  const HotspotBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(selectedHotspotProvider);
    if (rating == null) return const SizedBox.shrink();

    final hotspot = rating.hotspot;

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.15,
      maxChildSize: 0.75,
      snap: true,
      snapSizes: const [0.15, 0.45, 0.75],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header: Name and rating
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hotspot.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hotspot.lakeName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RatingBadge(rating: rating),
                ],
              ),
              const SizedBox(height: 16),

              // Quick stats row
              _QuickStatsRow(hotspot: hotspot, rating: rating),
              const SizedBox(height: 16),

              // Why it's good now (or concerns)
              if (rating.whyGoodNow.isNotEmpty || rating.concerns.isNotEmpty)
                _CurrentConditionsCard(rating: rating),
              const SizedBox(height: 16),

              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 16),

              // Suggested techniques
              _TechniquesSection(rating: rating),
              const SizedBox(height: 16),

              // Description
              _DescriptionSection(hotspot: hotspot),
              const SizedBox(height: 16),

              // Season calendar
              _SeasonCalendar(hotspot: hotspot),
              const SizedBox(height: 16),

              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 16),

              // Coordinates and navigate button
              _CoordinatesRow(hotspot: hotspot),
              const SizedBox(height: 16),

              // Navigate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchNavigation(hotspot),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navigate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchNavigation(FishingHotspot hotspot) async {
    final uri = Uri.parse(
      'geo:${hotspot.latitude},${hotspot.longitude}'
      '?q=${hotspot.latitude},${hotspot.longitude}'
      '(${Uri.encodeComponent(hotspot.name)})',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _RatingBadge extends StatelessWidget {
  final HotspotRating rating;

  const _RatingBadge({required this.rating});

  Color get _color {
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

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            '${rating.matchPercentage}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            rating.ratingLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final FishingHotspot hotspot;
  final HotspotRating rating;

  const _QuickStatsRow({required this.hotspot, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InfoChip(
          label: hotspot.structureLabel,
          icon: Icons.terrain,
          color: AppColors.teal,
        ),
        const SizedBox(width: 8),
        InfoChip(
          label: hotspot.depthRangeString,
          icon: Icons.straighten,
          color: AppColors.info,
        ),
      ],
    );
  }
}

class _CurrentConditionsCard extends StatelessWidget {
  final HotspotRating rating;

  const _CurrentConditionsCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: rating.whyGoodNow.isNotEmpty
              ? [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.05),
                ]
              : [
                  AppColors.warning.withValues(alpha: 0.15),
                  AppColors.warning.withValues(alpha: 0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rating.whyGoodNow.isNotEmpty
              ? AppColors.success.withValues(alpha: 0.3)
              : AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                rating.whyGoodNow.isNotEmpty
                    ? Icons.thumb_up
                    : Icons.info_outline,
                color: rating.whyGoodNow.isNotEmpty
                    ? AppColors.success
                    : AppColors.warning,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                rating.whyGoodNow.isNotEmpty
                    ? 'Why It\'s Good Now'
                    : 'Current Conditions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: rating.whyGoodNow.isNotEmpty
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (rating.whyGoodNow.isNotEmpty)
            ...rating.whyGoodNow.map(
              (reason) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '✓ ',
                      style: TextStyle(
                        color: AppColors.success,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (rating.concerns.isNotEmpty) ...[
            if (rating.whyGoodNow.isNotEmpty) const SizedBox(height: 8),
            ...rating.concerns.map(
              (concern) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠ ',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        concern,
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
    );
  }
}

class _TechniquesSection extends StatelessWidget {
  final HotspotRating rating;

  const _TechniquesSection({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.phishing, color: AppColors.teal, size: 18),
            SizedBox(width: 8),
            Text(
              'Best Techniques',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Spacer(),
            Text(
              'for current conditions',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rating.suggestedTechniques.asMap().entries.map((entry) {
            final index = entry.key;
            final technique = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: index == 0
                    ? AppColors.teal.withValues(alpha: 0.2)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: index == 0
                      ? AppColors.teal.withValues(alpha: 0.5)
                      : AppColors.cardBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (index == 0)
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child:
                          Icon(Icons.star, color: AppColors.teal, size: 14),
                    ),
                  Text(
                    technique,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          index == 0 ? FontWeight.w600 : FontWeight.normal,
                      color: index == 0
                          ? AppColors.teal
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  final FishingHotspot hotspot;

  const _DescriptionSection({required this.hotspot});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description, color: AppColors.textMuted, size: 18),
            SizedBox(width: 8),
            Text(
              'About This Spot',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          hotspot.description,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        if (hotspot.notes != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates,
                  color: AppColors.warning,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hotspot.notes!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _SeasonCalendar extends StatelessWidget {
  final FishingHotspot hotspot;

  const _SeasonCalendar({required this.hotspot});

  @override
  Widget build(BuildContext context) {
    const allSeasons = [
      ('pre_spawn', 'Pre-Spawn', 'Feb-Mar'),
      ('spawn', 'Spawn', 'Apr-May'),
      ('post_spawn', 'Post-Spawn', 'May-Jun'),
      ('summer', 'Summer', 'Jul-Sep'),
      ('fall', 'Fall', 'Oct-Nov'),
      ('winter', 'Winter', 'Dec-Feb'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_month, color: AppColors.textMuted, size: 18),
            SizedBox(width: 8),
            Text(
              'Peak Seasons',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: allSeasons.map((season) {
            final isActive = hotspot.bestSeasons.contains(season.$1);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.card.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isActive
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.cardBorder.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    season.$2,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isActive
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    season.$3,
                    style: TextStyle(
                      fontSize: 9,
                      color: isActive
                          ? AppColors.textSecondary
                          : AppColors.textMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _CoordinatesRow extends StatelessWidget {
  final FishingHotspot hotspot;

  const _CoordinatesRow({required this.hotspot});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.gps_fixed, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hotspot.coordinateString,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 16, color: AppColors.teal),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: hotspot.coordinateString));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Coordinates copied'),
                duration: Duration(seconds: 2),
                backgroundColor: AppColors.card,
              ),
            );
          },
          tooltip: 'Copy coordinates',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
