import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/moon_phase.dart';

class SunMoonCard extends StatelessWidget {
  final DailyForecast today;

  const SunMoonCard({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('h:mm a');
    final sunriseStr = timeFormat.format(today.sunrise);
    final sunsetStr = timeFormat.format(today.sunset);

    final phase = moonPhase(today.date);
    final phaseName = moonPhaseName(phase);
    final phaseEmoji = moonPhaseEmoji(phase);
    final illumination = moonIllumination(phase);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Sun section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Color(0xFFFBBF24), size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Sun',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _SunRow(
                    icon: Icons.wb_twilight,
                    iconColor: const Color(0xFFFBBF24),
                    label: 'Rise',
                    value: sunriseStr,
                  ),
                  const SizedBox(height: 6),
                  _SunRow(
                    icon: Icons.nights_stay,
                    iconColor: const Color(0xFFF97316),
                    label: 'Set',
                    value: sunsetStr,
                  ),
                ],
              ),
            ),

            // Vertical divider
            Container(
              width: 1,
              height: 70,
              color: AppColors.cardBorder.withValues(alpha: 0.5),
            ),

            // Moon section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          phaseEmoji,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Moon',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      phaseName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${illumination.round()}% illuminated',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small sunrise / sunset row
// ---------------------------------------------------------------------------

class _SunRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _SunRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Text(
          '$label  ',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
