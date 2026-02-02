class LakeConditions {
  final String lakeId;
  final double? waterLevelFt;
  final double? normalPoolFt;
  final double? waterTempF;
  final DateTime? lastUpdated;
  final String? usgsGageId;
  final List<LevelReading> recentReadings;

  const LakeConditions({
    required this.lakeId,
    this.waterLevelFt,
    this.normalPoolFt,
    this.waterTempF,
    this.lastUpdated,
    this.usgsGageId,
    this.recentReadings = const [],
  });

  double? get levelDifference {
    if (waterLevelFt == null || normalPoolFt == null) return null;
    return waterLevelFt! - normalPoolFt!;
  }

  String get levelStatus {
    final diff = levelDifference;
    if (diff == null) return 'Unknown';
    if (diff > 1.0) return 'Above Normal';
    if (diff < -1.0) return 'Below Normal';
    return 'Normal';
  }
}

class LevelReading {
  final DateTime timestamp;
  final double valueFt;

  const LevelReading({
    required this.timestamp,
    required this.valueFt,
  });
}
