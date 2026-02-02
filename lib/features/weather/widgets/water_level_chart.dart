import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:slabhaul/core/models/lake_conditions.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// A line chart showing 7 days of water level readings with an optional
/// normal pool reference line.
class WaterLevelChart extends StatelessWidget {
  final List<LevelReading> readings;
  final double? normalPool;

  const WaterLevelChart({
    super.key,
    required this.readings,
    this.normalPool,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) {
      return const Center(
        child: Text(
          'Insufficient data',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    // Downsample readings to one per ~6 hours for a cleaner chart.
    final sampled = _downsample(readings, 28);
    final earliest = sampled.first.timestamp;

    // Build spots: x = hours since earliest reading, y = water level
    final spots = <FlSpot>[];
    for (final r in sampled) {
      final hours = r.timestamp.difference(earliest).inMinutes / 60.0;
      spots.add(FlSpot(hours, r.valueFt));
    }

    // Y axis bounds with padding
    final allValues = sampled.map((r) => r.valueFt).toList();
    if (normalPool != null) allValues.add(normalPool!);
    final minY = allValues.reduce((a, b) => a < b ? a : b) - 0.3;
    final maxY = allValues.reduce((a, b) => a > b ? a : b) + 0.3;

    final maxX = spots.last.x;

    // Generate day labels for the X axis.
    // We place labels at midnight boundaries.
    final dayLabels = <double, String>{};
    final dayFormat = DateFormat('E');
    for (int i = 0; i < 8; i++) {
      final midnight = DateTime(earliest.year, earliest.month,
          earliest.day + i);
      final hoursFromStart =
          midnight.difference(earliest).inMinutes / 60.0;
      if (hoursFromStart >= 0 && hoursFromStart <= maxX) {
        dayLabels[hoursFromStart] = dayFormat.format(midnight);
      }
    }

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calcInterval(minY, maxY),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.cardBorder.withValues(alpha: 0.3),
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 48,
              interval: _calcInterval(minY, maxY),
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 24,
              getTitlesWidget: (value, meta) {
                // Find closest day label
                String? label;
                for (final entry in dayLabels.entries) {
                  if ((entry.key - value).abs() < 6) {
                    label = entry.value;
                    break;
                  }
                }
                if (label == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
            left: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => AppColors.card,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(2)} ft',
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
        extraLinesData: normalPool != null
            ? ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: normalPool!,
                    color: AppColors.textMuted.withValues(alpha: 0.6),
                    strokeWidth: 1.5,
                    dashArray: [6, 4],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      padding: const EdgeInsets.only(right: 4, bottom: 2),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                      ),
                      labelResolver: (_) => 'Normal Pool',
                    ),
                  ),
                ],
              )
            : null,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.teal,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal.withValues(alpha: 0.2),
                  AppColors.teal.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Downsample readings by picking evenly spaced entries.
  List<LevelReading> _downsample(List<LevelReading> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    final result = <LevelReading>[];
    for (double i = 0; i < data.length; i += step) {
      result.add(data[i.round().clamp(0, data.length - 1)]);
    }
    // Always include the last reading.
    if (result.last != data.last) {
      result.add(data.last);
    }
    return result;
  }

  /// Calculate a reasonable Y axis interval.
  double _calcInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range < 0.5) return 0.1;
    if (range < 1.0) return 0.2;
    if (range < 2.0) return 0.5;
    if (range < 5.0) return 1.0;
    return 2.0;
  }
}
