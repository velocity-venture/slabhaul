import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/wind_providers.dart';

/// Horizontal time slider for selecting wind forecast time.
/// Shows 2 days history + 7 days forecast.
class WindForecastSlider extends ConsumerStatefulWidget {
  const WindForecastSlider({super.key});

  @override
  ConsumerState<WindForecastSlider> createState() => _WindForecastSliderState();
}

class _WindForecastSliderState extends ConsumerState<WindForecastSlider> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    // Start at "now" position (2 days = 48 hours into the range)
    _sliderValue = 48.0;
  }

  @override
  Widget build(BuildContext context) {
    final windEnabled = ref.watch(windEnabledProvider);
    final timeRange = ref.watch(windTimeRangeProvider);
    final forecast = ref.watch(windForecastProvider).valueOrNull;
    final timeLabel = ref.watch(windTimeLabelProvider);
    final timeMode = ref.watch(windTimeDisplayModeProvider);

    if (!windEnabled || timeRange == null || forecast == null) {
      return const SizedBox.shrink();
    }

    final (earliest, latest) = timeRange;
    final totalHours = latest.difference(earliest).inHours.toDouble();
    
    // Ensure slider value is within range
    if (_sliderValue > totalHours) {
      _sliderValue = totalHours;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with time label and reset button
          Row(
            children: [
              Icon(
                _getModeIcon(timeMode),
                size: 16,
                color: _getModeColor(timeMode),
              ),
              const SizedBox(width: 6),
              Text(
                timeLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getModeColor(timeMode),
                ),
              ),
              const Spacer(),
              // Reset to Now button
              if (timeMode != WindTimeMode.current)
                GestureDetector(
                  onTap: _resetToNow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Now',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Wind speed mini-graph preview
          SizedBox(
            height: 40,
            child: _WindSpeedGraph(
              forecast: forecast,
              currentHour: _sliderValue,
              totalHours: totalHours,
            ),
          ),
          const SizedBox(height: 4),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: AppColors.teal,
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: AppColors.teal,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              overlayColor: AppColors.teal.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: _sliderValue.clamp(0, totalHours),
              min: 0,
              max: totalHours,
              divisions: totalHours.toInt(),
              onChanged: (value) {
                setState(() {
                  _sliderValue = value;
                });
                _updateSelectedTime(earliest, value);
              },
            ),
          ),
          
          // Time labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-2 days',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                'Now',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '+7 days',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateSelectedTime(DateTime earliest, double hours) {
    final selectedTime = earliest.add(Duration(hours: hours.round()));
    final now = DateTime.now();
    
    // If within 1 hour of now, treat as "current"
    if ((selectedTime.difference(now).inMinutes).abs() < 60) {
      ref.read(selectedWindTimeProvider.notifier).state = null;
    } else {
      ref.read(selectedWindTimeProvider.notifier).state = selectedTime;
    }
  }

  void _resetToNow() {
    setState(() {
      _sliderValue = 48.0; // 2 days = 48 hours
    });
    ref.read(selectedWindTimeProvider.notifier).state = null;
  }

  IconData _getModeIcon(WindTimeMode mode) {
    switch (mode) {
      case WindTimeMode.historical:
        return Icons.history;
      case WindTimeMode.current:
        return Icons.air;
      case WindTimeMode.forecast:
        return Icons.schedule;
    }
  }

  Color _getModeColor(WindTimeMode mode) {
    switch (mode) {
      case WindTimeMode.historical:
        return AppColors.info;
      case WindTimeMode.current:
        return AppColors.teal;
      case WindTimeMode.forecast:
        return AppColors.warning;
    }
  }
}

/// Mini graph showing wind speed variation over the forecast period.
class _WindSpeedGraph extends StatelessWidget {
  final dynamic forecast;
  final double currentHour;
  final double totalHours;

  const _WindSpeedGraph({
    required this.forecast,
    required this.currentHour,
    required this.totalHours,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WindGraphPainter(
        hourlyData: forecast.hourly,
        currentHour: currentHour,
        totalHours: totalHours,
      ),
      size: const Size(double.infinity, 40),
    );
  }
}

class _WindGraphPainter extends CustomPainter {
  final List<dynamic> hourlyData;
  final double currentHour;
  final double totalHours;

  _WindGraphPainter({
    required this.hourlyData,
    required this.currentHour,
    required this.totalHours,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (hourlyData.isEmpty) return;

    // Find max speed for scaling
    double maxSpeed = 0;
    for (final hour in hourlyData) {
      if (hour.speedMph > maxSpeed) maxSpeed = hour.speedMph;
    }
    maxSpeed = maxSpeed.clamp(10, 50); // Minimum scale of 10 mph

    // Draw the graph
    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < hourlyData.length; i++) {
      final x = (i / hourlyData.length) * size.width;
      final y = size.height - (hourlyData[i].speedMph / maxSpeed) * size.height * 0.9;
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    // Fill gradient
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.teal.withValues(alpha: 0.3),
          AppColors.teal.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Line
    final linePaint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, linePaint);

    // Current position indicator
    final indicatorX = (currentHour / totalHours) * size.width;
    final indicatorPaint = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(indicatorX, 0),
      Offset(indicatorX, size.height),
      indicatorPaint,
    );

    // "Now" line (at 48 hours, which is 2 days in)
    final nowX = (48 / totalHours) * size.width;
    final nowPaint = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(nowX, 0),
      Offset(nowX, size.height),
      nowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WindGraphPainter oldDelegate) {
    return oldDelegate.currentHour != currentHour ||
        oldDelegate.hourlyData.length != hourlyData.length;
  }
}

/// Compact version of the wind forecast slider for smaller screens.
class WindForecastSliderCompact extends ConsumerWidget {
  const WindForecastSliderCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windEnabled = ref.watch(windEnabledProvider);
    final timeLabel = ref.watch(windTimeLabelProvider);
    final timeMode = ref.watch(windTimeDisplayModeProvider);
    final conditions = ref.watch(activeWindConditionsProvider).valueOrNull;

    if (!windEnabled || conditions == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timeMode == WindTimeMode.current 
                ? Icons.air 
                : (timeMode == WindTimeMode.historical ? Icons.history : Icons.schedule),
            size: 16,
            color: _getModeColor(timeMode),
          ),
          const SizedBox(width: 6),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${conditions.speedMph.toStringAsFixed(1)} mph ${conditions.compassDirection}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _speedColor(conditions.speedMph),
                ),
              ),
              Text(
                timeLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getModeColor(WindTimeMode mode) {
    switch (mode) {
      case WindTimeMode.historical:
        return AppColors.info;
      case WindTimeMode.current:
        return AppColors.teal;
      case WindTimeMode.forecast:
        return AppColors.warning;
    }
  }

  Color _speedColor(double mph) {
    if (mph < 5) return AppColors.windCalm;
    if (mph < 12) return AppColors.windModerate;
    if (mph < 20) return AppColors.windStrong;
    return AppColors.windDangerous;
  }
}
