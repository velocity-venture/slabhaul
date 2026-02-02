import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/generation_data.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// 7-day generation history chart showing when generators were running
class GenerationHistoryGraph extends StatefulWidget {
  final List<GenerationReading> readings;
  final double? baseflow;
  final int daysToShow;
  final bool showLabels;
  final bool interactive;

  const GenerationHistoryGraph({
    super.key,
    required this.readings,
    this.baseflow,
    this.daysToShow = 7,
    this.showLabels = true,
    this.interactive = true,
  });

  @override
  State<GenerationHistoryGraph> createState() => _GenerationHistoryGraphState();
}

class _GenerationHistoryGraphState extends State<GenerationHistoryGraph> {
  int? _hoveredIndex;
  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.readings.isEmpty) {
      return _EmptyState();
    }

    // Sample readings to reasonable chart width (one per hour)
    final sampled = _sampleReadings(widget.readings, widget.daysToShow * 24);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tooltip for hovered bar
        if (_hoveredIndex != null && _hoveredIndex! < sampled.length)
          _HoverTooltip(reading: sampled[_hoveredIndex!]),
        
        // Chart area
        SizedBox(
          height: 120,
          child: GestureDetector(
            onHorizontalDragUpdate: widget.interactive
                ? (details) {
                    setState(() {
                      _scrollOffset -= details.delta.dx;
                      _scrollOffset = _scrollOffset.clamp(
                        0.0,
                        (sampled.length * 6.0 - MediaQuery.of(context).size.width + 64).clamp(0.0, double.infinity),
                      );
                    });
                  }
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // Background grid
                    _BackgroundGrid(
                      daysToShow: widget.daysToShow,
                      width: constraints.maxWidth,
                    ),
                    
                    // Bar chart
                    _BarChart(
                      readings: sampled,
                      baseflow: widget.baseflow,
                      width: constraints.maxWidth,
                      onHover: widget.interactive
                          ? (index) => setState(() => _hoveredIndex = index)
                          : null,
                      hoveredIndex: _hoveredIndex,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        
        // Time labels
        if (widget.showLabels) ...[
          const SizedBox(height: 4),
          _TimeLabels(
            readings: sampled,
            daysToShow: widget.daysToShow,
          ),
        ],
        
        // Legend
        const SizedBox(height: 8),
        _Legend(),
      ],
    );
  }

  List<GenerationReading> _sampleReadings(
    List<GenerationReading> readings,
    int targetCount,
  ) {
    if (readings.length <= targetCount) return readings;

    final step = readings.length / targetCount;
    final sampled = <GenerationReading>[];

    for (var i = 0.0; i < readings.length; i += step) {
      sampled.add(readings[i.floor()]);
    }

    return sampled;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'No generation data available',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HoverTooltip extends StatelessWidget {
  final GenerationReading reading;

  const _HoverTooltip({required this.reading});

  @override
  Widget build(BuildContext context) {
    final time = reading.timestamp;
    final timeStr = _formatTime(time);
    final flowStr = '${reading.dischargeCfs.toStringAsFixed(0)} cfs';
    final statusStr = reading.isGenerating
        ? '${reading.generatorCount ?? '?'} generators'
        : 'Idle';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _intensityColor(reading.intensityLevel),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$timeStr  •  $flowStr  •  $statusStr',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final isToday = dt.day == DateTime.now().day;
    final dayStr = isToday ? 'Today' : _dayName(dt.weekday);
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$dayStr $hour$ampm';
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

class _BackgroundGrid extends StatelessWidget {
  final int daysToShow;
  final double width;

  const _BackgroundGrid({
    required this.daysToShow,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, 120),
      painter: _GridPainter(daysToShow: daysToShow),
    );
  }
}

class _GridPainter extends CustomPainter {
  final int daysToShow;

  _GridPainter({required this.daysToShow});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cardBorder.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Horizontal lines
    for (var i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines for each day
    for (var i = 0; i <= daysToShow; i++) {
      final x = (size.width / daysToShow) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BarChart extends StatelessWidget {
  final List<GenerationReading> readings;
  final double? baseflow;
  final double width;
  final Function(int?)? onHover;
  final int? hoveredIndex;

  const _BarChart({
    required this.readings,
    this.baseflow,
    required this.width,
    this.onHover,
    this.hoveredIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    // Find max for scaling
    final maxDischarge = readings
        .map((r) => r.dischargeCfs)
        .reduce((a, b) => a > b ? a : b);

    final barWidth = (width / readings.length).clamp(2.0, 8.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(readings.length, (index) {
        final reading = readings[index];
        final heightPct = (reading.dischargeCfs / maxDischarge).clamp(0.05, 1.0);
        final isHovered = hoveredIndex == index;
        final color = _intensityColor(reading.intensityLevel);

        return GestureDetector(
          onTapDown: (_) => onHover?.call(index),
          onTapUp: (_) => onHover?.call(null),
          onTapCancel: () => onHover?.call(null),
          child: MouseRegion(
            onEnter: (_) => onHover?.call(index),
            onExit: (_) => onHover?.call(null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: barWidth - 1,
              height: 120 * heightPct,
              decoration: BoxDecoration(
                color: isHovered ? color : color.withValues(alpha: 0.8),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(barWidth > 4 ? 2 : 1),
                ),
                boxShadow: isHovered
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _TimeLabels extends StatelessWidget {
  final List<GenerationReading> readings;
  final int daysToShow;

  const _TimeLabels({
    required this.readings,
    required this.daysToShow,
  });

  @override
  Widget build(BuildContext context) {
    // Show labels for each day
    final labels = <String>[];
    final now = DateTime.now();

    for (var i = daysToShow - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      if (i == 0) {
        labels.add('Today');
      } else if (i == 1) {
        labels.add('Yesterday');
      } else {
        labels.add(_dayName(day.weekday));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map((label) => Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
              ))
          .toList(),
    );
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: _intensityColor(0), label: 'Idle'),
        const SizedBox(width: 16),
        _LegendItem(color: _intensityColor(1), label: '1-2 Gens'),
        const SizedBox(width: 16),
        _LegendItem(color: _intensityColor(3), label: '3+ Gens'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

/// Returns color based on generation intensity level
Color _intensityColor(int level) {
  switch (level) {
    case 0:
      return AppColors.card; // Idle - gray
    case 1:
      return const Color(0xFF60A5FA); // Light blue - low generation
    case 2:
      return const Color(0xFF3B82F6); // Blue - moderate
    case 3:
      return const Color(0xFF2563EB); // Dark blue - high
    default:
      return const Color(0xFF1D4ED8); // Darker blue - very high
  }
}

/// Compact version for cards
class GenerationHistoryMini extends StatelessWidget {
  final List<GenerationReading> readings;
  final double? baseflow;

  const GenerationHistoryMini({
    super.key,
    required this.readings,
    this.baseflow,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) return const SizedBox.shrink();

    // Sample to ~48 bars (one per hour for 2 days)
    final sampled = <GenerationReading>[];
    final step = (readings.length / 48).ceil().clamp(1, readings.length);
    for (var i = 0; i < readings.length; i += step) {
      sampled.add(readings[i]);
    }

    // Find max for scaling
    final maxDischarge = readings
        .map((r) => r.dischargeCfs)
        .reduce((a, b) => a > b ? a : b);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: sampled.map((reading) {
        final heightPct = (reading.dischargeCfs / maxDischarge).clamp(0.1, 1.0);
        final color = _intensityColor(reading.intensityLevel);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.5),
            child: Container(
              height: 60 * heightPct,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
