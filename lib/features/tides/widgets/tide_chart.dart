import 'package:flutter/material.dart';
import '../../../core/models/tides_data.dart';
import '../../../core/utils/constants.dart';

/// Full tide chart widget showing 48-hour tide predictions.
/// 
/// Displays:
/// - Sine-wave style tide curve
/// - High/low tide markers
/// - Current time indicator
/// - Fishing window highlights
class TideChart extends StatelessWidget {
  final List<TideReading> hourlyPredictions;
  final List<TidePrediction> predictions;
  final List<TideFishingWindow> fishingWindows;
  final double? currentHeight;

  const TideChart({
    super.key,
    required this.hourlyPredictions,
    required this.predictions,
    this.fishingWindows = const [],
    this.currentHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyPredictions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildChart(),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waves, color: AppColors.textMuted, size: 40),
            SizedBox(height: 12),
            Text(
              'No tide data available',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.waves, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '48-HOUR TIDE FORECAST',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Tap for details',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: CustomPaint(
        painter: _TideChartPainter(
          hourlyPredictions: hourlyPredictions,
          predictions: predictions,
          fishingWindows: fishingWindows,
          currentHeight: currentHeight,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(AppColors.success, 'Excellent'),
          const SizedBox(width: 16),
          _legendItem(AppColors.info, 'Good'),
          const SizedBox(width: 16),
          _legendItem(AppColors.textMuted, 'Slack'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// Custom painter for the tide chart.
class _TideChartPainter extends CustomPainter {
  final List<TideReading> hourlyPredictions;
  final List<TidePrediction> predictions;
  final List<TideFishingWindow> fishingWindows;
  final double? currentHeight;

  _TideChartPainter({
    required this.hourlyPredictions,
    required this.predictions,
    required this.fishingWindows,
    this.currentHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyPredictions.isEmpty) return;

    final rect = Rect.fromLTWH(40, 10, size.width - 50, size.height - 40);
    
    // Find height range
    double minHeight = double.infinity;
    double maxHeight = double.negativeInfinity;
    for (final reading in hourlyPredictions) {
      if (reading.heightFt < minHeight) minHeight = reading.heightFt;
      if (reading.heightFt > maxHeight) maxHeight = reading.heightFt;
    }
    
    // Add padding to range
    final range = maxHeight - minHeight;
    minHeight -= range * 0.1;
    maxHeight += range * 0.1;

    // Time range
    final startTime = hourlyPredictions.first.timestamp;
    final endTime = hourlyPredictions.last.timestamp;
    final timeRange = endTime.difference(startTime).inMinutes.toDouble();

    // Helper functions
    double timeToX(DateTime time) {
      final minutes = time.difference(startTime).inMinutes.toDouble();
      return rect.left + (minutes / timeRange) * rect.width;
    }

    double heightToY(double height) {
      final normalized = (height - minHeight) / (maxHeight - minHeight);
      return rect.bottom - normalized * rect.height;
    }

    // Draw fishing windows background
    for (final window in fishingWindows) {
      if (window.end.isBefore(startTime) || window.start.isAfter(endTime)) {
        continue;
      }

      final windowStart = window.start.isBefore(startTime) ? startTime : window.start;
      final windowEnd = window.end.isAfter(endTime) ? endTime : window.end;

      Color color;
      switch (window.rating) {
        case TideFishingRating.excellent:
          color = AppColors.success;
          break;
        case TideFishingRating.good:
          color = AppColors.info;
          break;
        case TideFishingRating.fair:
          color = AppColors.warning;
          break;
        case TideFishingRating.poor:
          color = AppColors.textMuted;
          break;
      }

      final windowRect = Rect.fromLTRB(
        timeToX(windowStart),
        rect.top,
        timeToX(windowEnd),
        rect.bottom,
      );

      canvas.drawRect(
        windowRect,
        Paint()..color = color.withOpacity(0.15),
      );
    }

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.cardBorder.withOpacity(0.3)
      ..strokeWidth = 1;

    // Horizontal grid lines (height)
    const numHLines = 4;
    for (int i = 0; i <= numHLines; i++) {
      final y = rect.top + (rect.height * i / numHLines);
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), gridPaint);
    }

    // Vertical grid lines (time) - every 6 hours
    final now = DateTime.now();
    var gridTime = DateTime(startTime.year, startTime.month, startTime.day, 
        ((startTime.hour / 6).ceil()) * 6);
    while (gridTime.isBefore(endTime)) {
      final x = timeToX(gridTime);
      if (x >= rect.left && x <= rect.right) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), gridPaint);
        
        // Draw time label
        final hour = gridTime.hour;
        final label = hour == 0 
            ? '${gridTime.month}/${gridTime.day}'
            : '${hour > 12 ? hour - 12 : hour}${hour >= 12 ? 'P' : 'A'}';
        
        final textPainter = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, rect.bottom + 4));
      }
      gridTime = gridTime.add(const Duration(hours: 6));
    }

    // Draw tide curve
    final curvePath = Path();
    bool firstPoint = true;

    for (final reading in hourlyPredictions) {
      final x = timeToX(reading.timestamp);
      final y = heightToY(reading.heightFt);

      if (firstPoint) {
        curvePath.moveTo(x, y);
        firstPoint = false;
      } else {
        curvePath.lineTo(x, y);
      }
    }

    // Draw filled area under curve
    final fillPath = Path.from(curvePath);
    fillPath.lineTo(timeToX(endTime), rect.bottom);
    fillPath.lineTo(rect.left, rect.bottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = AppColors.info.withOpacity(0.2),
    );

    // Draw curve line
    canvas.drawPath(
      curvePath,
      Paint()
        ..color = AppColors.info
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Draw high/low markers
    for (final pred in predictions) {
      if (pred.timestamp.isBefore(startTime) || pred.timestamp.isAfter(endTime)) {
        continue;
      }

      final x = timeToX(pred.timestamp);
      final y = heightToY(pred.heightFt);

      // Marker circle
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = pred.isHigh ? AppColors.warning : AppColors.info,
      );
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.surface,
      );

      // Label
      final label = pred.isHigh ? 'H' : 'L';
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: pred.isHigh ? AppColors.warning : AppColors.info,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - 18),
      );

      // Height label
      final heightPainter = TextPainter(
        text: TextSpan(
          text: '${pred.heightFt.toStringAsFixed(1)}\'',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 8,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      heightPainter.layout();
      heightPainter.paint(
        canvas,
        Offset(x - heightPainter.width / 2, y + (pred.isHigh ? -30 : 10)),
      );
    }

    // Draw current time marker
    if (now.isAfter(startTime) && now.isBefore(endTime)) {
      final nowX = timeToX(now);

      // Vertical line
      canvas.drawLine(
        Offset(nowX, rect.top),
        Offset(nowX, rect.bottom),
        Paint()
          ..color = AppColors.teal
          ..strokeWidth = 2,
      );

      // NOW label
      final nowPainter = TextPainter(
        text: const TextSpan(
          text: 'NOW',
          style: TextStyle(
            color: AppColors.teal,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      nowPainter.layout();
      
      // Background for NOW label
      final labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          nowX - nowPainter.width / 2 - 4,
          rect.top - 14,
          nowPainter.width + 8,
          14,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(labelRect, Paint()..color = AppColors.teal);
      
      nowPainter.paint(
        canvas,
        Offset(nowX - nowPainter.width / 2, rect.top - 12),
      );

      // Current height marker on curve
      if (currentHeight != null) {
        final currentY = heightToY(currentHeight!);
        canvas.drawCircle(
          Offset(nowX, currentY),
          5,
          Paint()..color = AppColors.teal,
        );
        canvas.drawCircle(
          Offset(nowX, currentY),
          3,
          Paint()..color = Colors.white,
        );
      }
    }

    // Draw Y-axis labels (height)
    for (int i = 0; i <= numHLines; i++) {
      final height = maxHeight - (i * (maxHeight - minHeight) / numHLines);
      final y = rect.top + (rect.height * i / numHLines);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${height.toStringAsFixed(1)}\'',
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _TideChartPainter oldDelegate) {
    return hourlyPredictions != oldDelegate.hourlyPredictions ||
        predictions != oldDelegate.predictions ||
        fishingWindows != oldDelegate.fishingWindows ||
        currentHeight != oldDelegate.currentHeight;
  }
}

/// Compact mini tide chart for dashboard use.
class TideMiniChart extends StatelessWidget {
  final List<TideReading> hourlyPredictions;
  final double? currentHeight;

  const TideMiniChart({
    super.key,
    required this.hourlyPredictions,
    this.currentHeight,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyPredictions.isEmpty) {
      return const SizedBox(height: 60);
    }

    return SizedBox(
      height: 60,
      child: CustomPaint(
        painter: _TideMiniChartPainter(
          hourlyPredictions: hourlyPredictions,
          currentHeight: currentHeight,
        ),
        size: Size.infinite,
      ),
    );
  }
}

/// Simple mini chart painter.
class _TideMiniChartPainter extends CustomPainter {
  final List<TideReading> hourlyPredictions;
  final double? currentHeight;

  _TideMiniChartPainter({
    required this.hourlyPredictions,
    this.currentHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyPredictions.isEmpty) return;

    final rect = Rect.fromLTWH(0, 5, size.width, size.height - 10);

    // Find height range
    double minHeight = double.infinity;
    double maxHeight = double.negativeInfinity;
    for (final reading in hourlyPredictions) {
      if (reading.heightFt < minHeight) minHeight = reading.heightFt;
      if (reading.heightFt > maxHeight) maxHeight = reading.heightFt;
    }

    final range = maxHeight - minHeight;
    minHeight -= range * 0.1;
    maxHeight += range * 0.1;

    // Draw curve
    final path = Path();
    bool first = true;

    for (int i = 0; i < hourlyPredictions.length; i++) {
      final reading = hourlyPredictions[i];
      final x = rect.left + (i / (hourlyPredictions.length - 1)) * rect.width;
      final normalized = (reading.heightFt - minHeight) / (maxHeight - minHeight);
      final y = rect.bottom - normalized * rect.height;

      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Fill
    final fillPath = Path.from(path);
    fillPath.lineTo(rect.right, rect.bottom);
    fillPath.lineTo(rect.left, rect.bottom);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()..color = AppColors.info.withOpacity(0.2),
    );

    // Line
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.info
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _TideMiniChartPainter oldDelegate) {
    return hourlyPredictions != oldDelegate.hourlyPredictions;
  }
}
