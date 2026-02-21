import 'package:flutter/material.dart';
import '../../../core/models/hatch_recommendation.dart';

class ProTipCard extends StatelessWidget {
  final ProTip tip;

  const ProTipCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              Text(
                'Pro Tip',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\u201C${tip.text}\u201D',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF78350F),
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '\u2014 ${tip.source}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }
}
