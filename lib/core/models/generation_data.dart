/// Dam generation schedule data for TVA and other power authorities.
///
/// Generation (water release through turbines) creates current that
/// triggers feeding behavior in crappie and other species.
class GenerationData {
  final String damId;
  final String damName;
  final String lakeName;
  final String powerAuthority; // 'TVA', 'USACE', 'Alabama Power', etc.
  final GenerationStatus currentStatus;
  final double? currentDischargeCfs;
  final double? baseflowCfs;
  final DateTime? lastUpdated;
  final List<GenerationReading> recentReadings;
  final List<ScheduledGeneration> upcomingSchedule;
  final GenerationPattern? typicalPattern;

  const GenerationData({
    required this.damId,
    required this.damName,
    required this.lakeName,
    required this.powerAuthority,
    required this.currentStatus,
    this.currentDischargeCfs,
    this.baseflowCfs,
    this.lastUpdated,
    this.recentReadings = const [],
    this.upcomingSchedule = const [],
    this.typicalPattern,
  });

  /// Is water currently being released at generation-level rates?
  bool get isGenerating => currentStatus == GenerationStatus.generating;

  /// Ratio of current discharge to baseflow (>1 = generation)
  double? get dischargeRatio {
    if (currentDischargeCfs == null || baseflowCfs == null || baseflowCfs == 0) {
      return null;
    }
    return currentDischargeCfs! / baseflowCfs!;
  }

  /// Next scheduled generation window
  ScheduledGeneration? get nextScheduled {
    final now = DateTime.now();
    return upcomingSchedule
        .where((s) => s.startTime.isAfter(now))
        .fold<ScheduledGeneration?>(null, (prev, s) =>
            prev == null || s.startTime.isBefore(prev.startTime) ? s : prev);
  }

  /// Time until next generation (null if unknown or currently generating)
  Duration? get timeUntilGeneration {
    if (isGenerating) return Duration.zero;
    final next = nextScheduled;
    if (next == null) return null;
    return next.startTime.difference(DateTime.now());
  }
}

/// Current generation status
enum GenerationStatus {
  generating,    // Water actively being released through turbines
  idle,          // Minimal baseflow only
  scheduled,     // Not generating now, but scheduled soon (within 2 hours)
  unknown,       // Cannot determine status
}

/// A single discharge reading from the dam
class GenerationReading {
  final DateTime timestamp;
  final double dischargeCfs;
  final bool isGenerating;

  const GenerationReading({
    required this.timestamp,
    required this.dischargeCfs,
    required this.isGenerating,
  });
}

/// A scheduled generation window
class ScheduledGeneration {
  final DateTime startTime;
  final DateTime? endTime;
  final int? estimatedUnits; // Number of generating units
  final double? estimatedDischargeCfs;
  final String? notes;

  const ScheduledGeneration({
    required this.startTime,
    this.endTime,
    this.estimatedUnits,
    this.estimatedDischargeCfs,
    this.notes,
  });

  Duration? get duration {
    if (endTime == null) return null;
    return endTime!.difference(startTime);
  }
}

/// Typical daily generation patterns (based on historical data)
class GenerationPattern {
  final List<int> peakHours;        // Hours when generation most likely (0-23)
  final List<int> offPeakHours;     // Hours when generation least likely
  final double weekdayProbability;   // Likelihood of generation on weekdays
  final double weekendProbability;   // Likelihood of generation on weekends
  final String notes;

  const GenerationPattern({
    required this.peakHours,
    required this.offPeakHours,
    required this.weekdayProbability,
    required this.weekendProbability,
    this.notes = '',
  });

  /// Is the current hour typically a peak generation hour?
  bool get isCurrentlyPeakHour {
    return peakHours.contains(DateTime.now().hour);
  }
}

