import 'dart:math' as math;

/// Current wind conditions at a location.
class WindConditions {
  final double speedMph;
  final double gustsMph;
  final int directionDeg;
  final DateTime timestamp;

  const WindConditions({
    required this.speedMph,
    required this.gustsMph,
    required this.directionDeg,
    required this.timestamp,
  });

  /// Compass direction as a string (N, NNE, NE, etc.)
  String get compassDirection {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((directionDeg + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Wind severity category
  WindSeverity get severity {
    if (speedMph < 5) return WindSeverity.calm;
    if (speedMph < 12) return WindSeverity.light;
    if (speedMph < 20) return WindSeverity.moderate;
    if (speedMph < 30) return WindSeverity.strong;
    return WindSeverity.dangerous;
  }

  /// Direction in radians (for arrow rotation)
  double get directionRadians => directionDeg * math.pi / 180;

  /// Direction the wind is blowing TO (opposite of from)
  int get blowingTowardsDeg => (directionDeg + 180) % 360;

  WindConditions copyWith({
    double? speedMph,
    double? gustsMph,
    int? directionDeg,
    DateTime? timestamp,
  }) {
    return WindConditions(
      speedMph: speedMph ?? this.speedMph,
      gustsMph: gustsMph ?? this.gustsMph,
      directionDeg: directionDeg ?? this.directionDeg,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory WindConditions.mock() {
    return WindConditions(
      speedMph: 8.5,
      gustsMph: 12.0,
      directionDeg: 210,
      timestamp: DateTime.now(),
    );
  }
}

/// Wind severity levels
enum WindSeverity {
  calm,      // < 5 mph
  light,     // 5-12 mph
  moderate,  // 12-20 mph
  strong,    // 20-30 mph
  dangerous, // > 30 mph
}

/// Hourly wind forecast data point
class WindForecastHour {
  final DateTime time;
  final double speedMph;
  final double gustsMph;
  final int directionDeg;

  const WindForecastHour({
    required this.time,
    required this.speedMph,
    required this.gustsMph,
    required this.directionDeg,
  });

  WindConditions toConditions() => WindConditions(
    speedMph: speedMph,
    gustsMph: gustsMph,
    directionDeg: directionDeg,
    timestamp: time,
  );

  String get compassDirection {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((directionDeg + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

/// Complete wind forecast data
class WindForecast {
  final WindConditions current;
  final List<WindForecastHour> hourly;
  final DateTime fetchedAt;
  final double latitude;
  final double longitude;

  const WindForecast({
    required this.current,
    required this.hourly,
    required this.fetchedAt,
    required this.latitude,
    required this.longitude,
  });

  /// Get forecast for a specific time
  WindForecastHour? getHourlyAt(DateTime time) {
    for (final hour in hourly) {
      if (hour.time.isAfter(time.subtract(const Duration(minutes: 30))) &&
          hour.time.isBefore(time.add(const Duration(minutes: 30)))) {
        return hour;
      }
    }
    return null;
  }

  /// Get the closest forecast hour to a given time
  WindForecastHour getClosestHour(DateTime time) {
    if (hourly.isEmpty) {
      return WindForecastHour(
        time: time,
        speedMph: current.speedMph,
        gustsMph: current.gustsMph,
        directionDeg: current.directionDeg,
      );
    }

    WindForecastHour closest = hourly.first;
    int minDiff = (hourly.first.time.difference(time).inMinutes).abs();

    for (final hour in hourly) {
      final diff = (hour.time.difference(time).inMinutes).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = hour;
      }
    }
    return closest;
  }

  /// Earliest available forecast time
  DateTime get earliestTime => hourly.isNotEmpty 
      ? hourly.first.time 
      : DateTime.now().subtract(const Duration(days: 2));

  /// Latest available forecast time
  DateTime get latestTime => hourly.isNotEmpty 
      ? hourly.last.time 
      : DateTime.now().add(const Duration(days: 7));
}

/// Bank exposure rating for wind effects
enum BankExposure {
  sheltered,   // Protected from wind (lee side)
  partial,     // Some exposure
  exposed,     // Direct windward exposure
}

/// A shoreline segment affected by wind
class WindAffectedBank {
  /// Start point of the bank segment
  final double startLat;
  final double startLon;

  /// End point of the bank segment
  final double endLat;
  final double endLon;

  /// Bank orientation in degrees (direction it faces)
  final double orientationDeg;

  /// Exposure level based on wind
  final BankExposure exposure;

  /// Wind-generated wave height estimate in feet
  final double waveHeightFt;

  /// Fetch distance in miles (open water distance wind travels)
  final double fetchMiles;

  const WindAffectedBank({
    required this.startLat,
    required this.startLon,
    required this.endLat,
    required this.endLon,
    required this.orientationDeg,
    required this.exposure,
    required this.waveHeightFt,
    required this.fetchMiles,
  });

  /// Center point of this bank segment
  double get centerLat => (startLat + endLat) / 2;
  double get centerLon => (startLon + endLon) / 2;
}

/// A calm pocket area protected from wind
class CalmPocket {
  final double centerLat;
  final double centerLon;
  final double radiusMiles;
  final String description;

  const CalmPocket({
    required this.centerLat,
    required this.centerLon,
    required this.radiusMiles,
    required this.description,
  });
}

/// Wave conditions for open water areas
class WaveConditions {
  /// Estimated wave height in feet
  final double heightFt;

  /// Wave period in seconds
  final double periodSeconds;

  /// Fetch distance that generated the waves
  final double fetchMiles;

  /// How these conditions affect fishing
  final WaveFishingImpact fishingImpact;

  const WaveConditions({
    required this.heightFt,
    required this.periodSeconds,
    required this.fetchMiles,
    required this.fishingImpact,
  });

  /// Descriptive text for wave height
  String get description {
    if (heightFt < 0.5) return 'Calm';
    if (heightFt < 1.0) return 'Light chop';
    if (heightFt < 2.0) return 'Moderate waves';
    if (heightFt < 3.0) return 'Rough';
    return 'Very rough';
  }
}

/// How waves affect fishing conditions
enum WaveFishingImpact {
  excellent,  // Light waves move baitfish, triggers feeding
  good,       // Moderate activity, fish are active
  fair,       // Some wave action, fishing possible
  poor,       // Rough conditions, difficult fishing
  dangerous,  // Stay off the water
}

/// Complete wind effects analysis for a lake
class LakeWindAnalysis {
  final WindConditions wind;
  final List<WindAffectedBank> affectedBanks;
  final List<CalmPocket> calmPockets;
  final WaveConditions openWaterWaves;
  final DateTime analyzedAt;

  const LakeWindAnalysis({
    required this.wind,
    required this.affectedBanks,
    required this.calmPockets,
    required this.openWaterWaves,
    required this.analyzedAt,
  });

  /// Get exposed banks (good for baitfish accumulation)
  List<WindAffectedBank> get exposedBanks =>
      affectedBanks.where((b) => b.exposure == BankExposure.exposed).toList();

  /// Get sheltered banks (calm water)
  List<WindAffectedBank> get shelteredBanks =>
      affectedBanks.where((b) => b.exposure == BankExposure.sheltered).toList();

  /// Overall fishing recommendation based on wind
  String get fishingRecommendation {
    final speed = wind.speedMph;
    if (speed < 5) {
      return 'Calm conditions - fish deeper structure, topwater can work early/late';
    }
    if (speed < 12) {
      return 'Ideal conditions - target windward banks where baitfish concentrate';
    }
    if (speed < 20) {
      return 'Good wind - fish the windblown points and banks, use heavier jigs';
    }
    if (speed < 30) {
      return 'Strong wind - seek protected areas, use heavy tackle';
    }
    return 'Dangerous conditions - consider staying off the water';
  }
}
