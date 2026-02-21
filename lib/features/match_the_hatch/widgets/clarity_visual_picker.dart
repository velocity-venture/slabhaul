import 'package:flutter/material.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/utils/constants.dart';

class ClarityVisualPicker extends StatelessWidget {
  final WaterClarity? selected;
  final ValueChanged<WaterClarity> onChanged;

  const ClarityVisualPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Water Clarity',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: WaterClarity.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final clarity = WaterClarity.values[index];
              final isSelected = clarity == selected;
              return GestureDetector(
                onTap: () => onChanged(clarity),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _gradientColors(clarity),
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.teal : AppColors.cardBorder,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: Text(
                          _shortLabel(clarity),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppColors.teal : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  List<Color> _gradientColors(WaterClarity clarity) {
    switch (clarity) {
      case WaterClarity.crystalClear:
        return [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)];
      case WaterClarity.clear:
        return [const Color(0xFFCCFBF1), const Color(0xFF99F6E4)];
      case WaterClarity.lightStain:
        return [const Color(0xFFFEF3C7), const Color(0xFFFDE68A)];
      case WaterClarity.stained:
        return [const Color(0xFFFED7AA), const Color(0xFFFB923C)];
      case WaterClarity.muddy:
        return [const Color(0xFFD6D3D1), const Color(0xFF92400E)];
    }
  }

  String _shortLabel(WaterClarity clarity) {
    switch (clarity) {
      case WaterClarity.crystalClear:
        return 'Crystal\nClear';
      case WaterClarity.clear:
        return 'Clear';
      case WaterClarity.lightStain:
        return 'Light\nStain';
      case WaterClarity.stained:
        return 'Stained';
      case WaterClarity.muddy:
        return 'Muddy';
    }
  }
}
