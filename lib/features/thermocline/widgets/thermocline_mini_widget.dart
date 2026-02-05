import 'package:flutter/material.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/utils/constants.dart';

/// Compact thermocline widget for dashboard or map overlay
/// 
/// Shows essential info at a glance:
/// - Target depth range
/// - Confidence indicator
/// - Status
class ThermoclineMiniWidget extends StatelessWidget {
  final ThermoclineData data;
  final VoidCallback? onTap;

  const ThermoclineMiniWidget({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTargetIcon(),
            const SizedBox(width: 8),
            _buildDepthText(),
            const SizedBox(width: 12),
            _buildConfidenceDots(),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTargetIcon() {
    final color = data.isStratified ? AppColors.teal : AppColors.info;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        data.isStratified ? Icons.gps_fixed : Icons.waves,
        color: color,
        size: 18,
      ),
    );
  }

  Widget _buildDepthText() {
    if (!data.isStratified) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Any Depth',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Lake Mixed',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${data.targetDepthMinFt.round()}-${data.targetDepthMaxFt.round()} ft',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          data.status.label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceDots() {
    final confidence = data.confidence;
    final filledDots = (confidence * 5).round().clamp(1, 5);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final isFilled = i < filledDots;
        return Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isFilled 
                ? _getConfidenceColor()
                : AppColors.textMuted.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }

  Color _getConfidenceColor() {
    if (data.confidence >= 0.85) return AppColors.success;
    if (data.confidence >= 0.65) return AppColors.warning;
    if (data.confidence >= 0.50) return Colors.orange;
    return AppColors.error;
  }
}

/// Status indicator pill for thermocline state
class ThermoclineStatusPill extends StatelessWidget {
  final StratificationStatus status;

  const ThermoclineStatusPill({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getStatusDisplay();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            status.label,
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

  (IconData, Color) _getStatusDisplay() {
    return switch (status) {
      StratificationStatus.mixed => (Icons.ac_unit, AppColors.info),
      StratificationStatus.forming => (Icons.trending_up, AppColors.warning),
      StratificationStatus.stratified => (Icons.wb_sunny, AppColors.success),
      StratificationStatus.breaking => (Icons.trending_down, Colors.orange),
    };
  }
}
