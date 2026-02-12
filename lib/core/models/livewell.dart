// Livewell Management Models
//
// Monitor livewell conditions to keep crappie alive and healthy.
// Evaluates temperature, overcrowding, and equipment to provide
// real-time status alerts and recommendations.

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Overall livewell health status
enum LivewellStatus {
  safe,
  caution,
  danger,
}

extension LivewellStatusX on LivewellStatus {
  String get displayName {
    switch (this) {
      case LivewellStatus.safe:
        return 'Safe';
      case LivewellStatus.caution:
        return 'Caution';
      case LivewellStatus.danger:
        return 'Danger';
    }
  }

  String get icon {
    switch (this) {
      case LivewellStatus.safe:
        return 'check_circle';
      case LivewellStatus.caution:
        return 'warning';
      case LivewellStatus.danger:
        return 'error';
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// An alert generated from evaluating livewell conditions
@immutable
class LivewellAlert {
  final LivewellStatus status;
  final String message;
  final String recommendation;
  final DateTime timestamp;

  const LivewellAlert({
    required this.status,
    required this.message,
    required this.recommendation,
    required this.timestamp,
  });

  factory LivewellAlert.fromJson(Map<String, dynamic> json) {
    return LivewellAlert(
      status: LivewellStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => LivewellStatus.safe,
      ),
      message: json['message'] as String,
      recommendation: json['recommendation'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'message': message,
        'recommendation': recommendation,
        'timestamp': timestamp.toIso8601String(),
      };

  LivewellAlert copyWith({
    LivewellStatus? status,
    String? message,
    String? recommendation,
    DateTime? timestamp,
  }) {
    return LivewellAlert(
      status: status ?? this.status,
      message: message ?? this.message,
      recommendation: recommendation ?? this.recommendation,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

/// Current livewell conditions snapshot for evaluation
@immutable
class LivewellConditions {
  final double waterTempF;
  final double airTempF;
  final int fishCount;
  final double livewellSizeGallons;
  final bool hasAerator;
  final bool hasRecirculator;
  final bool isInsulated;

  const LivewellConditions({
    required this.waterTempF,
    required this.airTempF,
    required this.fishCount,
    this.livewellSizeGallons = 25,
    this.hasAerator = false,
    this.hasRecirculator = false,
    this.isInsulated = false,
  });

  factory LivewellConditions.fromJson(Map<String, dynamic> json) {
    return LivewellConditions(
      waterTempF: (json['water_temp_f'] as num).toDouble(),
      airTempF: (json['air_temp_f'] as num).toDouble(),
      fishCount: json['fish_count'] as int,
      livewellSizeGallons:
          (json['livewell_size_gallons'] as num?)?.toDouble() ?? 25,
      hasAerator: json['has_aerator'] as bool? ?? false,
      hasRecirculator: json['has_recirculator'] as bool? ?? false,
      isInsulated: json['is_insulated'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'water_temp_f': waterTempF,
        'air_temp_f': airTempF,
        'fish_count': fishCount,
        'livewell_size_gallons': livewellSizeGallons,
        'has_aerator': hasAerator,
        'has_recirculator': hasRecirculator,
        'is_insulated': isInsulated,
      };

  LivewellConditions copyWith({
    double? waterTempF,
    double? airTempF,
    int? fishCount,
    double? livewellSizeGallons,
    bool? hasAerator,
    bool? hasRecirculator,
    bool? isInsulated,
  }) {
    return LivewellConditions(
      waterTempF: waterTempF ?? this.waterTempF,
      airTempF: airTempF ?? this.airTempF,
      fishCount: fishCount ?? this.fishCount,
      livewellSizeGallons: livewellSizeGallons ?? this.livewellSizeGallons,
      hasAerator: hasAerator ?? this.hasAerator,
      hasRecirculator: hasRecirculator ?? this.hasRecirculator,
      isInsulated: isInsulated ?? this.isInsulated,
    );
  }

  /// Gallons available per fish (higher is better)
  double get gallonsPerFish =>
      fishCount > 0 ? livewellSizeGallons / fishCount : livewellSizeGallons;

  /// Temperature differential between air and water
  double get tempDifferentialF => airTempF - waterTempF;
}
