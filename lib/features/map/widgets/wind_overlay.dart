import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/wind_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/wind_providers.dart';

/// Compact wind indicator card shown at the bottom-right of the map.
///
/// Displays real-time or forecast wind data including:
/// - Wind direction arrow
/// - Wind speed and gusts
/// - Wave conditions
/// - Fishing recommendation
class WindOverlay extends ConsumerWidget {
  const WindOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windEnabled = ref.watch(windEnabledProvider);
    if (!windEnabled) return const SizedBox.shrink();

    final conditionsAsync = ref.watch(activeWindConditionsProvider);
    final analysisAsync = ref.watch(windAnalysisProvider);
    final timeMode = ref.watch(windTimeDisplayModeProvider);

    return Positioned(
      bottom: 24,
      right: 16,
      child: conditionsAsync.when(
        data: (conditions) {
          if (conditions == null) {
            return _buildLoadingCard();
          }
          return _WindCard(
            conditions: conditions,
            analysis: analysisAsync.valueOrNull,
            timeMode: timeMode,
          );
        },
        loading: () => _buildLoadingCard(),
        error: (_, __) => _buildErrorCard(),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.teal,
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, color: AppColors.textMuted, size: 24),
          SizedBox(width: 8),
          Text(
            'Wind data unavailable',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _WindCard extends StatelessWidget {
  final WindConditions conditions;
  final LakeWindAnalysis? analysis;
  final WindTimeMode timeMode;

  const _WindCard({
    required this.conditions,
    required this.analysis,
    required this.timeMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with time indicator
          if (timeMode != WindTimeMode.current)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _timeModeColor(timeMode).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    timeMode == WindTimeMode.historical 
                        ? Icons.history 
                        : Icons.schedule,
                    size: 12,
                    color: _timeModeColor(timeMode),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    timeMode == WindTimeMode.historical ? 'Past' : 'Forecast',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _timeModeColor(timeMode),
                    ),
                  ),
                ],
              ),
            ),

          // Main wind display
          Row(
            children: [
              // Wind direction arrow (animated)
              _AnimatedWindArrow(
                degrees: conditions.directionDeg.toDouble(),
                speedMph: conditions.speedMph,
              ),
              const SizedBox(width: 12),
              // Speed and direction text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Speed
                    Text(
                      '${conditions.speedMph.toStringAsFixed(1)} mph',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _windSpeedColor(conditions.speedMph),
                      ),
                    ),
                    // Direction
                    Text(
                      'from ${conditions.compassDirection}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    // Gusts
                    if (conditions.gustsMph > conditions.speedMph + 2)
                      Text(
                        'gusts ${conditions.gustsMph.toStringAsFixed(0)} mph',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.warning.withValues(alpha: 0.9),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Wave conditions
          if (analysis != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.waves,
                    size: 14,
                    color: _waveColor(analysis!.openWaterWaves.heightFt),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    analysis!.openWaterWaves.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: _waveColor(analysis!.openWaterWaves.heightFt),
                    ),
                  ),
                  if (analysis!.openWaterWaves.heightFt >= 0.5) ...[
                    Text(
                      ' • ${analysis!.openWaterWaves.heightFt.toStringAsFixed(1)}ft',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Fishing tip
          if (analysis != null) ...[
            const SizedBox(height: 8),
            Text(
              _shortFishingTip(analysis!),
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Color _timeModeColor(WindTimeMode mode) {
    return mode == WindTimeMode.historical ? AppColors.info : AppColors.warning;
  }

  Color _windSpeedColor(double mph) {
    if (mph < 5) return AppColors.windCalm;
    if (mph < 12) return AppColors.windModerate;
    if (mph < 20) return AppColors.windStrong;
    return AppColors.windDangerous;
  }

  Color _waveColor(double heightFt) {
    if (heightFt < 0.5) return AppColors.windCalm;
    if (heightFt < 1.5) return AppColors.windModerate;
    if (heightFt < 2.5) return AppColors.windStrong;
    return AppColors.windDangerous;
  }

  String _shortFishingTip(LakeWindAnalysis analysis) {
    final speed = analysis.wind.speedMph;
    if (speed < 5) return 'Calm water — try deeper structure';
    if (speed < 12) return 'Perfect! Hit the windward banks';
    if (speed < 20) return 'Strong — fish windblown points';
    return 'Rough — stay in protected areas';
  }
}

/// Animated wind direction arrow with subtle movement.
class _AnimatedWindArrow extends StatefulWidget {
  final double degrees;
  final double speedMph;

  const _AnimatedWindArrow({
    required this.degrees,
    required this.speedMph,
  });

  @override
  State<_AnimatedWindArrow> createState() => _AnimatedWindArrowState();
}

class _AnimatedWindArrowState extends State<_AnimatedWindArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: (2000 / (widget.speedMph + 1)).round().clamp(300, 2000)),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _AnimatedWindArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speedMph != widget.speedMph) {
      _controller.duration = Duration(
        milliseconds: (2000 / (widget.speedMph + 1)).round().clamp(300, 2000),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Subtle wobble based on wind speed
        final wobble = (widget.speedMph > 5)
            ? math.sin(_controller.value * 2 * math.pi) * 3 * (widget.speedMph / 30)
            : 0.0;

        return Transform.rotate(
          angle: (widget.degrees + wobble) * math.pi / 180,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _speedColor(widget.speedMph).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.navigation,
              color: _speedColor(widget.speedMph),
              size: 24,
            ),
          ),
        );
      },
    );
  }

