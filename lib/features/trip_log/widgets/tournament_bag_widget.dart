import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/models/tournament.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/providers/tournament_providers.dart';
import '../../../core/utils/constants.dart';

/// Compact tournament bag tracker that shows current bag status,
/// fish cards sorted by weight, and cull indicators.
class TournamentBagWidget extends ConsumerWidget {
  const TournamentBagWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(tournamentConfigProvider);
    if (config == null) return const SizedBox.shrink();

    final bag = ref.watch(tournamentBagProvider);

    return Container(
      decoration: GlassDecoration.elevated(radius: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row: title + bag count + total weight
          _BagHeader(bag: bag, config: config),

          // Divider
          Divider(
            height: 1,
            color: AppColors.cardBorder.withValues(alpha: 0.3),
          ),

          // Fish cards or empty state
          if (bag.fish.isEmpty)
            const _EmptyBagState()
          else
            _FishCardList(bag: bag),

          // Cull history summary (if any culls happened)
          if (bag.cullHistory.isNotEmpty) _CullHistorySummary(bag: bag),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bag Header
// ---------------------------------------------------------------------------

class _BagHeader extends StatelessWidget {
  final TournamentBag bag;
  final TournamentConfig config;

  const _BagHeader({required this.bag, required this.config});

  @override
  Widget build(BuildContext context) {
    final isFull = bag.isFull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // Trophy icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isFull
                  ? AppColors.warning.withValues(alpha: 0.15)
                  : AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.emoji_events,
              size: 18,
              color: isFull ? AppColors.warning : AppColors.teal,
            ),
          ),
          const SizedBox(width: 10),

          // Title
          const Text(
            'Tournament Bag',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // Fish count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isFull
                  ? AppColors.warning.withValues(alpha: 0.2)
                  : AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${bag.count}/${config.bagLimit}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: isFull ? AppColors.warning : AppColors.teal,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Total weight
          Text(
            '${bag.totalWeight.toStringAsFixed(2)} lbs',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              color: AppColors.tealLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty State
// ---------------------------------------------------------------------------

class _EmptyBagState extends StatelessWidget {
  const _EmptyBagState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phishing,
            size: 20,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          const Text(
            'No fish in the bag yet',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Fish Card List
// ---------------------------------------------------------------------------

class _FishCardList extends StatelessWidget {
  final TournamentBag bag;

  const _FishCardList({required this.bag});

  @override
  Widget build(BuildContext context) {
    final sorted = bag.sortedByWeight;
    final smallestId = bag.smallestFish?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < sorted.length; i++)
            _FishCard(
              fish: sorted[i],
              rank: i + 1,
              isSmallest: bag.isFull && sorted[i].id == smallestId,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual Fish Card
// ---------------------------------------------------------------------------

class _FishCard extends StatelessWidget {
  final TournamentFish fish;
  final int rank;
  final bool isSmallest;

  const _FishCard({
    required this.fish,
    required this.rank,
    required this.isSmallest,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final borderColor = isSmallest
        ? AppColors.error.withValues(alpha: 0.5)
        : AppColors.cardBorder.withValues(alpha: 0.2);
    final bgColor = isSmallest
        ? AppColors.error.withValues(alpha: 0.06)
        : AppColors.card.withValues(alpha: 0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: rank == 1
                  ? AppColors.teal.withValues(alpha: 0.2)
                  : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: rank == 1 ? AppColors.teal : AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Species + length
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fish.species.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${fish.lengthInches.toStringAsFixed(1)}" \u2022 ${timeFormat.format(fish.caughtAt)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Weight
          Text(
            '${fish.weightLbs.toStringAsFixed(2)} lbs',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
              color: AppColors.textPrimary,
            ),
          ),

          // Cull indicator for smallest fish
          if (isSmallest) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CULL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cull History Summary
// ---------------------------------------------------------------------------

class _CullHistorySummary extends StatelessWidget {
  final TournamentBag bag;

  const _CullHistorySummary({required this.bag});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        border: Border(
          top: BorderSide(
            color: AppColors.cardBorder.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_vert, size: 14, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            '${bag.cullHistory.length} cull${bag.cullHistory.length == 1 ? '' : 's'}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '+${bag.totalCullGain.toStringAsFixed(2)} lbs gained',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.success.withValues(alpha: 0.8),
            ),
          ),
          const Spacer(),
          Text(
            'avg ${bag.averageWeight.toStringAsFixed(2)} lbs',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Cull Opportunity Banner
// ---------------------------------------------------------------------------

/// A small banner shown when a new catch is heavier than the smallest fish
/// in a full bag. Intended to be placed near the add-catch flow.
class CullOpportunityBanner extends ConsumerWidget {
  /// Weight of the potential new fish in pounds.
  final double newWeightLbs;

  const CullOpportunityBanner({super.key, required this.newWeightLbs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gain = ref.watch(potentialCullGainProvider(newWeightLbs));
    if (gain == null) return const SizedBox.shrink();

    final bag = ref.watch(tournamentBagProvider);
    final smallest = bag.smallestFish;
    if (smallest == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'CULL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Replace ${smallest.weightLbs.toStringAsFixed(2)} lbs fish  \u2192  +${gain.toStringAsFixed(2)} lbs',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
