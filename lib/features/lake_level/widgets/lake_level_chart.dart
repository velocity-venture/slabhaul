import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:slabhaul/core/models/lake_conditions.dart';
import 'package:slabhaul/core/utils/constants.dart';
import '../providers/lake_level_providers.dart';

/// Enhanced line chart showing water level history with trend visualization,
/// normal pool reference, and improved styling.
class LakeLevelChart extends StatelessWidget {
  final List<LevelReading> readings;
  final double? normalPool;
  final LevelTrend? trend;
  final int daysToShow;
  final bool showLabels;
  final bool interactive;

  const LakeLevelChart({
    super.key,
    required this.readings,
    this.normalPool,
    this.trend,
    this.daysToShow = 7,
    this.showLabels = true,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) {
      return const Center(
        child: Text(
          'Insufficient data for chart',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    // Filter readings to the requested time range
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: daysToShow));
    final filteredReadings = readings
        .where((r) => r.timestamp.isAfter(cutoff))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (filteredReadings.length < 2) {
      return const Center(
        child: Text(
          'Not enough recent data',
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    // Downsample for performance (one reading per ~6 hours max)
    final sampled = _downsample(filteredReadings, daysToShow * 4);
    final earliest = sampled.first.timestamp;

    // Build spots: x = hours since earliest, y = water level
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

    // Generate day labels for X axis
    final dayLabels = _generateDayLabels(earliest, maxX);

    // Determine line color based on trend
    final lineColor = _getTrendColor(trend);
    final gradientColors = _getGradientColors(trend);

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
          leftTitles: showLabels
              ? AxisTitles(
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
                )
              : const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
          bottomTitles: showLabels
              ? AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    interval: 24,
                    getTitlesWidget: (value, meta) {
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
                )
              : const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
        ),
        borderData: FlBorderData(
          show: true,
          border: const Border(
            bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
            left: BorderSide(color: AppColors.cardBorder, width: 0.5),
          ),
        ),
        lineTouchData: interactive
            ? LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.card,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      // Calculate timestamp from x value
                      final timestamp = earliest.add(
                        Duration(minutes: (spot.x * 60).round()),
                      );
                      final dateStr = DateFormat('MMM d, ha').format(timestamp);

                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(2)} ft\n$dateStr',
                        TextStyle(
                          color: lineColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              )
            : const LineTouchData(enabled: false),

        // Normal pool reference line
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
            color: lineColor,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                // Show dots only for first, last, and every 6th point
                if (index == 0 || index == spots.length - 1 || index % 6 == 0) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: lineColor,
                    strokeWidth: 1,
                    strokeColor: AppColors.surface,
                  );
                }
                return FlDotCirclePainter(
                  radius: 0,
                  color: Colors.transparent,
                  strokeWidth: 0,
                  strokeColor: Colors.transparent,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: gradientColors,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<LevelReading> _downsample(List<LevelReading> data, int targetCount) {
    if (data.length <= targetCount) return data;
    final step = data.length / targetCount;
    final result = <LevelReading>[];
    for (double i = 0; i < data.length; i += step) {
      result.add(data[i.round().clamp(0, data.length - 1)]);
    }
    if (result.last != data.last) {
      result.add(data.last);
    }
    return result;
  }

  Map<double, String> _generateDayLabels(DateTime earliest, double maxX) {
    final dayLabels = <double, String>{};
    final dayFormat = DateFormat('E');
    for (int i = 0; i < daysToShow + 2; i++) {
      final midnight = DateTime(
        earliest.year,
        earliest.month,
        earliest.day + i,
      );
      final hoursFromStart = midnight.difference(earliest).inMinutes / 60.0;
      if (hoursFromStart >= 0 && hoursFromStart <= maxX) {
        dayLabels[hoursFromStart] = dayFormat.format(midnight);
      }
    }
    return dayLabels;
  }

  double _calcInterval(double minY, double maxY) {
    final range = maxY - minY;
    if (range < 0.5) return 0.1;
    if (range < 1.0) return 0.2;
    if (range < 2.0) return 0.5;
    if (range < 5.0) return 1.0;
    return 2.0;
  }

  Color _getTrendColor(LevelTrend? trend) {
    switch (trend) {
      case LevelTrend.rising:
        return AppColors.success;
      case LevelTrend.falling:
        return AppColors.error;
      case LevelTrend.stable:
        return AppColors.teal;
      case LevelTrend.unknown:
      case null:
        return AppColors.teal;
    }
  }

  List<Color> _getGradientColors(LevelTrend? trend) {
    final baseColor = _getTrendColor(trend);
    return [
      baseColor.withValues(alpha: 0.25),
      baseColor.withValues(alpha: 0.0),
    ];
  }
}

/// Range selector chips for the chart
class ChartRangeSelector extends StatelessWidget {
  final LevelHistoryRange selected;
  final ValueChanged<LevelHistoryRange> onChanged;

  const ChartRangeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: LevelHistoryRange.values.map((range) {
        final isSelected = range == selected;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(
              range.label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) onChanged(range);
            },
            selectedColor: AppColors.teal,
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? AppColors.teal : AppColors.cardBorder,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            visualDensity: VisualDensity.compact,
          ),
        );
      }).toList(),
    );
  }
}
