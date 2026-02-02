import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../providers/bait_recommendation_providers.dart';

/// Form for inputting current fishing conditions
class ConditionsInputForm extends ConsumerWidget {
  const ConditionsInputForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conditions = ref.watch(fishingConditionsProvider);
    final notifier = ref.read(fishingConditionsProvider.notifier);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppColors.teal, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Current Conditions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Water Temperature Slider
          _buildSliderSection(
            label: 'Water Temperature',
            value: conditions.waterTempF ?? 65,
            min: 35,
            max: 95,
            divisions: 60,
            valueLabel: '${(conditions.waterTempF ?? 65).round()}°F',
            icon: Icons.thermostat,
            onChanged: (value) => notifier.setWaterTemp(value),
            seasonIndicator: _getSeasonIndicator(conditions.waterTempF ?? 65),
          ),
          
          const SizedBox(height: 16),
          
          // Target Depth Slider
          _buildSliderSection(
            label: 'Target Depth',
            value: conditions.targetDepthFt,
            min: 1,
            max: 40,
            divisions: 39,
            valueLabel: '${conditions.targetDepthFt.round()} ft',
            icon: Icons.water,
            onChanged: (value) => notifier.setTargetDepth(value),
          ),
          
          const SizedBox(height: 16),
          
          // Water Clarity Selector
          const Text(
            'Water Clarity',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _ClaritySelector(
            selected: conditions.clarity,
            onChanged: (clarity) => notifier.setClarity(clarity),
          ),
          
          const SizedBox(height: 16),
          
          // Structure Type Selector
          const Text(
            'Target Structure (optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _StructureSelector(
            selected: conditions.structureType,
            onChanged: (type) => notifier.setStructureType(type),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSliderSection({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required IconData icon,
    required ValueChanged<double> onChanged,
    Widget? seasonIndicator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.teal),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                valueLabel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                ),
              ),
            ),
          ],
        ),
        if (seasonIndicator != null) ...[
          const SizedBox(height: 4),
          seasonIndicator,
        ],
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.teal,
            inactiveTrackColor: AppColors.teal.withValues(alpha: 0.2),
            thumbColor: AppColors.teal,
            overlayColor: AppColors.teal.withValues(alpha: 0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
  
  Widget _getSeasonIndicator(double tempF) {
    String season;
    Color color;
    IconData icon;
    
    if (tempF < 50) {
      season = 'Winter Pattern';
      color = const Color(0xFF60A5FA);
      icon = Icons.ac_unit;
    } else if (tempF < 60) {
      season = 'Pre-Spawn';
      color = const Color(0xFF34D399);
      icon = Icons.trending_up;
    } else if (tempF < 68) {
      season = 'Spawn';
      color = const Color(0xFFFBBF24);
      icon = Icons.water_drop;
    } else if (tempF < 75) {
      season = 'Post-Spawn';
      color = const Color(0xFFF97316);
      icon = Icons.wb_sunny;
    } else {
      season = 'Summer Pattern';
      color = const Color(0xFFEF4444);
      icon = Icons.wb_sunny;
    }
    
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          season,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ClaritySelector extends StatelessWidget {
  final WaterClarity selected;
  final ValueChanged<WaterClarity> onChanged;
  
  const _ClaritySelector({
    required this.selected,
    required this.onChanged,
  });
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WaterClarity.values.map((clarity) {
        final isSelected = clarity == selected;
        return GestureDetector(
          onTap: () => onChanged(clarity),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.teal.withValues(alpha: 0.2)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? AppColors.teal 
                    : AppColors.cardBorder,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _getClarityIcon(clarity),
                  size: 18,
                  color: isSelected ? AppColors.teal : AppColors.textMuted,
                ),
                const SizedBox(height: 4),
                Text(
                  clarity.displayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                        ? AppColors.teal 
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  IconData _getClarityIcon(WaterClarity clarity) {
    switch (clarity) {
      case WaterClarity.clear:
        return Icons.visibility;
      case WaterClarity.lightStain:
        return Icons.blur_on;
      case WaterClarity.stained:
        return Icons.blur_linear;
      case WaterClarity.muddy:
        return Icons.blur_off;
    }
  }
}

class _StructureSelector extends StatelessWidget {
  final StructureType? selected;
  final ValueChanged<StructureType?> onChanged;
  
  const _StructureSelector({
    required this.selected,
    required this.onChanged,
  });
  
  // Top structures for crappie fishing
  static const _topStructures = [
    StructureType.brushPile,
    StructureType.stakeBed,
    StructureType.dock,
    StructureType.standingTimber,
    StructureType.creekChannel,
    StructureType.bridge,
    StructureType.openWater,
    StructureType.point,
  ];
  
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // "Any" option
        _StructureChip(
          label: 'Any',
          icon: Icons.all_inclusive,
          isSelected: selected == null,
          onTap: () => onChanged(null),
        ),
        ..._topStructures.map((structure) => _StructureChip(
          label: structure.displayName,
          icon: _getStructureIcon(structure),
          isSelected: structure == selected,
          onTap: () => onChanged(structure),
        )),
      ],
    );
  }
  
  IconData _getStructureIcon(StructureType type) {
    switch (type) {
      case StructureType.brushPile:
        return Icons.park;
      case StructureType.stakeBed:
        return Icons.grid_on;
      case StructureType.standingTimber:
        return Icons.nature;
      case StructureType.laydown:
        return Icons.account_tree;
      case StructureType.dock:
        return Icons.house_siding;
      case StructureType.bridge:
        return Icons.domain;
      case StructureType.riprap:
        return Icons.landscape;
      case StructureType.openWater:
        return Icons.waves;
      case StructureType.creekChannel:
        return Icons.timeline;
      case StructureType.hump:
        return Icons.terrain;
      case StructureType.point:
        return Icons.place;
      case StructureType.vegetation:
        return Icons.grass;
    }
  }
}

class _StructureChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _StructureChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.teal.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppColors.teal : AppColors.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.teal : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
