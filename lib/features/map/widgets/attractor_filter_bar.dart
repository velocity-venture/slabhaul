import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Row of type-filter chips that sits below the [LakeSelector].
///
/// Each chip is coloured according to its attractor type. The "All" chip uses
/// the default teal colour.
class AttractorFilterBar extends ConsumerWidget {
  const AttractorFilterBar({super.key});

  static const List<_FilterOption> _filters = [
    _FilterOption(label: 'All', type: null, color: AppColors.teal),
    _FilterOption(
        label: 'Brush Pile', type: 'brush_pile', color: AppColors.brushPile),
    _FilterOption(
        label: 'PVC Tree', type: 'pvc_tree', color: AppColors.pvcTree),
    _FilterOption(
        label: 'Stake Bed', type: 'stake_bed', color: AppColors.stakeBed),
    _FilterOption(
        label: 'Pallet', type: 'pallet', color: AppColors.pallet),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(selectedTypeProvider);

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = selectedType == filter.type;

          return GestureDetector(
            onTap: () {
              ref.read(selectedTypeProvider.notifier).state = filter.type;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? filter.color.withValues(alpha: 0.25)
                    : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? filter.color.withValues(alpha: 0.6)
                      : AppColors.cardBorder,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: filter.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? filter.color
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterOption {
  final String label;
  final String? type;
  final Color color;

  const _FilterOption({
    required this.label,
    required this.type,
    required this.color,
  });
}
