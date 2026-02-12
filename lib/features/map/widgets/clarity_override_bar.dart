import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/features/map/providers/clarity_override_provider.dart';
import 'package:slabhaul/shared/widgets/glass_container.dart';

/// A row of choice chips inside a glass container that lets the user
/// override the computed water-clarity level on the map.
class ClarityOverrideBar extends ConsumerWidget {
  const ClarityOverrideBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(manualClarityOverrideProvider);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      borderRadius: 12,
      opacity: 0.20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ClarityChip(
            label: 'Auto',
            selected: override == null,
            color: Colors.white,
            onTap: () => ref
                .read(manualClarityOverrideProvider.notifier)
                .state = null,
          ),
          const SizedBox(width: 6),
          _ClarityChip(
            label: 'Clear',
            selected: override == ClarityLevel.clear,
            color: Color(ClarityLevel.clear.mapColor),
            onTap: () => ref
                .read(manualClarityOverrideProvider.notifier)
                .state = ClarityLevel.clear,
          ),
          const SizedBox(width: 6),
          _ClarityChip(
            label: 'Stained',
            selected: override == ClarityLevel.stained,
            color: Color(ClarityLevel.stained.mapColor),
            onTap: () => ref
                .read(manualClarityOverrideProvider.notifier)
                .state = ClarityLevel.stained,
          ),
          const SizedBox(width: 6),
          _ClarityChip(
            label: 'Muddy',
            selected: override == ClarityLevel.muddy,
            color: Color(ClarityLevel.muddy.mapColor),
            onTap: () => ref
                .read(manualClarityOverrideProvider.notifier)
                .state = ClarityLevel.muddy,
          ),
        ],
      ),
    );
  }
}

class _ClarityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _ClarityChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : Colors.white24,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? color : Colors.white70,
          ),
        ),
      ),
    );
  }
}
