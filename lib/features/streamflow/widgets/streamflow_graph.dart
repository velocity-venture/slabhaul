import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:slabhaul/core/models/streamflow_data.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// 7-day streamflow history graph with trend visualization.
class StreamflowGraph extends StatelessWidget {
  final List<StreamflowReading> readings;
  final double? historicalMedian;

  const StreamflowGraph({
    super.key,
    required this.readings,
    this.historicalMedian,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            'No historical data available',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    // Sort readings by time
    final sortedReadings = List<StreamflowReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Calculate min/max for Y axis
    final flows = sortedReadings.map((r) => r.flowRateCfs).toList();
    var minY = flows.reduce((a, b) => a < b ? a : b);
    var maxY = flows.reduce((a, b) => a > b ? a : b);

    // Include median in range if available
    if (historicalMedian != null) {
      minY = minY < historicalMedian! ? minY : historicalMedian!;
      maxY = maxY > historicalMedian! ? maxY : historicalMedian!;
    }

    // Add padding
    final range = maxY - minY;
    minY = (minY - range * 0.1).clamp(0, double.infinity);
    maxY = maxY + range * 0.1;

    // Ensure minimum range
    if (maxY - minY < 50) {
      maxY = minY + 50;
    }

    // Convert to spots
    final spots = <FlSpot>[];
    final startTime = sortedReadings.first.timestamp;

    for (final reading in sortedReadings) {
      final hours = reading.timestamp.difference(startTime).inHours.toDouble();
      spots.add(FlSpot(hours, reading.flowRateCfs));
    }

    // Calculate gradient colors based on flow trend
    final firstFlow = sortedReadings.first.flowRateCfs;
    final lastFlow = sortedReadings.last.flowRateCfs;
    final isRising = lastFlow > firstFlow * 1.1;
    final isFalling = lastFlow < firstFlow * 0.9;

    Color lineColor;
    List<Color> gradientColors;
    if (isRising) {
      lineColor = AppColors.success;
      gradientColors = [
        AppColors.success.withValues(alpha: 0.3),
        AppColors.success.withValues(alpha: 0.0),
      ];
    } else if (isFalling) {
      lineColor = AppColors.warning;
      gradientColors = [
        AppColors.warning.withValues(alpha: 0.3),
        AppColors.warning.withValues(alpha: 0.0),
      ];
    } else {
      lineColor = AppColors.info;
      gradientColors = [
        AppColors.info.withValues(alpha: 0.3),
        AppColors.info.withValues(alpha: 0.0),
      ];
    }

    return Container(
      height: 180,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.cardBorder.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 24,
                getTitlesWidget: (value, meta) {
                  final daysAgo = ((spots.last.x - value) / 24).round();
                  if (daysAgo == 0) return const Text('Now', style: _labelStyle);
                  if (daysAgo == 7) return const Text('7d', style: _labelStyle);
                  if (daysAgo % 2 == 0 && daysAgo > 0 && daysAgo < 7) {
                    return Text('${daysAgo}d', style: _labelStyle);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _formatFlow(value),
                      style: _labelStyle,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            // Main flow line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: lineColor,
              barWidth: 2.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
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
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              // Historical median line (if available)
              if (historicalMedian != null)
                HorizontalLine(
                  y: historicalMedian!,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                    labelResolver: (_) => 'Median',
                  ),
                ),
            ],
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final hours = spot.x;
                  final reading = sortedReadings.firstWhere(
                    (r) => r.timestamp.difference(startTime).inHours.toDouble() == hours,
                    orElse: () => sortedReadings.first,
                  );
                  return LineTooltipItem(
                    '${_formatFlow(spot.y)}\n${_formatDateTime(reading.timestamp)}',
                    const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  static const _labelStyle = TextStyle(
    color: AppColors.textMuted,
    fontSize: 10,
  );

  String _formatFlow(double flow) {
    if (flow >= 10000) {
      return '${(flow / 1000).toStringAsFixed(1)}K';
    }
    if (flow >= 1000) {
      return flow.toStringAsFixed(0);
    }
    return flow.toStringAsFixed(0);
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    }
    
    final days = diff.inDays;
    return '${days}d ago';
  }
}

/// Compact flow trend indicator.
class FlowTrendIndicator extends StatelessWidget {
  final FlowTrend trend;
  final double? changePercent;

  const FlowTrendIndicator({
    super.key,
    required this.trend,
    this.changePercent,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    String label;

    switch (trend) {
      case FlowTrend.rising:
        icon = Icons.trending_up;
        color = AppColors.success;
        label = 'Rising';
        break;
      case FlowTrend.falling:
        icon = Icons.trending_down;
        color = AppColors.warning;
        label = 'Falling';
        break;
      case FlowTrend.stable:
        icon = Icons.trending_flat;
        color = AppColors.textSecondary;
        label = 'Stable';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (changePercent != null) ...[
            const SizedBox(width: 4),
            Text(
              '${changePercent! >= 0 ? '+' : ''}${changePercent!.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Mini sparkline for use in lists or compact views.
class FlowSparkline extends StatelessWidget {
  final List<StreamflowReading> readings;
  final double width;
  final double height;

  const FlowSparkline({
    super.key,
    required this.readings,
    this.width = 60,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) {
      return SizedBox(width: width, height: height);
    }

    final sortedReadings = List<StreamflowReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final flows = sortedReadings.map((r) => r.flowRateCfs).toList();
    final minY = flows.reduce((a, b) => a < b ? a : b);
    final maxY = flows.reduce((a, b) => a > b ? a : b);
    final range = maxY - minY;

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedReadings.length; i++) {
      spots.add(FlSpot(i.toDouble(), sortedReadings[i].flowRateCfs));
    }

    final isRising = flows.last > flows.first * 1.1;
    final isFalling = flows.last < flows.first * 0.9;
    final color = isRising
        ? AppColors.success
        : isFalling
            ? AppColors.warning
            : AppColors.info;

    return SizedBox(
      width: width,
      height: height,
      child: LineChart(
        LineChartData(
          minY: minY - range * 0.1,
          maxY: maxY + range * 0.1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: color,
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
