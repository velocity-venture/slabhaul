import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';

class SevenDayForecast extends StatelessWidget {
  final List<DailyForecast> daily;

  const SevenDayForecast({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    if (daily.isEmpty) return const SizedBox.shrink();

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.teal, size: 18),
                SizedBox(width: 8),
                Text(
                  '7-Day Forecast',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Daily rows
            ...List.generate(daily.length, (index) {
              final day = daily[index];
              final isLast = index == daily.length - 1;
              return Column(
                children: [
                  _DailyRow(
                    forecast: day,
                    isToday: index == 0,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: AppColors.cardBorder.withValues(alpha: 0.4),
                    ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Single daily forecast row
// ---------------------------------------------------------------------------

class _DailyRow extends StatelessWidget {
  final DailyForecast forecast;
  final bool isToday;

  const _DailyRow({required this.forecast, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final dayFormat = DateFormat('EEE');
    final dayLabel = isToday ? 'Today' : dayFormat.format(forecast.date);
    final icon = weatherIcon(forecast.weatherCode);
    final description = weatherDescription(forecast.weatherCode);
    final hasPrecip = forecast.precipitationMm > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // Day name
          SizedBox(
            width: 50,
            child: Text(
              dayLabel,
              style: TextStyle(
                color: isToday ? AppColors.teal : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Weather icon
          Icon(icon, color: AppColors.textPrimary, size: 20),
          const SizedBox(width: 10),

          // Description + precipitation
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasPrecip)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.water_drop,
                            size: 10, color: AppColors.info),
                        const SizedBox(width: 3),
                        Text(
                          '${forecast.precipitationMm.toStringAsFixed(1)} mm',
                          style: const TextStyle(
                            color: AppColors.info,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // High / Low temps
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${forecast.highF.round()}\u00B0',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                '/',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(width: 4),
              Text(
                '${forecast.lowF.round()}\u00B0',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
