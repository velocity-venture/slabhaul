import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

class DepthSliders extends ConsumerWidget {
  const DepthSliders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(calculatorInputProvider);
    final notifier = ref.read(calculatorInputProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Sinker Weight (discrete) ----
        _SliderHeader(
          label: 'Sinker Weight',
          value: SinkerWeights.label(input.sinkerWeightOz),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _sinkerIndex(input.sinkerWeightOz).toDouble(),
            min: 0,
            max: (SinkerWeights.values.length - 1).toDouble(),
            divisions: SinkerWeights.values.length - 1,
            label: SinkerWeights.label(input.sinkerWeightOz),
            onChanged: (val) {
              final idx = val.round().clamp(0, SinkerWeights.values.length - 1);
              notifier.setSinkerWeight(SinkerWeights.values[idx]);
            },
          ),
        ),
        const SizedBox(height: 8),

        // ---- Line Out (continuous) ----
        _SliderHeader(
          label: 'Line Out',
          value: '${input.lineOutFt.toStringAsFixed(0)} ft',
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: input.lineOutFt,
            min: 10,
            max: 100,
            divisions: 90,
            label: '${input.lineOutFt.toStringAsFixed(0)} ft',
            onChanged: (val) {
              notifier.setLineOut(val.roundToDouble());
            },
          ),
        ),
        const SizedBox(height: 8),

        // ---- Boat Speed (continuous) ----
        _SliderHeader(
          label: 'Boat Speed',
          value: '${input.boatSpeedMph.toStringAsFixed(2)} mph',
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: input.boatSpeedMph,
            min: 0.0,
            max: 2.0,
            divisions: 40,
            label: '${input.boatSpeedMph.toStringAsFixed(2)} mph',
            onChanged: (val) {
              // Round to nearest 0.05.
              final rounded = (val * 20).round() / 20.0;
              notifier.setBoatSpeed(rounded);
            },
          ),
        ),
        const SizedBox(height: 16),

        // ---- Line Type (choice chips) ----
        const Text(
          'Line Type',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: LineTypes.dragFactors.keys.map((type) {
            final isSelected = input.lineType == type;
            return ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (_) => notifier.setLineType(type),
              selectedColor: AppColors.teal.withValues(alpha: 0.3),
              backgroundColor: AppColors.card,
              side: BorderSide(
                color: isSelected ? AppColors.teal : AppColors.cardBorder,
              ),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.tealLight : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              checkmarkColor: AppColors.tealLight,
            );
          }).toList(),
        ),
      ],
    );
  }

  int _sinkerIndex(double oz) {
    int closest = 0;
    double minDiff = double.infinity;
    for (int i = 0; i < SinkerWeights.values.length; i++) {
      final diff = (SinkerWeights.values[i] - oz).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = i;
      }
    }
    return closest;
  }
}

class _SliderHeader extends StatelessWidget {
  final String label;
  final String value;

  const _SliderHeader({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
