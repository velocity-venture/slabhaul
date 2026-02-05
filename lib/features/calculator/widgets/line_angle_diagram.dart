import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/calculator/providers/calculator_providers.dart';

class LineAngleDiagram extends ConsumerStatefulWidget {
  const LineAngleDiagram({super.key});

  @override
  ConsumerState<LineAngleDiagram> createState() => _LineAngleDiagramState();
}

class _LineAngleDiagramState extends ConsumerState<LineAngleDiagram>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _animatedAngle = 0.0;
  double _animatedDepth = 0.0;
  double _animatedLineOut = 50.0;
  double _targetAngle = 0.0;
  double _targetDepth = 0.0;
  double _targetLineOut = 50.0;
  double _previousAngle = 0.0;
  double _previousDepth = 0.0;
  double _previousLineOut = 50.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(() {
        final t = Curves.easeOutCubic.transform(_controller.value);
        setState(() {
          _animatedAngle = _previousAngle + (_targetAngle - _previousAngle) * t;
          _animatedDepth = _previousDepth + (_targetDepth - _previousDepth) * t;
          _animatedLineOut =
              _previousLineOut + (_targetLineOut - _previousLineOut) * t;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(double angle, double depth, double lineOut) {
    _previousAngle = _animatedAngle;
    _previousDepth = _animatedDepth;
    _previousLineOut = _animatedLineOut;
    _targetAngle = angle;
    _targetDepth = depth;
    _targetLineOut = lineOut;
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(calculatorResultProvider);

    // Trigger animation when result changes.
    if ((result.lineAngleDeg - _targetAngle).abs() > 0.01 ||
        (result.depthFt - _targetDepth).abs() > 0.01) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateTo(result.lineAngleDeg, result.depthFt, result.input.lineOutFt);
      });
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        size: const Size(double.infinity, 200),
        painter: _LineAnglePainter(
          angleDeg: _animatedAngle,
          depthFt: _animatedDepth,
          lineOutFt: _animatedLineOut,
        ),
      ),
    );
  }
}

class _LineAnglePainter extends CustomPainter {
  final double angleDeg;
  final double depthFt;
  final double lineOutFt;

  _LineAnglePainter({
    required this.angleDeg,
    required this.depthFt,
    required this.lineOutFt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Background water gradient.
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0F172A),
          Color(0xFF0C1929),
          Color(0xFF0A1422),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Water surface line at ~25% from top.
    final double surfaceY = h * 0.22;

    // Draw gentle wave on water surface.
    final wavePaint = Paint()
      ..color = const Color(0xFF1E6091)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final wavePath = Path();
    wavePath.moveTo(0, surfaceY);
    for (double x = 0; x <= w; x += 1) {
      final y = surfaceY + sin(x * 0.04) * 2.5 + sin(x * 0.02) * 1.5;
      wavePath.lineTo(x, y);
    }
    canvas.drawPath(wavePath, wavePaint);

    // Semi-transparent water fill below wave.
    final waterFill = Paint()
      ..color = const Color(0xFF1E6091).withValues(alpha: 0.08);
    final fillPath = Path()
      ..addPath(wavePath, Offset.zero)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(fillPath, waterFill);

    // Draw boat silhouette at surface.
    final double boatX = w * 0.18;
    final double boatY = surfaceY - 4;
    _drawBoat(canvas, boatX, boatY);

    // Rod tip (where line exits from boat).
    final double rodTipX = boatX + 16;
    final double rodTipY = surfaceY + 2;

    // Line goes from rod tip down at the calculated angle.
    // angleDeg is from vertical, so 0 = straight down, 90 = horizontal.
    final double angleRad = angleDeg * pi / 180.0;

    // Scale line length to fit diagram (max line length fills ~70% of available space).
    final double availableDepth = h - surfaceY - 20;
    const double maxLineOut = 100.0;
    final double lineScale = availableDepth / (maxLineOut * 0.95);
    final double scaledLine = lineOutFt.clamp(10, 100) * lineScale;

    // Endpoint of the fishing line.
    final double sinkerX = rodTipX + sin(angleRad) * scaledLine;
    final double sinkerY = rodTipY + cos(angleRad) * scaledLine;

    // Draw fishing line.
    final linePaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(rodTipX, rodTipY), Offset(sinkerX, sinkerY), linePaint);

