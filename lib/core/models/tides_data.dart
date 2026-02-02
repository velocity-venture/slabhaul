// Tides data models for coastal/brackish water crappie fishing.
// 
// Supports NOAA CO-OPS tide stations and predictions for
// tidal-influenced waters like Sabine Lake, Lake Pontchartrain, etc.

/// Represents a NOAA CO-OPS tide monitoring station.
class TideStation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? stateCode;
  final String? timezone;
  final double? mslOffset; // Mean sea level offset

  const TideStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.stateCode,
    this.timezone,
    this.mslOffset,
  });

  factory TideStation.fromJson(Map<String, dynamic> json) {
    return TideStation(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stateCode: json['state_code'] as String?,
      timezone: json['timezone'] as String?,
      mslOffset: (json['msl_offset'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'state_code': stateCode,
    'timezone': timezone,
    'msl_offset': mslOffset,
  };
}

/// Type of tide reading.
enum TideType {
  high,
  low,
  rising,
  falling,
  slack,
}

/// A single tide reading (actual or predicted).
class TideReading {
  final DateTime timestamp;
  final double heightFt; // Height in feet above MLLW
  final TideType type;
  final bool isPrediction;

  const TideReading({
    required this.timestamp,
    required this.heightFt,
    required this.type,
    this.isPrediction = false,
  });

  factory TideReading.fromJson(Map<String, dynamic> json, {bool isPrediction = false}) {
    return TideReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      heightFt: (json['height_ft'] as num).toDouble(),
      type: _parseTideType(json['type'] as String?),
      isPrediction: isPrediction,
    );
  }

  static TideType _parseTideType(String? type) {
    switch (type?.toLowerCase()) {
      case 'h':
      case 'high':
        return TideType.high;
      case 'l':
      case 'low':
        return TideType.low;
      case 'rising':
        return TideType.rising;
      case 'falling':
        return TideType.falling;
      default:
        return TideType.slack;
    }
  }

  /// Human-readable height display
  String get heightDisplay => '${heightFt.toStringAsFixed(1)} ft';

  /// Tide type display string
  String get typeDisplay {
    switch (type) {
      case TideType.high:
        return 'High';
      case TideType.low:
        return 'Low';
      case TideType.rising:
        return 'Rising';
      case TideType.falling:
        return 'Falling';
      case TideType.slack:
        return 'Slack';
    }
  }

  /// Icon for tide type
  String get typeIcon {
    switch (type) {
      case TideType.high:
        return '⬆️';
      case TideType.low:
        return '⬇️';
      case TideType.rising:
        return '📈';
      case TideType.falling:
        return '📉';
      case TideType.slack:
        return '➡️';
    }
  }
}

/// A predicted high/low tide event.
class TidePrediction {
  final DateTime timestamp;
  final double heightFt;
  final bool isHigh; // true = high tide, false = low tide

  const TidePrediction({
    required this.timestamp,
    required this.heightFt,
    required this.isHigh,
  });

  factory TidePrediction.fromNoaaJson(Map<String, dynamic> json) {
    // NOAA format: {"t": "2024-01-15 06:42", "v": "1.234", "type": "H"}
    return TidePrediction(
      timestamp: DateTime.parse((json['t'] as String).replaceFirst(' ', 'T')),
      heightFt: double.tryParse(json['v'] as String? ?? '') ?? 0,
      isHigh: (json['type'] as String?)?.toUpperCase() == 'H',
    );
  }

  String get typeLabel => isHigh ? 'High Tide' : 'Low Tide';
  String get heightDisplay => '${heightFt.toStringAsFixed(1)} ft';
}

/// Fishing quality rating based on tide conditions.
enum TideFishingRating {
  excellent, // Peak movement period
  good, // Active movement
  fair, // Moderate activity
  poor, // Slack water
}

/// An optimal fishing window based on tide movement.
class TideFishingWindow {
  final DateTime start;
  final DateTime end;
  final TideFishingRating rating;
  final String reason;
  final double? movementRate; // ft/hour

  const TideFishingWindow({
    required this.start,
    required this.end,
    required this.rating,
    required this.reason,
    this.movementRate,
  });

  /// Duration of this window
  Duration get duration => end.difference(start);

  /// Human-readable duration
  String get durationDisplay {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Whether this window is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(start) && now.isBefore(end);
  }

  /// Rating color for UI
  int get ratingColorValue {
    switch (rating) {
      case TideFishingRating.excellent:
        return 0xFF22C55E; // Green
      case TideFishingRating.good:
        return 0xFF3B82F6; // Blue
      case TideFishingRating.fair:
        return 0xFFF59E0B; // Amber
      case TideFishingRating.poor:
        return 0xFF6B7280; // Gray
    }
  }

  /// Rating label
  String get ratingLabel {
    switch (rating) {
      case TideFishingRating.excellent:
        return 'Excellent';
      case TideFishingRating.good:
        return 'Good';
      case TideFishingRating.fair:
        return 'Fair';
      case TideFishingRating.poor:
        return 'Poor';
    }
  }
}

/// Current tide conditions for a station.
class TideConditions {
  final TideStation station;
  final TideReading? currentReading;
  final List<TidePrediction> predictions; // High/low predictions
  final List<TideReading> history; // Recent readings for trend
  final DateTime fetchedAt;

  const TideConditions({
    required this.station,
    this.currentReading,
    required this.predictions,
    required this.history,
    required this.fetchedAt,
  });

  /// Current tide state (rising/falling/slack)
  TideType get currentState {
    if (predictions.length < 2) return TideType.slack;

    final now = DateTime.now();

    // Find the next high/low
    TidePrediction? nextEvent;

    for (final pred in predictions) {
      if (pred.timestamp.isAfter(now)) {
        nextEvent = pred;
        break;
      }
    }

    if (nextEvent == null) return TideType.slack;

    // If next event is high tide, we're rising; if low, we're falling
    return nextEvent.isHigh ? TideType.rising : TideType.falling;
  }

  /// Next high tide prediction
  TidePrediction? get nextHighTide {
    final now = DateTime.now();
    for (final pred in predictions) {
      if (pred.isHigh && pred.timestamp.isAfter(now)) {
        return pred;
      }
    }
    return null;
  }

  /// Next low tide prediction
  TidePrediction? get nextLowTide {
    final now = DateTime.now();
    for (final pred in predictions) {
      if (!pred.isHigh && pred.timestamp.isAfter(now)) {
        return pred;
      }
    }
    return null;
  }

  /// Next tide event (high or low)
  TidePrediction? get nextTideEvent {
    final now = DateTime.now();
    for (final pred in predictions) {
      if (pred.timestamp.isAfter(now)) {
        return pred;
      }
    }
    return null;
  }

  /// Time until next tide event
  Duration? get timeUntilNextEvent {
    final next = nextTideEvent;
    if (next == null) return null;
    return next.timestamp.difference(DateTime.now());
  }

  /// Estimated movement rate in ft/hour based on predictions
  double? get movementRate {
    if (predictions.length < 2) return null;

    final now = DateTime.now();
    TidePrediction? prev;
    TidePrediction? next;

    for (int i = 0; i < predictions.length; i++) {
      if (predictions[i].timestamp.isAfter(now)) {
        next = predictions[i];
        if (i > 0) prev = predictions[i - 1];
        break;
      }
      prev = predictions[i];
    }

    if (prev == null || next == null) return null;

    final heightDiff = (next.heightFt - prev.heightFt).abs();
    final hoursDiff = next.timestamp.difference(prev.timestamp).inMinutes / 60.0;

    if (hoursDiff == 0) return null;
    return heightDiff / hoursDiff;
  }

  /// Whether tide is currently moving fast (good for fishing)
  bool get isMovingFast {
    final rate = movementRate;
    if (rate == null) return false;
    return rate > 0.3; // More than 0.3 ft/hour
  }

  /// Tide range for current cycle
  double? get tidalRange {
    if (predictions.length < 2) return null;

    double? lastHigh;
    double? lastLow;

    for (final pred in predictions) {
      if (pred.isHigh) {
        lastHigh = pred.heightFt;
      } else {
        lastLow = pred.heightFt;
      }
      if (lastHigh != null && lastLow != null) break;
    }

    if (lastHigh == null || lastLow == null) return null;
    return (lastHigh - lastLow).abs();
  }
}

/// A water body that has tidal influence.
class TidalWater {
  final String lakeId;
  final String name;
  final String primaryStationId;
  final List<String>? secondaryStationIds;
  final double tidalInfluence; // 0-1, how much tide affects fishing
  final String notes;

  const TidalWater({
    required this.lakeId,
    required this.name,
    required this.primaryStationId,
    this.secondaryStationIds,
    required this.tidalInfluence,
    required this.notes,
  });

  factory TidalWater.fromJson(Map<String, dynamic> json) {
    return TidalWater(
      lakeId: json['lake_id'] as String,
      name: json['name'] as String,
      primaryStationId: json['primary_station_id'] as String,
      secondaryStationIds: (json['secondary_station_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tidalInfluence: (json['tidal_influence'] as num).toDouble(),
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'lake_id': lakeId,
    'name': name,
    'primary_station_id': primaryStationId,
    'secondary_station_ids': secondaryStationIds,
    'tidal_influence': tidalInfluence,
    'notes': notes,
  };

  /// Whether this water has significant tidal influence
  bool get hasSignificantTide => tidalInfluence >= 0.5;
}

/// Fishing impact assessment based on tide conditions.
class TideFishingImpact {
  final TideFishingRating overallRating;
  final String summary;
  final List<String> positives;
  final List<String> negatives;
  final List<String> recommendations;

  const TideFishingImpact({
    required this.overallRating,
    required this.summary,
    required this.positives,
    required this.negatives,
    required this.recommendations,
  });

  factory TideFishingImpact.fromConditions(TideConditions conditions) {
    final state = conditions.currentState;
    final rate = conditions.movementRate ?? 0;
    final range = conditions.tidalRange ?? 0;

    List<String> positives = [];
    List<String> negatives = [];
    List<String> recommendations = [];

    TideFishingRating rating;
    String summary;

    // Analyze current state
    if (state == TideType.rising || state == TideType.falling) {
      if (rate > 0.5) {
        // Fast movement - excellent
        rating = TideFishingRating.excellent;
        summary = 'Peak tide movement - fish are actively feeding!';
        positives.add('Strong water movement pushing baitfish');
        positives.add('Crappie positioned to ambush prey');
        recommendations.add('Target current breaks and structure edges');
        recommendations.add('Use more active retrieves');
      } else if (rate > 0.2) {
        // Moderate movement - good
        rating = TideFishingRating.good;
        summary = 'Active tide movement - good feeding conditions.';
        positives.add('Steady water flow bringing nutrients');
        positives.add('Fish moving and feeding');
        recommendations.add('Fish mid-depth structure');
        recommendations.add('Jig minnow patterns work well');
      } else {
        // Slow movement - fair
        rating = TideFishingRating.fair;
        summary = 'Light tide movement - moderate activity expected.';
        negatives.add('Slower water movement');
        recommendations.add('Slow down presentations');
        recommendations.add('Target deeper holding areas');
      }

      if (state == TideType.rising) {
        positives.add('Rising tide pushing fish to feeding zones');
        recommendations.add('Fish shallower structure as water rises');
      } else {
        positives.add('Falling tide concentrating baitfish');
        recommendations.add('Position near drop-offs and channel edges');
      }
    } else {
      // Slack water
      rating = TideFishingRating.poor;
      summary = 'Slack water period - fish are less active.';
      negatives.add('Minimal water movement');
      negatives.add('Fish tend to suspend and become neutral');
      recommendations.add('Wait for tide to start moving');
      recommendations.add('If fishing, use very slow presentations');
      recommendations.add('Target shade and cover');
    }

    // Tidal range impact
    if (range > 2.0) {
      positives.add('Strong tidal range = more water movement');
    } else if (range < 0.5) {
      negatives.add('Weak tidal range limits fish activity');
    }

    return TideFishingImpact(
      overallRating: rating,
      summary: summary,
      positives: positives,
      negatives: negatives,
      recommendations: recommendations,
    );
  }
}
