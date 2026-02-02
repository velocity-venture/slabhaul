import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

class _PresetData {
  final String label;
  final double sinkerWeightOz;
  final double lineOutFt;
  final double boatSpeedMph;

  const _PresetData({
    required this.label,
    required this.sinkerWeightOz,
    required this.lineOutFt,
    required this.boatSpeedMph,
  });
}

const List<_PresetData> _presets = [
  _PresetData(
    label: 'Shallow (8-12ft)',
    sinkerWeightOz: 0.25,
    lineOutFt: 20,
    boatSpeedMph: 0.4,
  ),
  _PresetData(
    label: 'Mid (15-20ft)',
    sinkerWeightOz: 0.5,
    lineOutFt: 50,
    boatSpeedMph: 0.6,
  ),
  _PresetData(
    label: 'Deep (25+ft)',
    sinkerWeightOz: 1.0,
    lineOutFt: 80,
    boatSpeedMph: 0.8,
  ),
];

class PresetChips extends ConsumerWidget {
  const PresetChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(calculatorInputProvider);
    final notifier = ref.read(calculatorInputProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Presets',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((preset) {
            final isActive = _matchesPreset(input, preset);
            return ActionChip(
              label: Text(preset.label),
              onPressed: () {
                notifier.applyPreset(
                  sinkerWeightOz: preset.sinkerWeightOz,
                  lineOutFt: preset.lineOutFt,
                  boatSpeedMph: preset.boatSpeedMph,
                );
              },
              backgroundColor:
                  isActive ? AppColors.teal.withValues(alpha: 0.25) : AppColors.card,
              side: BorderSide(
                color: isActive ? AppColors.teal : AppColors.cardBorder,
              ),
              labelStyle: TextStyle(
                color: isActive ? AppColors.tealLight : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                fontSize: 13,
              ),
              avatar: isActive
                  ? const Icon(Icons.check_circle, size: 16, color: AppColors.teal)
                  : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  bool _matchesPreset(dynamic input, _PresetData preset) {
    return (input.sinkerWeightOz - preset.sinkerWeightOz).abs() < 0.001 &&
        (input.lineOutFt - preset.lineOutFt).abs() < 0.5 &&
        (input.boatSpeedMph - preset.boatSpeedMph).abs() < 0.01;
  }
}
