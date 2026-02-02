import 'dart:math';
import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// A custom wind compass widget that displays a circular compass with
/// N/S/E/W labels, an arrow pointing in the wind direction, and the
/// wind speed in the center.
class WindCompass extends StatelessWidget {
  /// Wind direction in degrees (meteorological: direction wind is coming FROM).
  final int directionDeg;

  /// Wind speed in mph.
  final double speedMph;

  /// Overall size of the compass widget.
  final double size;

  const WindCompass({
    super.key,
    required this.directionDeg,
    required this.speedMph,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(
          directionDeg: directionDeg,
          speedMph: speedMph,
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final int directionDeg;
  final double speedMph;

  _CompassPainter({required this.directionDeg, required this.speedMph});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;

    // Outer ring
    final ringPaint = Paint()
      ..color = AppColors.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius, ringPaint);

    // Inner fill
    final fillPaint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1, fillPaint);

    // Tick marks at cardinal and intercardinal points
    final tickPaint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 - pi / 2; // Start from top (N)
      final isCardinal = i % 2 == 0;
      final innerR = isCardinal ? radius - 10 : radius - 7;
      final outerR = radius - 2;
      final p1 = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );
      final p2 = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // Cardinal direction labels (N, S, E, W)
    const labels = ['N', 'E', 'S', 'W'];
    const labelAngles = [-pi / 2, 0.0, pi / 2, pi]; // Top, Right, Bottom, Left

    for (int i = 0; i < 4; i++) {
      final labelRadius = radius - 18;
      final angle = labelAngles[i];
      final offset = Offset(
        center.dx + labelRadius * cos(angle),
        center.dy + labelRadius * sin(angle),
      );

      final isNorth = i == 0;
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: isNorth ? AppColors.teal : AppColors.textMuted,
            fontSize: isNorth ? 12 : 10,
            fontWeight: isNorth ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          offset.dx - textPainter.width / 2,
          offset.dy - textPainter.height / 2,
        ),
      );
    }

    // Wind direction arrow
    // Wind direction in meteorology: degrees the wind comes FROM,
    // so the arrow should point in the direction the wind is blowing TO.
    // directionDeg 0 = from North, arrow points South, etc.
    final arrowAngle = (directionDeg + 180) * pi / 180 - pi / 2;
    final arrowLength = radius - 26;
    final arrowTip = Offset(
      center.dx + arrowLength * cos(arrowAngle),
      center.dy + arrowLength * sin(arrowAngle),
    );

    // Arrow shaft
    final arrowPaint = Paint()
      ..color = AppColors.teal
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, arrowTip, arrowPaint);

    // Arrowhead
    final headLength = 10.0;
    final headAngle = 0.5;
    final left = Offset(
      arrowTip.dx - headLength * cos(arrowAngle - headAngle),
      arrowTip.dy - headLength * sin(arrowAngle - headAngle),
    );
    final right = Offset(
      arrowTip.dx - headLength * cos(arrowAngle + headAngle),
      arrowTip.dy - headLength * sin(arrowAngle + headAngle),
    );
    final headPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(
      headPath,
      Paint()
        ..color = AppColors.teal
        ..style = PaintingStyle.fill,
    );

    // Tail (short line in opposite direction)
    final tailLength = 12.0;
    final tailEnd = Offset(
      center.dx - tailLength * cos(arrowAngle),
      center.dy - tailLength * sin(arrowAngle),
    );
    final tailPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.4)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tailEnd, tailPaint);

    // Center dot
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = AppColors.teal
        ..style = PaintingStyle.fill,
    );

    // Speed label in center (offset slightly below)
    final speedText = TextPainter(
      text: TextSpan(
        text: '${speedMph.round()}',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    final unitText = TextPainter(
      text: const TextSpan(
        text: 'mph',
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 8,
          fontWeight: FontWeight.w500,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    speedText.paint(
      canvas,
      Offset(
        center.dx - speedText.width / 2,
        center.dy + 8,
      ),
    );
    unitText.paint(
      canvas,
      Offset(
        center.dx - unitText.width / 2,
        center.dy + 22,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.directionDeg != directionDeg ||
        oldDelegate.speedMph != speedMph;
  }
}
