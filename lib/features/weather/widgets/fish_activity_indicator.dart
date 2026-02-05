import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';
import '../../../core/models/weather_data.dart';

/// Compact fish activity indicator based on current conditions
/// 
/// Combines multiple factors:
/// - Barometric pressure trend
/// - Wind conditions
/// - Temperature
/// - Time of day
/// - Moon phase (solunar)
class FishActivityIndicator extends StatelessWidget {
  final WeatherData weather;
  final double? solunarRating;
  
  const FishActivityIndicator({
    super.key,
    required this.weather,
    this.solunarRating,
  });

  @override
  Widget build(BuildContext context) {
    final rating = _calculateOverallRating();
    final color = _getRatingColor(rating);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.2),
            color.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          _buildGauge(rating, color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getRatingLabel(rating),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getRecommendation(rating),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildFactorDots(),
              ),
              const SizedBox(height: 4),
              Text(
                '${(rating * 100).round()}%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(double rating, Color color) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: rating,
            strokeWidth: 5,
            backgroundColor: AppColors.card,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          const Text(
            '🐟',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFactorDots() {
    final factors = _getFactorScores();
    return factors.entries.map((entry) {
      final color = entry.value >= 0.7 
          ? AppColors.success 
          : entry.value >= 0.4 
              ? AppColors.warning 
              : AppColors.error;
      return Tooltip(
        message: '${entry.key}: ${(entry.value * 100).round()}%',
        child: Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }

  double _calculateOverallRating() {
    final factors = _getFactorScores();
    if (factors.isEmpty) return 0.5;
    
    final sum = factors.values.reduce((a, b) => a + b);
    return sum / factors.length;
  }

  Map<String, double> _getFactorScores() {
    final scores = <String, double>{};
    
    // Barometric pressure trend
    final pressureTrend = _getPressureTrendScore();
    scores['Pressure'] = pressureTrend;
    
    // Wind conditions
    final windScore = _getWindScore();
    scores['Wind'] = windScore;
    
    // Temperature comfort
    final tempScore = _getTemperatureScore();
    scores['Temp'] = tempScore;
    
    // Solunar rating (if available)
    if (solunarRating != null) {
      scores['Moon'] = solunarRating!;
    }
    
    return scores;
  }

  double _getPressureTrendScore() {
    // Analyze pressure trend from hourly data
    if (weather.hourly.length < 6) return 0.5;
    
    final recent = weather.hourly.take(6).toList();
    final pressures = recent.map((h) => h.pressureMb).toList();
    
    // Calculate trend
    final first = pressures.first;
    final last = pressures.last;
    final change = last - first;
    
    // Falling pressure = fish feeding (up to a point)
    // Stable pressure = good
    // Rising rapidly = poor
    if (change < -3) {
      return 0.9; // Falling fast = excellent feeding
    } else if (change < -1) {
      return 0.8; // Falling slowly = good
    } else if (change.abs() < 1) {
      return 0.7; // Stable = decent
    } else if (change < 3) {
      return 0.5; // Rising slowly = fair
    } else {
      return 0.3; // Rising fast = poor
    }
  }

  double _getWindScore() {
    final wind = weather.current.windSpeedMph;
    
    // Light wind (5-12 mph) = best for crappie
    // Calm = fish can see you
    // High wind = dangerous/difficult
    if (wind < 3) {
      return 0.5; // Too calm
    } else if (wind <= 12) {
      return 0.9; // Perfect
    } else if (wind <= 18) {
      return 0.6; // Manageable
    } else {
      return 0.3; // Too windy
    }
  }

  double _getTemperatureScore() {
    final temp = weather.current.temperatureF;
    
    // Crappie prefer 55-75°F water
    // Air temp is a proxy for comfort
    if (temp < 35) {
      return 0.3; // Too cold to fish
    } else if (temp < 50) {
      return 0.6; // Cold but fishable
    } else if (temp <= 80) {
      return 0.9; // Ideal
    } else if (temp <= 90) {
      return 0.7; // Hot but OK
    } else {
      return 0.4; // Too hot
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 0.8) return AppColors.success;
    if (rating >= 0.6) return AppColors.teal;
    if (rating >= 0.4) return AppColors.warning;
    return AppColors.error;
  }

  String _getRatingLabel(double rating) {
    if (rating >= 0.85) return 'Excellent';
    if (rating >= 0.7) return 'Good';
    if (rating >= 0.55) return 'Fair';
    if (rating >= 0.4) return 'Slow';
    return 'Poor';
  }

  String _getRecommendation(double rating) {
    if (rating >= 0.8) {
      return 'Prime conditions! Fish should be active.';
    } else if (rating >= 0.65) {
      return 'Good conditions. Focus on structure.';
    } else if (rating >= 0.5) {
      return 'Average day. Target prime feeding windows.';
    } else if (rating >= 0.35) {
      return 'Tough conditions. Slow presentations may help.';
    } else {
      return 'Consider waiting for better conditions.';
    }
  }
}
