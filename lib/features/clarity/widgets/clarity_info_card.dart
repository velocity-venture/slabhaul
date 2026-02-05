import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/clarity_providers.dart';

/// Card displaying current water clarity estimate with factors and fishing advice.
class ClarityInfoCard extends ConsumerWidget {
  const ClarityInfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clarityAsync = ref.watch(lakeClarityProvider);

    return clarityAsync.when(
      data: (estimate) {
        if (estimate == null) {
          return _NoDataCard();
        }
        return _ClarityCard(estimate: estimate);
      },
      loading: () => _LoadingCard(),
      error: (_, __) => _ErrorCard(),
    );
  }
}

class _ClarityCard extends StatelessWidget {
  final ClarityEstimate estimate;

  const _ClarityCard({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with clarity level
          _ClarityHeader(estimate: estimate),
          
          const Divider(height: 1, color: AppColors.cardBorder),
          
          // Factors affecting clarity
          _FactorsSection(factors: estimate.factors),
          
          const Divider(height: 1, color: AppColors.cardBorder),
          
          // Fishing recommendations
          _FishingAdviceSection(estimate: estimate),
          
          const Divider(height: 1, color: AppColors.cardBorder),
          
          // Recommended colors
          _ColorRecommendationsSection(estimate: estimate),
        ],
      ),
    );
  }
}

/// Header showing the main clarity estimate
class _ClarityHeader extends StatelessWidget {
  final ClarityEstimate estimate;

  const _ClarityHeader({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(estimate.level.mapColor).withValues(alpha: 0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          // Clarity icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Color(estimate.level.mapColor).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                estimate.level.icon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Clarity details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  estimate.level.displayName,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(estimate.level.mapColor),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.visibility,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '~${estimate.visibilityFt.toStringAsFixed(1)} ft visibility',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      estimate.trend.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      estimate.trend.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _trendColor(estimate.trend),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ConfidenceBadge(confidence: estimate.confidence),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _trendColor(ClarityTrend trend) {
    switch (trend) {
      case ClarityTrend.improving:
        return AppColors.success;
      case ClarityTrend.stable:
        return AppColors.textSecondary;
      case ClarityTrend.worsening:
        return AppColors.error;
    }
  }
}

/// Badge showing confidence level
class _ConfidenceBadge extends StatelessWidget {
  final ClarityConfidence confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _confidenceColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _confidenceColor().withValues(alpha: 0.4)),
      ),
      child: Text(
        '${confidence.displayName} confidence',
        style: TextStyle(
          fontSize: 10,
          color: _confidenceColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _confidenceColor() {
    switch (confidence) {
      case ClarityConfidence.high:
        return AppColors.success;
      case ClarityConfidence.medium:
        return AppColors.warning;
      case ClarityConfidence.low:
        return AppColors.textSecondary;
    }
  }
}

/// Section showing what factors are affecting clarity
class _FactorsSection extends StatelessWidget {
  final ClarityFactors factors;

  const _FactorsSection({required this.factors});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What\'s Affecting Clarity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Precipitation factor
          _FactorRow(
            icon: Icons.water_drop,
            label: 'Rain (24h)',
            value: factors.precipitation24h > 0
                ? '${factors.precipitation24h.toStringAsFixed(1)} mm'
                : 'None',
            impact: _rainImpact(factors.precipitation24h),
          ),
          const SizedBox(height: 8),
          
          // Days since rain
          _FactorRow(
            icon: Icons.calendar_today,
            label: 'Days since rain',
            value: '${factors.daysSinceRain} days',
            impact: factors.daysSinceRain >= 5 
                ? FactorImpact.positive 
                : (factors.daysSinceRain <= 2 ? FactorImpact.negative : FactorImpact.neutral),
          ),
          const SizedBox(height: 8),
          
          // Wind factor
          _FactorRow(
            icon: Icons.air,
            label: 'Wind',
            value: '${factors.windSpeedMph.toStringAsFixed(0)} mph',
            impact: _windImpact(factors.windSpeedMph),
          ),
          const SizedBox(height: 8),
          
          // Seasonal factor
          _FactorRow(
            icon: Icons.wb_sunny,
            label: 'Season',
            value: _seasonName(factors.month),
            impact: _seasonImpact(factors.month),
          ),
        ],
      ),
    );
  }

  FactorImpact _rainImpact(double precip) {
    if (precip > 15) return FactorImpact.negative;
    if (precip > 5) return FactorImpact.slightNegative;
    return FactorImpact.positive;
  }

  FactorImpact _windImpact(double wind) {
    if (wind > 20) return FactorImpact.negative;
    if (wind > 12) return FactorImpact.slightNegative;
    return FactorImpact.neutral;
  }

  String _seasonName(int month) {
    if (month >= 3 && month <= 5) return 'Spring';
    if (month >= 6 && month <= 8) return 'Summer';
    if (month >= 9 && month <= 11) return 'Fall';
    return 'Winter';
  }

  FactorImpact _seasonImpact(int month) {
    // Spring = runoff, summer = clear
    if (month >= 3 && month <= 5) return FactorImpact.slightNegative;
    if (month >= 7 && month <= 9) return FactorImpact.positive;
    return FactorImpact.neutral;
  }
}

