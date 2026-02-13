import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';

class CurrentConditionsCard extends StatelessWidget {
  final CurrentWeather weather;

  const CurrentConditionsCard({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final windDir = windCompass(weather.windDirectionDeg);
    final windColor = windSpeedColor(weather.windSpeedMph);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: icon + description
            Row(
              children: [
                Icon(
                  weatherIcon(weather.weatherCode),
                  color: AppColors.amberLight,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    weather.description,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Temperature row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Large temperature
                Text(
                  '${weather.temperatureF.round()}\u00B0F',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 52,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 16),

                // Details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.thermostat,
                        label: 'Feels like',
                        value: '${weather.feelsLikeF.round()}\u00B0F',
                        valueColor: AppColors.textPrimary,
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.water_drop_outlined,
                        label: 'Humidity',
                        value: '${weather.humidity}%',
                        valueColor: AppColors.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Divider
            Container(
              height: 1,
              color: AppColors.cardBorder.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),

            // Wind row
            Row(
              children: [
                // Wind direction icon (rotated arrow)
                Transform.rotate(
                  angle: weather.windDirectionDeg * 3.14159265 / 180,
                  child: Icon(
                    Icons.navigation,
                    color: windColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Wind',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: windColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${weather.windSpeedMph.round()} mph $windDir',
                    style: TextStyle(
                      color: windColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  windSpeedLabel(weather.windSpeedMph),
                  style: TextStyle(
                    color: windColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small icon + label + value row
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
