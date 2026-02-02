import 'package:flutter/material.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/utils/constants.dart';

/// Full thermocline visualization card with depth diagram
/// 
/// Displays:
/// - Confidence indicator
/// - Visual depth diagram with layers (epilimnion, thermocline, hypolimnion)
/// - Target fishing depth recommendation
/// - Factors that influenced the prediction
class ThermoclineCard extends StatelessWidget {
  final ThermoclineData data;
  final double? maxLakeDepth;

  const ThermoclineCard({
    super.key,
    required this.data,
    this.maxLakeDepth,
  });

  @override
  Widget build(BuildContext context) {
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
          _buildDepthDiagram(),
          _buildRecommendation(),
          _buildFactors(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.thermostat, color: AppColors.teal),
          const SizedBox(width: 8),
          const Text(
            'THERMOCLINE PREDICTOR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          _buildConfidenceBadge(),
        ],
      ),
    );
  }

  Widget _buildConfidenceBadge() {
    final (color, label) = _getConfidenceDisplay();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label Confidence',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _getConfidenceDisplay() {
    if (data.confidence >= 0.85) return (AppColors.success, 'High');
    if (data.confidence >= 0.65) return (AppColors.warning, 'Medium');
    if (data.confidence >= 0.50) return (Colors.orange, 'Low');
    return (AppColors.error, 'Very Low');
  }

  Widget _buildDepthDiagram() {
    if (!data.isStratified) {
      return _buildMixedDiagram();
    }
    
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: _ThermoclineDiagramPainter(
          data: data,
          maxDepth: maxLakeDepth ?? 40,
        ),
        size: Size.infinite,
      ),
    );
  }

  Widget _buildMixedDiagram() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade300,
            Colors.blue.shade600,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.waves, color: Colors.white, size: 32),
            SizedBox(height: 8),
            Text(
              'Lake is fully mixed',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'No thermocline present',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.recommendation,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(
            Icons.analytics_outlined,
            color: AppColors.textMuted,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.factors.join(' • '),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the thermocline depth diagram
class _ThermoclineDiagramPainter extends CustomPainter {
  final ThermoclineData data;
  final double maxDepth;

  _ThermoclineDiagramPainter({
    required this.data,
    required this.maxDepth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(40, 0, size.width - 80, size.height);
    
    // Draw gradient background (warm to cold)
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.orange.shade300,
        Colors.orange.shade400,
        Colors.blue.shade300,
        Colors.blue.shade600,
      ],
      stops: [
        0,
        (data.thermoclineTopFt / maxDepth).clamp(0.1, 0.9),
        ((data.thermoclineTopFt + 3) / maxDepth).clamp(0.15, 0.95),
        1,
      ],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      paint,
    );
    
    // Draw target zone highlight
    final targetTop = (data.targetDepthMinFt / maxDepth) * size.height;
    final targetBottom = (data.targetDepthMaxFt / maxDepth) * size.height;
    final targetRect = Rect.fromLTRB(
      rect.left,
      targetTop,
      rect.right,
      targetBottom,
    );
    
    final targetPaint = Paint()
      ..color = AppColors.teal.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(targetRect, targetPaint);
    
    // Draw target zone border
    final targetBorderPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(targetRect, targetBorderPaint);
    
    // Draw thermocline line
    final thermoclineY = (data.thermoclineTopFt / maxDepth) * size.height;
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(rect.left, thermoclineY),
      Offset(rect.right, thermoclineY),
      linePaint,
    );
    
    // Draw depth labels
    final textStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: 10,
    );
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Surface label
    textPainter.text = TextSpan(text: '0 ft', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, 0));
    
    // Target zone label
    textPainter.text = TextSpan(
      text: '${data.targetDepthMinFt.round()}-${data.targetDepthMaxFt.round()} ft\n🎯 TARGET',
      style: textStyle.copyWith(
        color: AppColors.teal,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.right + 5, targetTop));
    
    // Max depth label
    textPainter.text = TextSpan(text: '${maxDepth.round()} ft', style: textStyle);
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, size.height - 15));
    
    // Temperature labels
    textPainter.text = TextSpan(
      text: '${data.surfaceTempF.round()}°F',
      style: textStyle.copyWith(color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 5, 5));
    
    textPainter.text = TextSpan(
      text: '~${data.thermoclineTempF.round()}°F',
      style: textStyle.copyWith(color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 5, thermoclineY + 5));
  }

  @override
  bool shouldRepaint(covariant _ThermoclineDiagramPainter oldDelegate) {
    return data != oldDelegate.data || maxDepth != oldDelegate.maxDepth;
  }
}