enum FactorImpact { positive, neutral, slightNegative, negative }

/// Single row showing a factor and its impact
class _FactorRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final FactorImpact impact;

  const _FactorRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.impact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 8),
        _ImpactIndicator(impact: impact),
      ],
    );
  }
}

/// Visual indicator for factor impact
class _ImpactIndicator extends StatelessWidget {
  final FactorImpact impact;

  const _ImpactIndicator({required this.impact});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: _color().withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _icon(),
        size: 14,
        color: _color(),
      ),
    );
  }

  IconData _icon() {
    switch (impact) {
      case FactorImpact.positive:
        return Icons.thumb_up;
      case FactorImpact.neutral:
        return Icons.remove;
      case FactorImpact.slightNegative:
        return Icons.arrow_downward;
      case FactorImpact.negative:
        return Icons.thumb_down;
    }
  }

  Color _color() {
    switch (impact) {
      case FactorImpact.positive:
        return AppColors.success;
      case FactorImpact.neutral:
        return AppColors.textSecondary;
      case FactorImpact.slightNegative:
        return AppColors.warning;
      case FactorImpact.negative:
        return AppColors.error;
    }
  }
}

/// Section showing fishing advice based on clarity
class _FishingAdviceSection extends StatelessWidget {
  final ClarityEstimate estimate;

  const _FishingAdviceSection({required this.estimate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎣 Fishing Strategy',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            estimate.fishingAdvice,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          
          // Reasoning
          if (estimate.reasons.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Why this estimate:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            ...estimate.reasons.map((reason) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }
}

/// Section showing recommended bait colors
class _ColorRecommendationsSection extends StatelessWidget {
  final ClarityEstimate estimate;

  const _ColorRecommendationsSection({required this.estimate});

  @override
  Widget build(BuildContext context) {
    final colors = estimate.recommendedColors;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎨 Recommended Bait Colors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors.map((color) => _ColorChip(colorName: color)).toList(),
          ),
        ],
      ),
    );
  }
}

/// Individual color recommendation chip
class _ColorChip extends StatelessWidget {
  final String colorName;

  const _ColorChip({required this.colorName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _colorForName(colorName).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _colorForName(colorName).withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        colorName,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Color _colorForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('chartreuse')) return const Color(0xFFDFFF00);
    if (lower.contains('white')) return const Color(0xFFE5E5E5);
    if (lower.contains('pearl')) return const Color(0xFFF0EAD6);
    if (lower.contains('pink')) return const Color(0xFFFF69B4);
    if (lower.contains('orange')) return const Color(0xFFFFA500);
    if (lower.contains('black')) return const Color(0xFF333333);
    if (lower.contains('blue')) return const Color(0xFF4169E1);
    if (lower.contains('green')) return const Color(0xFF228B22);
    if (lower.contains('smoke')) return const Color(0xFF708090);
    if (lower.contains('shad')) return const Color(0xFFB8C4D0);
    if (lower.contains('ghost')) return const Color(0xFFD3D3D3);
    if (lower.contains('junebug')) return const Color(0xFF4B0082);
    return AppColors.teal;
  }
}

// Placeholder cards for loading/error states

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Estimating clarity...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.water_drop_outlined, size: 48, color: AppColors.textSecondary),
            SizedBox(height: 16),
            Text(
              'Select a lake to see clarity estimate',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              'Unable to estimate clarity',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact clarity indicator for inline use
class ClarityIndicator extends ConsumerWidget {
  const ClarityIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clarityAsync = ref.watch(lakeClarityProvider);

    return clarityAsync.when(
      data: (estimate) {
        if (estimate == null) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Color(estimate.level.mapColor).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Color(estimate.level.mapColor).withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(estimate.level.icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                '${estimate.visibilityFt.toStringAsFixed(1)} ft',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(estimate.level.mapColor),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
