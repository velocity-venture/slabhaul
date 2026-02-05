import 'package:flutter/material.dart';
import '../../../core/models/tides_data.dart';
import '../../../core/utils/constants.dart';
import 'tide_chart.dart';

/// Compact tide conditions card for dashboard display.
/// 
/// Shows:
/// - Current tide state (rising/falling)
/// - Current height
/// - Next high/low time
/// - Fishing rating indicator
/// - Mini tide chart
class TideCard extends StatelessWidget {
  final TideConditions conditions;
  final List<TideFishingWindow>? fishingWindows;
  final List<TideReading>? hourlyPredictions;
  final VoidCallback? onTap;

  const TideCard({
    super.key,
    required this.conditions,
    this.fishingWindows,
    this.hourlyPredictions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final impact = TideFishingImpact.fromConditions(conditions);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(impact),
            _buildCurrentConditions(),
            if (hourlyPredictions != null && hourlyPredictions!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TideMiniChart(
                  hourlyPredictions: hourlyPredictions!,
                  currentHeight: conditions.currentReading?.heightFt,
                ),
              ),
            _buildNextTides(),
            _buildFishingStatus(impact),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(TideFishingImpact impact) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.waves, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TIDES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conditions.station.name,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildRatingBadge(impact),
        ],
      ),
    );
  }

  Widget _buildRatingBadge(TideFishingImpact impact) {
    final color = Color(impact.overallRating == TideFishingRating.excellent
        ? 0xFF22C55E
        : impact.overallRating == TideFishingRating.good
            ? 0xFF3B82F6
            : impact.overallRating == TideFishingRating.fair
                ? 0xFFF59E0B
                : 0xFF6B7280);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            impact.overallRating == TideFishingRating.excellent
                ? Icons.star
                : impact.overallRating == TideFishingRating.good
                    ? Icons.thumb_up
                    : impact.overallRating == TideFishingRating.fair
                        ? Icons.remove
                        : Icons.hourglass_empty,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            impact.overallRating.name.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentConditions() {
    final state = conditions.currentState;
    final height = conditions.currentReading?.heightFt;
    final rate = conditions.movementRate;

    IconData stateIcon;
    Color stateColor;
    String stateLabel;

    switch (state) {
      case TideType.rising:
        stateIcon = Icons.trending_up;
        stateColor = AppColors.success;
        stateLabel = 'RISING';
        break;
      case TideType.falling:
        stateIcon = Icons.trending_down;
        stateColor = AppColors.info;
        stateLabel = 'FALLING';
        break;
      case TideType.high:
        stateIcon = Icons.arrow_upward;
        stateColor = AppColors.warning;
        stateLabel = 'HIGH';
        break;
      case TideType.low:
        stateIcon = Icons.arrow_downward;
        stateColor = AppColors.teal;
        stateLabel = 'LOW';
        break;
      case TideType.slack:
        stateIcon = Icons.pause;
        stateColor = AppColors.textMuted;
        stateLabel = 'SLACK';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Tide direction indicator
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(stateIcon, color: stateColor, size: 28),
          ),
          const SizedBox(width: 16),
          // Current height
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stateLabel,
                  style: TextStyle(
                    color: stateColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      height != null ? height.toStringAsFixed(1) : '--',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'ft',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    if (rate != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${rate.toStringAsFixed(2)} ft/hr',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextTides() {
    final nextHigh = conditions.nextHighTide;
    final nextLow = conditions.nextLowTide;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (nextHigh != null)
            Expanded(child: _tideTimeItem('High', nextHigh, AppColors.warning)),
          if (nextHigh != null && nextLow != null)
            Container(
              width: 1,
              height: 40,
              color: AppColors.cardBorder,
            ),
          if (nextLow != null)
            Expanded(child: _tideTimeItem('Low', nextLow, AppColors.info)),
        ],
      ),
    );
  }

  Widget _tideTimeItem(String label, TidePrediction tide, Color color) {
    final now = DateTime.now();
    final diff = tide.timestamp.difference(now);
    
    String timeUntil;
    if (diff.inHours < 1) {
      timeUntil = '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      final hours = diff.inHours;
      final mins = diff.inMinutes % 60;
      timeUntil = '${hours}h ${mins}m';
    } else {
      timeUntil = '${diff.inDays}d ${diff.inHours % 24}h';
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              label == 'High' ? Icons.arrow_upward : Icons.arrow_downward,
              color: color,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _formatTime(tide.timestamp),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          'in $timeUntil',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildFishingStatus(TideFishingImpact impact) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(impact.overallRating == TideFishingRating.excellent
            ? 0xFF22C55E
            : impact.overallRating == TideFishingRating.good
                ? 0xFF3B82F6
                : impact.overallRating == TideFishingRating.fair
                    ? 0xFFF59E0B
                    : 0xFF6B7280).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.phishing,
            color: Color(impact.overallRating == TideFishingRating.excellent
                ? 0xFF22C55E
                : impact.overallRating == TideFishingRating.good
                    ? 0xFF3B82F6
                    : impact.overallRating == TideFishingRating.fair
                        ? 0xFFF59E0B
                        : 0xFF6B7280),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              impact.summary,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

/// Very compact tide indicator for inline display.
class TideIndicator extends StatelessWidget {
  final TideConditions conditions;

  const TideIndicator({
    super.key,
    required this.conditions,
  });

  @override
  Widget build(BuildContext context) {
    final state = conditions.currentState;
    final height = conditions.currentReading?.heightFt;

    IconData icon;
    Color color;
    String label;

    switch (state) {
      case TideType.rising:
        icon = Icons.trending_up;
        color = AppColors.success;
        label = 'Rising';
        break;
      case TideType.falling:
        icon = Icons.trending_down;
        color = AppColors.info;
        label = 'Falling';
        break;
      default:
        icon = Icons.remove;
        color = AppColors.textMuted;
        label = 'Slack';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.waves, color: color, size: 14),
        const SizedBox(width: 4),
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(
          height != null ? '${height.toStringAsFixed(1)}\'' : label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
