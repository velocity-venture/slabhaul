import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Horizontally scrollable row of lake chips.
///
/// The first chip is always "All Lakes". When a lake is selected its chip turns
/// teal; unselected chips use the card color.
class LakeSelector extends ConsumerWidget {
  const LakeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lakesAsync = ref.watch(lakesProvider);
    final selectedLake = ref.watch(selectedLakeProvider);

    return lakesAsync.when(
      data: (lakes) {
        return SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: lakes.length + 1, // +1 for "All Lakes"
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              if (index == 0) {
                final isSelected = selectedLake == null;
                return _LakeChip(
                  label: 'All Lakes',
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(selectedLakeProvider.notifier).state = null;
                  },
                );
              }

              final lake = lakes[index - 1];
              final isSelected = selectedLake == lake.id;

              return _LakeChip(
                label: lake.name,
                isSelected: isSelected,
                onTap: () {
                  ref.read(selectedLakeProvider.notifier).state = lake.id;
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.teal,
            ),
          ),
        ),
      ),
      error: (e, _) => SizedBox(
        height: 44,
        child: Center(
          child: Text(
            'Failed to load lakes',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _LakeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LakeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.cardBorder,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
