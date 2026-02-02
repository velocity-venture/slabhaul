import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';

class HourlyForecastStrip extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const HourlyForecastStrip({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    // Show next 24 hours.
    final items = hourly.take(24).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(Icons.schedule, color: AppColors.teal, size: 18),
              SizedBox(width: 6),
              Text(
                'Hourly Forecast',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return _HourlyItem(
                forecast: items[index],
                isFirst: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Individual hourly forecast card
// ---------------------------------------------------------------------------

class _HourlyItem extends StatelessWidget {
  final HourlyForecast forecast;
  final bool isFirst;

  const _HourlyItem({required this.forecast, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final hourFormat = DateFormat('ha');
    final timeLabel = isFirst ? 'Now' : hourFormat.format(forecast.time);
    final windColor = windSpeedColor(forecast.windSpeedMph);

    return Container(
      width: 70,
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.teal.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFirst
              ? AppColors.teal.withValues(alpha: 0.4)
              : AppColors.cardBorder.withValues(alpha: 0.5),
          width: isFirst ? 1.0 : 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Time
            Text(
              timeLabel,
              style: TextStyle(
                color: isFirst ? AppColors.teal : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Weather icon (approximate from precipitation)
            Icon(
              _hourlyIcon(forecast),
              color: AppColors.textPrimary,
              size: 22,
            ),

            // Temperature
            Text(
              '${forecast.temperatureF.round()}\u00B0',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Wind speed
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.air, size: 11, color: windColor),
                const SizedBox(width: 2),
                Text(
                  '${forecast.windSpeedMph.round()}',
                  style: TextStyle(
                    color: windColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Determine an appropriate icon from hourly data.
  /// Since HourlyForecast doesn't include a weather code, we infer from
  /// precipitation amount and time of day.
  IconData _hourlyIcon(HourlyForecast h) {
    if (h.precipitationMm > 2.0) return Icons.water_drop;
    if (h.precipitationMm > 0.0) return Icons.grain;
    final hour = h.time.hour;
    if (hour >= 6 && hour < 18) return Icons.wb_sunny;
    return Icons.nights_stay;
  }
}