/// Dam configuration for generation tracking
class DamConfig {
  final String id;
  final String name;
  final String lakeName;
  final String powerAuthority;
  final double latitude;
  final double longitude;
  final String? usgsGageId;       // USGS gage below dam for discharge
  final double? baseflowCfs;      // Typical minimum discharge
  final double? generationThresholdCfs; // Discharge level indicating generation
  final String? tvaLakeCode;      // TVA's internal lake code (e.g., 'KY')
  final GenerationPattern? typicalPattern;

  const DamConfig({
    required this.id,
    required this.name,
    required this.lakeName,
    required this.powerAuthority,
    required this.latitude,
    required this.longitude,
    this.usgsGageId,
    this.baseflowCfs,
    this.generationThresholdCfs,
    this.tvaLakeCode,
    this.typicalPattern,
  });
}

/// Pre-configured TVA dams
class TvaDams {
  static const kentucky = DamConfig(
    id: 'kentucky',
    name: 'Kentucky Dam',
    lakeName: 'Kentucky Lake',
    powerAuthority: 'TVA',
    latitude: 37.0064,
    longitude: -88.2678,
    tvaLakeCode: 'KY',
    baseflowCfs: 8000,
    generationThresholdCfs: 25000,
    typicalPattern: GenerationPattern(
      peakHours: [6, 7, 8, 9, 17, 18, 19, 20],
      offPeakHours: [0, 1, 2, 3, 4, 12, 13, 14],
      weekdayProbability: 0.75,
      weekendProbability: 0.45,
      notes: 'Peak generation during morning/evening demand periods',
    ),
  );

  static const pickwick = DamConfig(
    id: 'pickwick',
    name: 'Pickwick Dam',
    lakeName: 'Pickwick Lake',
    powerAuthority: 'TVA',
    latitude: 35.0561,
    longitude: -88.2594,
    tvaLakeCode: 'PI',
    baseflowCfs: 10000,
    generationThresholdCfs: 30000,
    typicalPattern: GenerationPattern(
      peakHours: [6, 7, 8, 9, 17, 18, 19, 20],
      offPeakHours: [0, 1, 2, 3, 4, 12, 13, 14],
      weekdayProbability: 0.70,
      weekendProbability: 0.40,
      notes: 'Run-of-river dam; generation more consistent',
    ),
  );

  static const wheeler = DamConfig(
    id: 'wheeler',
    name: 'Wheeler Dam',
    lakeName: 'Wheeler Lake',
    powerAuthority: 'TVA',
    latitude: 34.7819,
    longitude: -87.4003,
    tvaLakeCode: 'WH',
    baseflowCfs: 12000,
    generationThresholdCfs: 35000,
    typicalPattern: GenerationPattern(
      peakHours: [6, 7, 8, 9, 17, 18, 19, 20],
      offPeakHours: [0, 1, 2, 3, 4, 12, 13, 14],
      weekdayProbability: 0.72,
      weekendProbability: 0.38,
      notes: 'Run-of-river dam with consistent baseflow',
    ),
  );

  static const guntersville = DamConfig(
    id: 'guntersville',
    name: 'Guntersville Dam',
    lakeName: 'Guntersville Lake',
    powerAuthority: 'TVA',
    latitude: 34.4161,
    longitude: -86.2917,
    tvaLakeCode: 'GU',
    baseflowCfs: 15000,
    generationThresholdCfs: 40000,
    typicalPattern: GenerationPattern(
      peakHours: [6, 7, 8, 9, 17, 18, 19, 20],
      offPeakHours: [0, 1, 2, 3, 4, 12, 13, 14],
      weekdayProbability: 0.68,
      weekendProbability: 0.35,
      notes: 'Largest TVA reservoir; highly variable generation',
    ),
  );

  static List<DamConfig> get all => [kentucky, pickwick, wheeler, guntersville];

  static DamConfig? forLake(String lakeName) {
    final lower = lakeName.toLowerCase();
    if (lower.contains('kentucky')) return kentucky;
    if (lower.contains('pickwick')) return pickwick;
    if (lower.contains('wheeler')) return wheeler;
    if (lower.contains('guntersville')) return guntersville;
    return null;
  }
}
