import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

class DepthResultDisplay extends ConsumerWidget {
  const DepthResultDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(calculatorResultProvider);

    final zoneColor = _zoneColor(result.depthZoneColor);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      child: Column(
        children: [
          // Primary depth reading.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: result.depthFt),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                      height: 1.0,
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              const Text(
                'ft',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.tealLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stats row.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'Depth Ratio',
                value: '${(result.depthRatio * 100).toStringAsFixed(1)}%',
                valueColor: AppColors.textPrimary,
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.cardBorder,
              ),
              _StatItem(
                label: 'Line Angle',
                value: '${result.lineAngleDeg.toStringAsFixed(1)}°',
                valueColor: const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Depth zone badge.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: zoneColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: zoneColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              result.depthZone,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: zoneColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _zoneColor(String colorName) {
    switch (colorName) {
      case 'green':
        return AppColors.success;
      case 'teal':
        return AppColors.teal;
      case 'blue':
        return AppColors.info;
      case 'purple':
        return const Color(0xFF8B5CF6);
      default:
        return AppColors.teal;
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