  Color _speedColor(double mph) {
    if (mph < 5) return AppColors.windCalm;
    if (mph < 12) return AppColors.windModerate;
    if (mph < 20) return AppColors.windStrong;
    return AppColors.windDangerous;
  }
}

/// Extended wind panel with full analysis details.
/// Can be shown as a draggable sheet or dialog.
class WindAnalysisPanel extends ConsumerWidget {
  const WindAnalysisPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsync = ref.watch(windAnalysisProvider);

    return analysisAsync.when(
      data: (analysis) {
        if (analysis == null) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Wind Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Current conditions
              _buildConditionsRow(analysis.wind),
              const SizedBox(height: 12),

              // Wave conditions
              _buildWaveRow(analysis.openWaterWaves),
              const SizedBox(height: 12),

              // Fishing recommendation
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: AppColors.teal, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        analysis.fishingRecommendation,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Bank summary
              Row(
                children: [
                  _buildBankSummary(
                    'Exposed Banks',
                    analysis.exposedBanks.length,
                    const Color(0xFFF97316),
                  ),
                  const SizedBox(width: 12),
                  _buildBankSummary(
                    'Sheltered Banks',
                    analysis.shelteredBanks.length,
                    const Color(0xFF22C55E),
                  ),
                ],
              ),

              // Calm pockets
              if (analysis.calmPockets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Calm Pockets Found: ${analysis.calmPockets.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildConditionsRow(WindConditions conditions) {
    return Row(
      children: [
        _buildStatBox(
          conditions.speedMph.toStringAsFixed(1),
          'mph',
          Icons.air,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          conditions.compassDirection,
          'from',
          Icons.explore,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          conditions.gustsMph.toStringAsFixed(0),
          'gusts',
          Icons.bolt,
        ),
      ],
    );
  }

  Widget _buildWaveRow(WaveConditions waves) {
    return Row(
      children: [
        _buildStatBox(
          waves.heightFt.toStringAsFixed(1),
          'ft waves',
          Icons.waves,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _impactColor(waves.fishingImpact).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _impactLabel(waves.fishingImpact),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _impactColor(waves.fishingImpact),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
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

  Widget _buildBankSummary(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _impactColor(WaveFishingImpact impact) {
    switch (impact) {
      case WaveFishingImpact.excellent:
        return AppColors.success;
      case WaveFishingImpact.good:
        return AppColors.windCalm;
      case WaveFishingImpact.fair:
        return AppColors.windModerate;
      case WaveFishingImpact.poor:
        return AppColors.windStrong;
      case WaveFishingImpact.dangerous:
        return AppColors.windDangerous;
    }
  }

  String _impactLabel(WaveFishingImpact impact) {
    switch (impact) {
      case WaveFishingImpact.excellent:
        return 'Excellent Fishing';
      case WaveFishingImpact.good:
        return 'Good Conditions';
      case WaveFishingImpact.fair:
        return 'Fair Conditions';
      case WaveFishingImpact.poor:
        return 'Poor Conditions';
      case WaveFishingImpact.dangerous:
        return 'Dangerous - Stay Safe';
    }
  }
}
