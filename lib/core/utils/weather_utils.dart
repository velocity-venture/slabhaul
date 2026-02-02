import 'package:flutter/material.dart';

/// WMO Weather Code to description + icon mapping.
/// See: https://open-meteo.com/en/docs#weathervariables
String weatherDescription(int code) {
  switch (code) {
    case 0:
      return 'Clear sky';
    case 1:
      return 'Mainly clear';
    case 2:
      return 'Partly cloudy';
    case 3:
      return 'Overcast';
    case 45:
    case 48:
      return 'Fog';
    case 51:
      return 'Light drizzle';
    case 53:
      return 'Moderate drizzle';
    case 55:
      return 'Dense drizzle';
    case 61:
      return 'Slight rain';
    case 63:
      return 'Moderate rain';
    case 65:
      return 'Heavy rain';
    case 66:
    case 67:
      return 'Freezing rain';
    case 71:
      return 'Slight snow';
    case 73:
      return 'Moderate snow';
    case 75:
      return 'Heavy snow';
    case 77:
      return 'Snow grains';
    case 80:
      return 'Slight showers';
    case 81:
      return 'Moderate showers';
    case 82:
      return 'Violent showers';
    case 85:
    case 86:
      return 'Snow showers';
    case 95:
      return 'Thunderstorm';
    case 96:
    case 99:
      return 'Thunderstorm w/ hail';
    default:
      return 'Unknown';
  }
}

IconData weatherIcon(int code) {
  if (code == 0 || code == 1) return Icons.wb_sunny;
  if (code == 2) return Icons.cloud_queue;
  if (code == 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.foggy;
  if (code >= 51 && code <= 55) return Icons.grain;
  if (code >= 61 && code <= 67) return Icons.water_drop;
  if (code >= 71 && code <= 77) return Icons.ac_unit;
  if (code >= 80 && code <= 82) return Icons.shower;
  if (code >= 85 && code <= 86) return Icons.ac_unit;
  if (code >= 95) return Icons.thunderstorm;
  return Icons.help_outline;
}

/// Wind direction degrees to compass label.
String windCompass(int degrees) {
  const dirs = [
    'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
    'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW',
  ];
  final index = ((degrees % 360) / 22.5).round() % 16;
  return dirs[index];
}

/// Barometric trend from a list of recent pressure readings.
/// Returns "Rising", "Falling", or "Steady".
String barometricTrend(List<double> recentPressures) {
  if (recentPressures.length < 2) return 'Steady';
  final first = recentPressures.first;
  final last = recentPressures.last;
  final diff = last - first;
  if (diff > 1.5) return 'Rising';
  if (diff < -1.5) return 'Falling';
  return 'Steady';
}

IconData barometricTrendIcon(String trend) {
  switch (trend) {
    case 'Rising':
      return Icons.trending_up;
    case 'Falling':
      return Icons.trending_down;
    default:
      return Icons.trending_flat;
  }
}

Color barometricTrendColor(String trend) {
  switch (trend) {
    case 'Rising':
      return const Color(0xFF22C55E);
    case 'Falling':
      return const Color(0xFFEF4444);
    default:
      return const Color(0xFF94A3B8);
  }
}

/// Pressure in millibars to inches of mercury.
double mbToInHg(double mb) => mb * 0.02953;

/// Wind speed bracket for color coding.
Color windSpeedColor(double mph) {
  if (mph < 5) return const Color(0xFF22C55E);
  if (mph < 10) return const Color(0xFFEAB308);
  if (mph < 15) return const Color(0xFFF97316);
  return const Color(0xFFEF4444);
}

String windSpeedLabel(double mph) {
  if (mph < 5) return 'Calm';
  if (mph < 10) return 'Light';
  if (mph < 15) return 'Moderate';
  return 'Strong';
}
