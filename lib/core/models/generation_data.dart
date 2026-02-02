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
  final GenerationHistory? history7Day;
  final DetectedPattern? detectedPattern;
  final int? currentGeneratorCount;

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
    this.history7Day,
    this.detectedPattern,
    this.currentGeneratorCount,
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
  final int? generatorCount; // Estimated number of units running

  const GenerationReading({
    required this.timestamp,
    required this.dischargeCfs,
    required this.isGenerating,
    this.generatorCount,
  });

  /// Intensity level (0 = idle, 1 = low, 2 = moderate, 3+ = high)
  int get intensityLevel {
    if (!isGenerating) return 0;
    if (generatorCount != null) {
      return generatorCount!.clamp(0, 4);
    }
    // Estimate from discharge if generator count unknown
    if (dischargeCfs < 20000) return 1;
    if (dischargeCfs < 35000) return 2;
    if (dischargeCfs < 50000) return 3;
    return 4;
  }
}

/// Historical generation data with analysis
class GenerationHistory {
  final List<GenerationReading> readings;
  final int totalReadings;
  final int generatingCount;
  final double averageFlowCfs;
  final double maxFlowCfs;
  final double minFlowCfs;
  final Duration totalGenerationTime;
  final List<GenerationWindow> generationWindows;

  const GenerationHistory({
    required this.readings,
    required this.totalReadings,
    required this.generatingCount,
    required this.averageFlowCfs,
    required this.maxFlowCfs,
    required this.minFlowCfs,
    required this.totalGenerationTime,
    this.generationWindows = const [],
  });

  /// Percentage of time generating
  double get generatingPercent =>
      totalReadings > 0 ? (generatingCount / totalReadings) * 100 : 0;

  factory GenerationHistory.fromReadings(List<GenerationReading> readings) {
    if (readings.isEmpty) {
      return const GenerationHistory(
        readings: [],
        totalReadings: 0,
        generatingCount: 0,
        averageFlowCfs: 0,
        maxFlowCfs: 0,
        minFlowCfs: 0,
        totalGenerationTime: Duration.zero,
      );
    }

    final sorted = List<GenerationReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int genCount = 0;
    double totalFlow = 0;
    double maxFlow = 0;
    double minFlow = double.infinity;

    for (final r in sorted) {
      if (r.isGenerating) genCount++;
      totalFlow += r.dischargeCfs;
      if (r.dischargeCfs > maxFlow) maxFlow = r.dischargeCfs;
      if (r.dischargeCfs < minFlow) minFlow = r.dischargeCfs;
    }

    // Find generation windows
    final windows = <GenerationWindow>[];
    GenerationReading? windowStart;

    for (var i = 0; i < sorted.length; i++) {
      final r = sorted[i];
      if (r.isGenerating && windowStart == null) {
        windowStart = r;
      } else if (!r.isGenerating && windowStart != null) {
        windows.add(GenerationWindow(
          start: windowStart.timestamp,
          end: sorted[i - 1].timestamp,
          peakFlowCfs: sorted
              .sublist(
                sorted.indexOf(windowStart),
                i,
              )
              .map((x) => x.dischargeCfs)
              .reduce((a, b) => a > b ? a : b),
        ));
        windowStart = null;
      }
    }

    // Handle ongoing window
    if (windowStart != null) {
      windows.add(GenerationWindow(
        start: windowStart.timestamp,
        end: null, // Still ongoing
        peakFlowCfs: sorted
            .sublist(sorted.indexOf(windowStart))
            .map((x) => x.dischargeCfs)
            .reduce((a, b) => a > b ? a : b),
      ));
    }

    // Calculate total generation time
    var totalGenTime = Duration.zero;
    for (final w in windows) {
      totalGenTime += w.duration ?? Duration.zero;
    }

    return GenerationHistory(
      readings: sorted,
      totalReadings: sorted.length,
      generatingCount: genCount,
      averageFlowCfs: totalFlow / sorted.length,
      maxFlowCfs: maxFlow,
      minFlowCfs: minFlow == double.infinity ? 0 : minFlow,
      totalGenerationTime: totalGenTime,
      generationWindows: windows,
    );
  }
}

/// A continuous window of generation activity
class GenerationWindow {
  final DateTime start;
  final DateTime? end; // null if ongoing
  final double peakFlowCfs;

  const GenerationWindow({
    required this.start,
    this.end,
    required this.peakFlowCfs,
  });

  Duration? get duration => end?.difference(start);
  bool get isOngoing => end == null;
}

/// Detected generation pattern from historical data
class DetectedPattern {
  final List<int> mostCommonHours;
  final double weekdayFrequency;
  final double weekendFrequency;
  final String description;
  final double confidence; // 0.0 to 1.0

  const DetectedPattern({
    required this.mostCommonHours,
    required this.weekdayFrequency,
    required this.weekendFrequency,
    required this.description,
    required this.confidence,
  });

  factory DetectedPattern.analyze(List<GenerationReading> readings) {
    if (readings.isEmpty) {
      return const DetectedPattern(
        mostCommonHours: [],
        weekdayFrequency: 0,
        weekendFrequency: 0,
        description: 'Insufficient data',
        confidence: 0,
      );
    }

    // Count generation by hour
    final hourCounts = <int, int>{};
    int weekdayGen = 0, weekdayTotal = 0;
    int weekendGen = 0, weekendTotal = 0;

    for (final r in readings) {
      final hour = r.timestamp.hour;
      final isWeekday = r.timestamp.weekday <= 5;

      if (isWeekday) {
        weekdayTotal++;
        if (r.isGenerating) weekdayGen++;
      } else {
        weekendTotal++;
        if (r.isGenerating) weekendGen++;
      }

      if (r.isGenerating) {
        hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
      }
    }

    // Find most common hours
    final sortedHours = hourCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topHours =
        sortedHours.take(4).map((e) => e.key).toList()..sort();

    final weekdayFreq =
        weekdayTotal > 0 ? weekdayGen / weekdayTotal : 0.0;
    final weekendFreq =
        weekendTotal > 0 ? weekendGen / weekendTotal : 0.0;

    // Generate description
    String desc;
    if (topHours.isEmpty) {
      desc = 'Generation rarely occurs';
    } else if (topHours.every((h) => h >= 6 && h <= 10)) {
      desc = 'Primarily morning generation (${_formatHourRange(topHours)})';
    } else if (topHours.every((h) => h >= 16 && h <= 21)) {
      desc = 'Primarily evening generation (${_formatHourRange(topHours)})';
    } else if (topHours.any((h) => h >= 6 && h <= 10) &&
        topHours.any((h) => h >= 16 && h <= 21)) {
      desc = 'Morning and evening peaks';
    } else {
      desc = 'Most active: ${_formatHourRange(topHours)}';
    }

    // Confidence based on data volume
    final confidence = (readings.length / 168).clamp(0.0, 1.0); // 168 = 7 days hourly

    return DetectedPattern(
      mostCommonHours: topHours,
      weekdayFrequency: weekdayFreq,
      weekendFrequency: weekendFreq,
      description: desc,
      confidence: confidence,
    );
  }

  static String _formatHourRange(List<int> hours) {
    if (hours.isEmpty) return '';
    final formatted = hours.map((h) {
      if (h == 0) return '12 AM';
      if (h < 12) return '$h AM';
      if (h == 12) return '12 PM';
      return '${h - 12} PM';
    });
    return formatted.join(', ');
  }
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