    // Draw sinker as a small filled circle.
    final sinkerPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(sinkerX, sinkerY), 4, sinkerPaint);

    // Draw sinker outline.
    final sinkerOutline = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(Offset(sinkerX, sinkerY), 4, sinkerOutline);

    // Draw vertical depth measurement dashed line.
    final double depthLineX = sinkerX + 20;
    _drawDashedLine(
      canvas,
      Offset(depthLineX, surfaceY),
      Offset(depthLineX, sinkerY),
      Paint()
        ..color = AppColors.teal.withValues(alpha: 0.6)
        ..strokeWidth = 1.0,
    );

    // Small horizontal ticks at top and bottom of depth line.
    final tickPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.6)
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(depthLineX - 4, surfaceY),
      Offset(depthLineX + 4, surfaceY),
      tickPaint,
    );
    canvas.drawLine(
      Offset(depthLineX - 4, sinkerY),
      Offset(depthLineX + 4, sinkerY),
      tickPaint,
    );

    // Depth label.
    final depthLabel = TextPainter(
      text: TextSpan(
        text: '${depthFt.toStringAsFixed(1)} ft',
        style: const TextStyle(
          color: AppColors.teal,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    depthLabel.paint(
      canvas,
      Offset(depthLineX + 8, (surfaceY + sinkerY) / 2 - depthLabel.height / 2),
    );

    // Draw angle arc and label near the rod tip.
    if (angleDeg > 1) {
      const arcRadius = 24.0;
      final arcRect = Rect.fromCircle(
        center: Offset(rodTipX, rodTipY),
        radius: arcRadius,
      );
      final arcPaint = Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      // Arc from straight-down (pi/2 from horizontal = 0 start) sweeping by angleDeg.
      // In Flutter canvas: 0 is right, pi/2 is down. Straight down from rod tip = pi/2.
      // We draw from the line direction to straight down.
      final startAngle = pi / 2 - angleRad;
      canvas.drawArc(arcRect, startAngle, angleRad, false, arcPaint);

      // Angle label.
      final angleLabel = TextPainter(
        text: TextSpan(
          text: '${angleDeg.toStringAsFixed(1)}°',
          style: const TextStyle(
            color: Color(0xFFF59E0B),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelAngle = pi / 2 - angleRad / 2;
      angleLabel.paint(
        canvas,
        Offset(
          rodTipX + cos(labelAngle) * (arcRadius + 12) - angleLabel.width / 2,
          rodTipY + sin(labelAngle) * (arcRadius + 12) - angleLabel.height / 2,
        ),
      );
    }

    // Line out label along the fishing line.
    final midX = (rodTipX + sinkerX) / 2;
    final midY = (rodTipY + sinkerY) / 2;
    final lineOutLabel = TextPainter(
      text: TextSpan(
        text: '${lineOutFt.toStringAsFixed(0)} ft line',
        style: TextStyle(
          color: const Color(0xFF94A3B8).withValues(alpha: 0.8),
          fontSize: 9,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    lineOutLabel.paint(
      canvas,
      Offset(midX - lineOutLabel.width - 6, midY - lineOutLabel.height / 2),
    );
  }

  void _drawBoat(Canvas canvas, double cx, double cy) {
    // Simple boat hull shape.
    final hullPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final hull = Path()
      ..moveTo(cx - 18, cy)
      ..lineTo(cx - 14, cy + 6)
      ..lineTo(cx + 20, cy + 6)
      ..lineTo(cx + 24, cy)
      ..close();
    canvas.drawPath(hull, hullPaint);

    // Cabin.
    final cabinPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 4, cy - 8, 14, 8),
        const Radius.circular(2),
      ),
      cabinPaint,
    );

    // Rod sticking out to the right.
    final rodPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 10, cy - 6), Offset(cx + 16, cy + 6), rodPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double length = sqrt(dx * dx + dy * dy);
    const double dashLen = 4.0;
    const double gapLen = 3.0;
    final double unitX = dx / length;
    final double unitY = dy / length;

    double drawn = 0;
    while (drawn < length) {
      final double segEnd = (drawn + dashLen).clamp(0, length);
      canvas.drawLine(
        Offset(start.dx + unitX * drawn, start.dy + unitY * drawn),
        Offset(start.dx + unitX * segEnd, start.dy + unitY * segEnd),
        paint,
      );
      drawn += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(covariant _LineAnglePainter old) =>
      old.angleDeg != angleDeg ||
      old.depthFt != depthFt ||
      old.lineOutFt != lineOutFt;
}
