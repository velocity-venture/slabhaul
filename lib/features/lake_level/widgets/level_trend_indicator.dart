import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';
import '../providers/lake_level_providers.dart';

/// Visual indicator showing rising/falling/stable water level trend
class LevelTrendIndicator extends StatelessWidget {
  final LevelTrend trend;
  final double? change24h;
  final double? changePerDay;
  final bool compact;

  const LevelTrendIndicator({
    super.key,
    required this.trend,
    this.change24h,
    this.changePerDay,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _trendColor(trend);
    final icon = _trendIcon(trend);

    if (compact) {
      return _CompactIndicator(
        trend: trend,
        color: color,
        icon: icon,
        change24h: change24h,
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // Animated trend icon
          _AnimatedTrendIcon(trend: trend, color: color),
          const SizedBox(width: 16),

          // Trend info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Water Level ${trend.label}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                if (change24h != null)
                  Text(
                    '${change24h! >= 0 ? '+' : ''}${change24h!.toStringAsFixed(2)} ft (24h)',
                    style: TextStyle(
                      fontSize: 13,
                      color: color.withValues(alpha: 0.9),
                    ),
                  ),
                if (changePerDay != null && change24h != null)
                  Text(
                    'Avg: ${changePerDay! >= 0 ? '+' : ''}${changePerDay!.toStringAsFixed(3)} ft/day',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Visual arrow
          Icon(icon, color: color, size: 32),
        ],
      ),
    );
  }

  Color _trendColor(LevelTrend trend) {
    switch (trend) {
      case LevelTrend.rising:
        return AppColors.success;
      case LevelTrend.falling:
        return AppColors.error;
      case LevelTrend.stable:
        return AppColors.teal;
      case LevelTrend.unknown:
        return AppColors.textMuted;
    }
  }

  IconData _trendIcon(LevelTrend trend) {
    switch (trend) {
      case LevelTrend.rising:
        return Icons.trending_up;
      case LevelTrend.falling:
        return Icons.trending_down;
      case LevelTrend.stable:
        return Icons.trending_flat;
      case LevelTrend.unknown:
        return Icons.help_outline;
    }
  }
}

class _CompactIndicator extends StatelessWidget {
  final LevelTrend trend;
  final Color color;
  final IconData icon;
  final double? change24h;

  const _CompactIndicator({
    required this.trend,
    required this.color,
    required this.icon,
    this.change24h,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            trend.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          if (change24h != null) ...[
            const SizedBox(width: 6),
            Text(
              '(${change24h! >= 0 ? '+' : ''}${change24h!.toStringAsFixed(2)})',
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Animated icon that pulses for active trends
class _AnimatedTrendIcon extends StatefulWidget {
  final LevelTrend trend;
  final Color color;

  const _AnimatedTrendIcon({
    required this.trend,
    required this.color,
  });

  @override
  State<_AnimatedTrendIcon> createState() => _AnimatedTrendIconState();
}

class _AnimatedTrendIconState extends State<_AnimatedTrendIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.trend == LevelTrend.stable ? 0.0 : 8.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    if (widget.trend != LevelTrend.stable && 
        widget.trend != LevelTrend.unknown) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double offset = 0;
    if (widget.trend == LevelTrend.rising) {
      offset = -_animation.value;
    } else if (widget.trend == LevelTrend.falling) {
      offset = _animation.value;
    }

    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          _getIcon(),
          color: widget.color,
          size: 28,
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (widget.trend) {
      case LevelTrend.rising:
        return Icons.water_drop;
      case LevelTrend.falling:
        return Icons.water;
      case LevelTrend.stable:
        return Icons.waves;
      case LevelTrend.unknown:
        return Icons.help_outline;
    }
  }
}
