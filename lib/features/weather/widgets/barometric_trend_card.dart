import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:slabhaul/core/models/weather_data.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';

class BarometricTrendCard extends StatelessWidget {
  final List<HourlyForecast> hourly;

  const BarometricTrendCard({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    // Extract pressure data for the last 24 entries (or all available).
    final pressureEntries = hourly.take(24).toList();
    final pressures = pressureEntries.map((h) => h.pressureMb).toList();
    final trend = barometricTrend(pressures);
    final trendIcon = barometricTrendIcon(trend);
    final trendColor = barometricTrendColor(trend);

    final currentPressure =
        pressures.isNotEmpty ? pressures.last : 1013.25;
    final currentInHg = mbToInHg(currentPressure);

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                const Icon(Icons.speed, color: AppColors.teal, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Barometric Pressure',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Trend chip
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(trendIcon, color: trendColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        trend,
                        style: TextStyle(
                          color: trendColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Pressure values
            Row(
              children: [
                Text(
                  '${currentPressure.toStringAsFixed(1)} mb',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${currentInHg.toStringAsFixed(2)} inHg',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sparkline chart
            SizedBox(
              height: 80,
              child: _PressureSparkline(pressures: pressures),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pressure sparkline using fl_chart
// ---------------------------------------------------------------------------

class _PressureSparkline extends StatelessWidget {
  final List<double> pressures;

  const _PressureSparkline({required this.pressures});

  @override
  Widget build(BuildContext context) {
    if (pressures.length < 2) {
      return const Center(
        child: Text(
          'Insufficient data',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < pressures.length; i++) {
      spots.add(FlSpot(i.toDouble(), pressures[i]));
    }

    // Calculate min/max for Y axis with some padding.
    final minP =
        pressures.reduce((a, b) => a < b ? a : b) - 1.0;
    final maxP =
        pressures.reduce((a, b) => a > b ? a : b) + 1.0;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.card,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} mb',
                  const TextStyle(
                    color: AppColors.teal,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList();
            },
          ),
        ),
        minX: 0,
        maxX: (pressures.length - 1).toDouble(),
        minY: minP,
        maxY: maxP,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.3,
            color: AppColors.teal,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.teal.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
