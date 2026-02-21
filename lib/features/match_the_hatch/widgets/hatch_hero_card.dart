import 'package:flutter/material.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/models/hatch_recommendation.dart';
import '../../../core/utils/constants.dart';

class HatchHeroCard extends StatelessWidget {
  final HatchBaitPick pick;

  const HatchHeroCard({super.key, required this.pick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.brandIndigo, Color(0xFF3B5998)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandIndigo.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                pick.baitCategory.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOP PICK',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0x99FFFFFF),
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      pick.baitCategory.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              _confidenceBadge(pick.confidence),
            ],
          ),
          const SizedBox(height: 16),

          // Detail grid
          Row(
            children: [
              Expanded(child: _detail('Size', pick.baitSize)),
              Expanded(child: _detail('Weight', pick.jigWeight)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _detail('Color', pick.colorName)),
              Expanded(child: _detail('Category', pick.colorCategory.displayName)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _detail('Speed', pick.speed.displayName)),
              Expanded(child: _detail('Depth', pick.depthRange)),
            ],
          ),
          const SizedBox(height: 12),

          // Technique
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TECHNIQUE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: Color(0x99FFFFFF),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  pick.technique,
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Reasons
          if (pick.reasons.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...pick.reasons.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('  \u2022 ', style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12)),
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(fontSize: 12, color: Color(0xCCFFFFFF)),
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

  Widget _detail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Color(0x80FFFFFF),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _confidenceBadge(double confidence) {
    final pct = (confidence * 100).round();
    final color = confidence >= 0.75
        ? const Color(0xFF34D399)
        : confidence >= 0.5
            ? const Color(0xFFFBBF24)
            : const Color(0xFFF87171);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        '$pct%',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
