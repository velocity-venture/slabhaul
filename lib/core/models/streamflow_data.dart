/// Streamflow and inflow data models for water flow analysis.
library;

/// Represents a USGS streamflow monitoring station.
class StreamflowStation {
  final String siteId;
  final String name;
  final double latitude;
  final double longitude;
  final String streamName;
  final String? stateCode;
  final String? countyName;
  final double? drainageAreaSqMi;

  const StreamflowStation({
    required this.siteId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.streamName,
    this.stateCode,
    this.countyName,
    this.drainageAreaSqMi,
  });

  factory StreamflowStation.fromJson(Map<String, dynamic> json) {
    return StreamflowStation(
      siteId: json['site_id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      streamName: json['stream_name'] as String,
      stateCode: json['state_code'] as String?,
      countyName: json['county_name'] as String?,
      drainageAreaSqMi: (json['drainage_area_sq_mi'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'site_id': siteId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'stream_name': streamName,
    'state_code': stateCode,
    'county_name': countyName,
    'drainage_area_sq_mi': drainageAreaSqMi,
  };
}

/// A single streamflow reading from a USGS gage.
class StreamflowReading {
  final DateTime timestamp;
  final double flowRateCfs; // cubic feet per second
  final double? gageHeightFt; // gage height in feet
  final String? qualifier; // data quality indicator

  const StreamflowReading({
    required this.timestamp,
    required this.flowRateCfs,
    this.gageHeightFt,
    this.qualifier,
  });

  factory StreamflowReading.fromJson(Map<String, dynamic> json) {
    return StreamflowReading(
      timestamp: DateTime.parse(json['timestamp'] as String),
      flowRateCfs: (json['flow_rate_cfs'] as num).toDouble(),
      gageHeightFt: (json['gage_height_ft'] as num?)?.toDouble(),
      qualifier: json['qualifier'] as String?,
    );
  }

  /// Flow rate category for display
  FlowMagnitude get magnitude {
    if (flowRateCfs < 50) return FlowMagnitude.veryLow;
    if (flowRateCfs < 200) return FlowMagnitude.low;
    if (flowRateCfs < 1000) return FlowMagnitude.normal;
    if (flowRateCfs < 5000) return FlowMagnitude.high;
    if (flowRateCfs < 20000) return FlowMagnitude.veryHigh;
    return FlowMagnitude.flood;
  }

  /// Human-readable flow rate
  String get flowRateDisplay {
    if (flowRateCfs >= 10000) {
      return '${(flowRateCfs / 1000).toStringAsFixed(1)}K cfs';
    }
    return '${flowRateCfs.toStringAsFixed(0)} cfs';
  }
}

/// Flow magnitude categories.
enum FlowMagnitude {
  veryLow,
  low,
  normal,
  high,
  veryHigh,
  flood,
}

/// Flow trend direction.
enum FlowTrend {
  rising,
  stable,
  falling,
}

/// Predicted/forecasted flow rate.
class StreamflowForecast {
  final DateTime timestamp;
  final double predictedFlowCfs;
  final double? confidenceLow;
  final double? confidenceHigh;

  const StreamflowForecast({
    required this.timestamp,
    required this.predictedFlowCfs,
    this.confidenceLow,
    this.confidenceHigh,
  });
}

/// A point where water enters a lake (stream inlet, river mouth, etc.)
class InflowPoint {
  final String id;
  final String lakeId;
  final String name;
  final double latitude;
  final double longitude;
  final String streamName;
  final String? usgsGageId;
  final double? avgAnnualFlowCfs;
  final double? drainageAreaSqMi;
  final String? description;

  const InflowPoint({
    required this.id,
    required this.lakeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.streamName,
    this.usgsGageId,
    this.avgAnnualFlowCfs,
    this.drainageAreaSqMi,
    this.description,
  });

  factory InflowPoint.fromJson(Map<String, dynamic> json) {
    return InflowPoint(
      id: json['id'] as String,
      lakeId: json['lake_id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      streamName: json['stream_name'] as String,
      usgsGageId: json['usgs_gage_id'] as String?,
      avgAnnualFlowCfs: (json['avg_annual_flow_cfs'] as num?)?.toDouble(),
      drainageAreaSqMi: (json['drainage_area_sq_mi'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'lake_id': lakeId,
    'name': name,
    'latitude': latitude,
    'longitude': longitude,
    'stream_name': streamName,
    'usgs_gage_id': usgsGageId,
    'avg_annual_flow_cfs': avgAnnualFlowCfs,
    'drainage_area_sq_mi': drainageAreaSqMi,
    'description': description,
  };

  /// Whether this inflow has real-time USGS data
  bool get hasRealtimeData => usgsGageId != null;

  /// Relative size category based on avg flow
  InflowSize get size {
    final flow = avgAnnualFlowCfs ?? 0;
    if (flow >= 5000) return InflowSize.major;
    if (flow >= 500) return InflowSize.large;
    if (flow >= 50) return InflowSize.medium;
    return InflowSize.small;
  }
}

/// Inflow point size categories.
enum InflowSize {
  small,
  medium,
  large,
  major,
}

/// Current streamflow conditions compared to historical averages.
class StreamflowConditions {
  final StreamflowStation station;
  final StreamflowReading currentReading;
  final List<StreamflowReading> history; // 7-day history
  final double? historicalMedianCfs; // Median flow for this time of year
  final double? historicalPercentile; // Where current flow falls (0-100)

  const StreamflowConditions({
    required this.station,
    required this.currentReading,
    required this.history,
    this.historicalMedianCfs,
    this.historicalPercentile,
  });

  /// Flow trend over past 24 hours
  FlowTrend get trend {
    if (history.length < 2) return FlowTrend.stable;

    // Compare recent readings to older readings
    final recent = history.take((history.length / 3).ceil()).toList();
    final older = history.skip((history.length * 2 / 3).ceil()).toList();

    if (recent.isEmpty || older.isEmpty) return FlowTrend.stable;

    final recentAvg = recent.fold(0.0, (sum, r) => sum + r.flowRateCfs) / recent.length;
    final olderAvg = older.fold(0.0, (sum, r) => sum + r.flowRateCfs) / older.length;

    final changePercent = ((recentAvg - olderAvg) / olderAvg) * 100;

    if (changePercent > 15) return FlowTrend.rising;
    if (changePercent < -15) return FlowTrend.falling;
    return FlowTrend.stable;
  }

  /// Comparison to historical median
  FlowComparison get comparisonToNormal {
    if (historicalPercentile == null) return FlowComparison.unknown;
    
    final p = historicalPercentile!;
    if (p < 10) return FlowComparison.muchBelowNormal;
    if (p < 25) return FlowComparison.belowNormal;
    if (p < 75) return FlowComparison.normal;
    if (p < 90) return FlowComparison.aboveNormal;
    return FlowComparison.muchAboveNormal;
  }

  /// Rate of change in cfs/hour over past 6 hours
  double? get rateOfChangeCfsPerHour {
    if (history.length < 2) return null;

    final sortedHistory = List<StreamflowReading>.from(history)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final recent = sortedHistory.last;
    final older = sortedHistory.first;
    
    final hours = recent.timestamp.difference(older.timestamp).inHours;
    if (hours == 0) return null;

    return (recent.flowRateCfs - older.flowRateCfs) / hours;
  }

  /// 24-hour change percentage
  double? get change24HourPercent {
    if (history.isEmpty) return null;

    final now = currentReading.flowRateCfs;
    final target = DateTime.now().subtract(const Duration(hours: 24));

    // Find closest reading to 24 hours ago
    StreamflowReading? closest;
    Duration? closestDiff;

    for (final reading in history) {
      final diff = reading.timestamp.difference(target).abs();
      if (closestDiff == null || diff < closestDiff) {
        closest = reading;
        closestDiff = diff;
      }
    }

    if (closest == null || closestDiff! > const Duration(hours: 6)) {
      return null; // No reading close enough to 24h ago
    }

    return ((now - closest.flowRateCfs) / closest.flowRateCfs) * 100;
  }
}

/// Comparison to historical normal flows.
enum FlowComparison {
  unknown,
  muchBelowNormal, // < 10th percentile
  belowNormal, // 10-25th percentile
  normal, // 25-75th percentile
  aboveNormal, // 75-90th percentile
  muchAboveNormal, // > 90th percentile
}

/// Aggregated inflow data for a single inflow point with live readings.
class InflowConditions {
  final InflowPoint inflow;
  final StreamflowConditions? conditions; // null if no USGS gage
  final DateTime fetchedAt;

  const InflowConditions({
    required this.inflow,
    this.conditions,
    required this.fetchedAt,
  });

  /// Current flow rate (live if available, otherwise estimated)
  double get currentFlowCfs {
    return conditions?.currentReading.flowRateCfs ?? 
           inflow.avgAnnualFlowCfs ?? 
           0;
  }

  /// Flow trend
  FlowTrend get trend => conditions?.trend ?? FlowTrend.stable;

  /// Whether live data is available
  bool get hasLiveData => conditions != null;
}

/// Fishing impact assessment based on streamflow conditions.
class StreamflowFishingImpact {
  final FlowImpactLevel overallImpact;
  final String summary;
  final List<String> positives;
  final List<String> negatives;
  final List<String> recommendations;

  const StreamflowFishingImpact({
    required this.overallImpact,
    required this.summary,
    required this.positives,
    required this.negatives,
    required this.recommendations,
  });

  factory StreamflowFishingImpact.fromConditions(StreamflowConditions conditions) {
    final trend = conditions.trend;
    final comparison = conditions.comparisonToNormal;
    // Flow value available for future use: conditions.currentReading.flowRateCfs

    List<String> positives = [];
    List<String> negatives = [];
    List<String> recommendations = [];

    // Analyze rising water
    if (trend == FlowTrend.rising) {
      positives.add('Rising water brings nutrients and baitfish');
      positives.add('Fish often feed more actively');
      recommendations.add('Target newly flooded areas and creek channels');
      recommendations.add('Mudlines can concentrate fish');
    }

    // Analyze falling water
    if (trend == FlowTrend.falling) {
      positives.add('Fish concentrate as water recedes');
      positives.add('Main channel and deep areas become productive');
      negatives.add('Fish may become more lethargic');
      recommendations.add('Focus on creek mouths and deep structure');
    }

    // Analyze high flow
    if (comparison == FlowComparison.aboveNormal || 
        comparison == FlowComparison.muchAboveNormal) {
      positives.add('High flow brings oxygen and fresh baitfish');
      negatives.add('Current may push fish to slack water');
      negatives.add('Visibility may be reduced');
      recommendations.add('Fish eddies and current breaks');
      recommendations.add('Use brighter colors in murky water');
    }

    // Analyze low flow
    if (comparison == FlowComparison.belowNormal || 
        comparison == FlowComparison.muchBelowNormal) {
      positives.add('Fish are concentrated in main channel');
      positives.add('Clear water for sight fishing');
      negatives.add('Fish may be more spooky in clear water');
      negatives.add('Less food being washed in');
      recommendations.add('Use longer leaders and finesse presentations');
      recommendations.add('Fish deeper water during midday');
    }

    // Determine overall impact
    FlowImpactLevel overallImpact;
    String summary;

    if (trend == FlowTrend.rising && 
        (comparison == FlowComparison.normal || comparison == FlowComparison.aboveNormal)) {
      overallImpact = FlowImpactLevel.excellent;
      summary = 'Rising water with good flow - prime fishing conditions!';
    } else if (trend == FlowTrend.stable && comparison == FlowComparison.normal) {
      overallImpact = FlowImpactLevel.good;
      summary = 'Stable, normal flow - consistent fishing expected.';
    } else if (comparison == FlowComparison.muchAboveNormal) {
      overallImpact = FlowImpactLevel.poor;
      summary = 'Very high flow - challenging but fish may stack in slack water.';
    } else if (comparison == FlowComparison.muchBelowNormal) {
      overallImpact = FlowImpactLevel.fair;
      summary = 'Low water - fish are concentrated but cautious.';
    } else {
      overallImpact = FlowImpactLevel.fair;
      summary = 'Mixed conditions - adapt your approach.';
    }

    return StreamflowFishingImpact(
      overallImpact: overallImpact,
      summary: summary,
      positives: positives,
      negatives: negatives,
      recommendations: recommendations,
    );
  }
}

/// Overall fishing impact level from flow conditions.
enum FlowImpactLevel {
  poor,
  fair,
  good,
  excellent,
}
