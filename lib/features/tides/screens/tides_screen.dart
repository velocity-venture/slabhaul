import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../core/models/tides_data.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../weather/providers/weather_providers.dart';
import '../providers/tides_providers.dart';
import '../widgets/tide_chart.dart';

/// Full tides detail screen with comprehensive tide information.
/// 
/// Displays:
/// - Full 48-hour tide chart
/// - Station information
/// - Detailed predictions table
/// - Fishing recommendations
class TidesScreen extends ConsumerWidget {
  const TidesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tideDataAsync = ref.watch(selectedLakeTideDataProvider);
    final lake = ref.watch(selectedWeatherLakeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.teal,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(selectedLakeTideDataProvider);
          await ref.read(selectedLakeTideDataProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'Tide Conditions',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.teal),
                  onPressed: () => ref.invalidate(selectedLakeTideDataProvider),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: tideDataAsync.when(
                data: (data) {
                  if (data == null) {
                    return SliverFillRemaining(
                      child: _buildNotTidalMessage(lake.name),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _buildLocationHeader(data, lake.name),
                      const SizedBox(height: 16),
                      _buildCurrentStatus(data),
                      const SizedBox(height: 16),
                      TideChart(
                        hourlyPredictions: data.hourlyPredictions,
                        predictions: data.conditions.predictions,
                        fishingWindows: data.fishingWindows,
                        currentHeight: data.conditions.currentReading?.heightFt,
                      ),
                      const SizedBox(height: 16),
                      _buildFishingWindows(data.fishingWindows),
                      const SizedBox(height: 16),
                      _buildPredictionsTable(data.conditions.predictions),
                      const SizedBox(height: 16),
                      _buildFishingTips(data.impact),
                      const SizedBox(height: 16),
                      _buildStationInfo(data.conditions.station, data.tidalWater),
                      const SizedBox(height: 24),
                    ]),
                  );
                },
                loading: () => SliverList(
                  delegate: SliverChildListDelegate([
                    const SkeletonCard(height: 80),
                    const SizedBox(height: 16),
                    const SkeletonCard(height: 120),
                    const SizedBox(height: 16),
                    const SkeletonCard(height: 220),
                    const SizedBox(height: 16),
                    const SkeletonCard(height: 160),
                  ]),
                ),
                error: (err, _) => SliverFillRemaining(
                  child: _buildErrorMessage(
                    () => ref.invalidate(selectedLakeTideDataProvider),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotTidalMessage(String lakeName) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.waves,
                color: AppColors.textMuted,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Tidal Data',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '$lakeName is not in a tidal-influenced area. Tide data is only available for coastal and brackish waters.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              'Tidal waters include:',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Sabine Lake (TX/LA)\n'
              '• Lake Pontchartrain (LA)\n'
              '• Mobile-Tensaw Delta (AL)\n'
              '• St. Johns River (FL)',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Could not load tide data',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: AppColors.teal),
            label: const Text('Retry', style: TextStyle(color: AppColors.teal)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.teal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationHeader(TideDisplayData data, String lakeName) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.location_on, color: AppColors.info, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lakeName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Station: ${data.conditions.station.name}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(data.tidalWater.tidalInfluence * 100).round()}% Tidal',
              style: const TextStyle(
                color: AppColors.teal,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStatus(TideDisplayData data) {
    final conditions = data.conditions;
    final state = conditions.currentState;
    final height = conditions.currentReading?.heightFt;
    final rate = conditions.movementRate;
    final range = conditions.tidalRange;

    Color stateColor;
    IconData stateIcon;
    String stateLabel;

    switch (state) {
      case TideType.rising:
        stateColor = AppColors.success;
        stateIcon = Icons.trending_up;
        stateLabel = 'Rising';
        break;
      case TideType.falling:
        stateColor = AppColors.info;
        stateIcon = Icons.trending_down;
        stateLabel = 'Falling';
        break;
      default:
        stateColor = AppColors.textMuted;
        stateIcon = Icons.pause;
        stateLabel = 'Slack';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current height
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CURRENT LEVEL',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        height?.toStringAsFixed(1) ?? '--',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'ft',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // State indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(stateIcon, color: stateColor, size: 32),
                    const SizedBox(height: 4),
                    Text(
                      stateLabel,
                      style: TextStyle(
                        color: stateColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 12),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statItem('Movement', rate != null ? '${rate.toStringAsFixed(2)} ft/hr' : '--'),
              _statItem('Range', range != null ? '${range.toStringAsFixed(1)} ft' : '--'),
              _statItem('Next ${conditions.nextTideEvent?.isHigh == true ? "High" : "Low"}',
                  conditions.timeUntilNextEvent != null
                      ? _formatDuration(conditions.timeUntilNextEvent!)
                      : '--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFishingWindows(List<TideFishingWindow> windows) {
    final now = DateTime.now();
    final upcomingWindows = windows
        .where((w) => w.end.isAfter(now))
        .where((w) => w.rating == TideFishingRating.excellent || 
                      w.rating == TideFishingRating.good)
        .take(4)
        .toList();

    if (upcomingWindows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.access_time, color: AppColors.success, size: 18),
                SizedBox(width: 8),
                Text(
                  'BEST FISHING WINDOWS',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ...upcomingWindows.map((w) => _fishingWindowTile(w)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _fishingWindowTile(TideFishingWindow window) {
    final color = Color(window.ratingColorValue);
    final isActive = window.isActive;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.15) : AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: isActive ? Border.all(color: color.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              window.rating == TideFishingRating.excellent ? Icons.star : Icons.thumb_up,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _formatTimeRange(window.start, window.end),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NOW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  window.reason,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                window.ratingLabel,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                window.durationDisplay,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsTable(List<TidePrediction> predictions) {
    final now = DateTime.now();
    final upcoming = predictions
        .where((p) => p.timestamp.isAfter(now))
        .take(8)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.schedule, color: AppColors.info, size: 18),
                SizedBox(width: 8),
                Text(
                  'UPCOMING TIDES',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          ...upcoming.asMap().entries.map((e) => _predictionRow(e.value, e.key.isEven)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _predictionRow(TidePrediction pred, bool isEven) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: isEven ? AppColors.background.withValues(alpha: 0.5) : null,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (pred.isHigh ? AppColors.warning : AppColors.info).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              pred.isHigh ? Icons.arrow_upward : Icons.arrow_downward,
              color: pred.isHigh ? AppColors.warning : AppColors.info,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pred.isHigh ? 'High Tide' : 'Low Tide',
                  style: TextStyle(
                    color: pred.isHigh ? AppColors.warning : AppColors.info,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _formatDateFull(pred.timestamp),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTime(pred.timestamp),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                pred.heightDisplay,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFishingTips(TideFishingImpact impact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.teal, size: 18),
              SizedBox(width: 8),
              Text(
                'FISHING TIPS',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (impact.positives.isNotEmpty) ...[
            ...impact.positives.map((tip) => _tipItem(tip, AppColors.success, Icons.add_circle_outline)),
            const SizedBox(height: 8),
          ],
          if (impact.negatives.isNotEmpty) ...[
            ...impact.negatives.map((tip) => _tipItem(tip, AppColors.warning, Icons.warning_amber_outlined)),
            const SizedBox(height: 8),
          ],
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 8),
          ...impact.recommendations.map((rec) => _tipItem(rec, AppColors.teal, Icons.tips_and_updates_outlined)),
        ],
      ),
    );
  }

  Widget _tipItem(String text, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfo(TideStation station, TidalWater tidalWater) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.textMuted, size: 18),
              SizedBox(width: 8),
              Text(
                'STATION INFO',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow('Station', station.name),
          _infoRow('ID', station.id),
          _infoRow('Location', '${station.latitude.toStringAsFixed(4)}°, ${station.longitude.toStringAsFixed(4)}°'),
          if (station.stateCode != null)
            _infoRow('State', station.stateCode!),
          const SizedBox(height: 8),
          const Divider(color: AppColors.cardBorder),
          const SizedBox(height: 8),
          Text(
            tidalWater.notes,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Data source: NOAA CO-OPS',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
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

  String _formatDateFull(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} - ${_formatTime(end)}';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours < 1) {
      return '${duration.inMinutes}m';
    } else if (duration.inHours < 24) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    }
  }
}
