import 'package:flutter/material.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/utils/constants.dart';

/// Card displaying thermocline prediction with depth diagram
class ThermoclineCard extends StatelessWidget {
  final ThermoclineData data;
  final double maxDepthFt;

  const ThermoclineCard({
    super.key,
    required this.data,
    this.maxDepthFt = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Depth diagram
              SizedBox(
                width: 80,
                height: 200,
                child: _DepthDiagram(
                  thermoclineTopFt: data.thermoclineTopFt,
                  thermoclineBottomFt: data.thermoclineBottomFt,
                  targetMinFt: data.targetDepthMinFt,
                  targetMaxFt: data.targetDepthMaxFt,
                  maxDepthFt: maxDepthFt,
                ),
              ),
              const SizedBox(width: 16),
              // Stats and recommendation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTargetDepth(),
                    const SizedBox(height: 12),
                    _buildStats(),
                    const SizedBox(height: 12),
                    _buildConfidence(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRecommendation(),
          if (data.factors.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildFactors(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.teal.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.layers,
            color: AppColors.teal,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thermocline Predictor',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                data.status.label,
                style: TextStyle(
                  color: _statusColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        data.isStratified ? 'Active' : 'Mixed',
        style: TextStyle(
          color: _statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (data.status) {
      case StratificationStatus.stratified:
        return AppColors.success;
      case StratificationStatus.forming:
      case StratificationStatus.breaking:
        return AppColors.warning;
      case StratificationStatus.mixed:
        return AppColors.textMuted;
    }
  }

  Widget _buildTargetDepth() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.teal.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.gps_fixed, color: AppColors.teal, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Depth',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                '${data.targetDepthMinFt.toStringAsFixed(0)}-${data.targetDepthMaxFt.toStringAsFixed(0)} ft',
                style: TextStyle(
                  color: AppColors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _StatChip(
          label: 'Surface',
          value: '${data.surfaceTempF.toStringAsFixed(0)}°F',
          icon: Icons.thermostat,
        ),
        _StatChip(
          label: 'At Depth',
          value: '${data.thermoclineTempF.toStringAsFixed(0)}°F',
          icon: Icons.thermostat_auto,
        ),
        _StatChip(
          label: 'Sweet Spot',
          value: '${data.sweetSpotFt.toStringAsFixed(0)} ft',
          icon: Icons.stars,
        ),
      ],
    );
  }

  Widget _buildConfidence() {
    final percent = (data.confidence * 100).toInt();
    return Row(
      children: [
        Text(
          'Confidence: ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.confidence,
              backgroundColor: AppColors.card,
              valueColor: AlwaysStoppedAnimation<Color>(
                data.confidence > 0.7 ? AppColors.success : AppColors.warning,
              ),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$percent%',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline, color: AppColors.warning, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.recommendation,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactors() {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: data.factors.map((factor) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            factor,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textMuted, size: 14),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Visual depth diagram showing lake layers and thermocline
class _DepthDiagram extends StatelessWidget {
  final double thermoclineTopFt;
  final double thermoclineBottomFt;
  final double targetMinFt;
  final double targetMaxFt;
  final double maxDepthFt;

  const _DepthDiagram({
    required this.thermoclineTopFt,
    required this.thermoclineBottomFt,
    required this.targetMinFt,
    required this.targetMaxFt,
    required this.maxDepthFt,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DepthDiagramPainter(
        thermoclineTopFt: thermoclineTopFt,
        thermoclineBottomFt: thermoclineBottomFt,
        targetMinFt: targetMinFt,
        targetMaxFt: targetMaxFt,
        maxDepthFt: maxDepthFt,
      ),
      size: const Size(80, 200),
    );
  }
}

class _DepthDiagramPainter extends CustomPainter {
  final double thermoclineTopFt;
  final double thermoclineBottomFt;
  final double targetMinFt;
  final double targetMaxFt;
  final double maxDepthFt;

  _DepthDiagramPainter({
    required this.thermoclineTopFt,
    required this.thermoclineBottomFt,
    required this.targetMinFt,
    required this.targetMaxFt,
    required this.maxDepthFt,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(10, 0, size.width - 20, size.height);
    
    // Warm surface layer (epilimnion)
    final warmPaint = Paint()
      ..color = const Color(0xFFFF6B6B).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    
    final thermoclineTopY = (thermoclineTopFt / maxDepthFt) * size.height;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, 0, rect.width, thermoclineTopY),
      warmPaint,
    );
    
    // Thermocline layer (gradient)
    final thermoclineBottomY = (thermoclineBottomFt / maxDepthFt) * size.height;
    final thermoclinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFFF6B6B).withValues(alpha: 0.6),
          const Color(0xFF4ECDC4).withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(rect.left, thermoclineTopY, rect.width, thermoclineBottomY - thermoclineTopY));
    canvas.drawRect(
      Rect.fromLTWH(rect.left, thermoclineTopY, rect.width, thermoclineBottomY - thermoclineTopY),
      thermoclinePaint,
    );
    
    // Cold deep layer (hypolimnion)
    final coldPaint = Paint()
      ..color = const Color(0xFF4ECDC4).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(rect.left, thermoclineBottomY, rect.width, size.height - thermoclineBottomY),
      coldPaint,
    );
    
    // Target zone highlight
    final targetTopY = (targetMinFt / maxDepthFt) * size.height;
    final targetBottomY = (targetMaxFt / maxDepthFt) * size.height;
    final targetPaint = Paint()
      ..color = AppColors.teal.withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(rect.left - 5, targetTopY, rect.width + 10, targetBottomY - targetTopY),
      targetPaint,
    );
    
    // Target zone border
    final targetBorderPaint = Paint()
      ..color = AppColors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(rect.left - 5, targetTopY, rect.width + 10, targetBottomY - targetTopY),
      targetBorderPaint,
    );
    
    // Fish icon in target zone
    final fishY = (targetTopY + targetBottomY) / 2;
    final fishPaint = TextPainter(
      text: TextSpan(
        text: '🐟',
        style: TextStyle(fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    fishPaint.layout();
    fishPaint.paint(canvas, Offset(rect.center.dx - 8, fishY - 8));
    
    // Depth labels
    final labelPaint = TextPainter(
      textDirection: TextDirection.ltr,
    );
    
    // Surface label
    labelPaint.text = TextSpan(
      text: '0\'',
      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
    );
    labelPaint.layout();
    labelPaint.paint(canvas, Offset(0, 2));
    
    // Thermocline label
    labelPaint.text = TextSpan(
      text: '${thermoclineTopFt.toStringAsFixed(0)}\'',
      style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
    );
    labelPaint.layout();
    labelPaint.paint(canvas, Offset(0, thermoclineTopY - 5));
    
    // Bottom label
    labelPaint.text = TextSpan(
      text: '${maxDepthFt.toStringAsFixed(0)}\'',
      style: TextStyle(color: AppColors.textMuted, fontSize: 10),
    );
    labelPaint.layout();
    labelPaint.paint(canvas, Offset(0, size.height - 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
