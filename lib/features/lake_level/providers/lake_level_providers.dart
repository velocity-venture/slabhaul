import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/features/weather/providers/lake_conditions_providers.dart';
import 'package:slabhaul/core/models/lake_conditions.dart';

/// Time range for historical data display
enum LevelHistoryRange {
  week7(7, '7 Days'),
  week14(14, '14 Days'),
  month30(30, '30 Days');

  final int days;
  final String label;
  const LevelHistoryRange(this.days, this.label);
}

/// Selected time range for lake level history
final levelHistoryRangeProvider = StateProvider<LevelHistoryRange>((ref) {
  return LevelHistoryRange.week7;
});

/// Trend analysis from recent readings
enum LevelTrend {
  rising,
  falling,
  stable,
  unknown;

  String get label {
    switch (this) {
      case LevelTrend.rising:
        return 'Rising';
      case LevelTrend.falling:
        return 'Falling';
      case LevelTrend.stable:
        return 'Stable';
      case LevelTrend.unknown:
        return 'Unknown';
    }
  }

  String get emoji {
    switch (this) {
      case LevelTrend.rising:
        return '📈';
      case LevelTrend.falling:
        return '📉';
      case LevelTrend.stable:
        return '➡️';
      case LevelTrend.unknown:
        return '❓';
    }
  }
}

/// Analyzed lake level data with trend
class LevelAnalysis {
  final LakeConditions conditions;
  final LevelTrend trend;
  final double? changePerDay; // ft/day average
  final double? change24h; // ft change in last 24h
  final double? change7d; // ft change in last 7 days
  final List<String> fishingTips;

  const LevelAnalysis({
    required this.conditions,
    required this.trend,
    this.changePerDay,
    this.change24h,
    this.change7d,
    required this.fishingTips,
  });
}

/// Provides analyzed lake level data with trend
final levelAnalysisProvider = Provider<LevelAnalysis?>((ref) {
  final conditionsAsync = ref.watch(lakeConditionsProvider);

  return conditionsAsync.whenOrNull(
    data: (conditions) => _analyzeLevelData(conditions),
  );
});

LevelAnalysis _analyzeLevelData(LakeConditions conditions) {
  final readings = conditions.recentReadings;

  if (readings.length < 2) {
    return LevelAnalysis(
      conditions: conditions,
      trend: LevelTrend.unknown,
      fishingTips: _getUnknownTips(),
    );
  }

  // Sort readings by timestamp (newest first)
  final sorted = List<LevelReading>.from(readings)
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  final latest = sorted.first;
  final now = DateTime.now();

  // Find reading closest to 24h ago
  LevelReading? reading24hAgo;
  for (final r in sorted) {
    if (now.difference(r.timestamp).inHours >= 24) {
      reading24hAgo = r;
      break;
    }
  }

  // Find reading closest to 7 days ago
  LevelReading? reading7dAgo;
  for (final r in sorted) {
    if (now.difference(r.timestamp).inDays >= 7) {
      reading7dAgo = r;
      break;
    }
  }

  // Calculate changes
  double? change24h;
  double? change7d;
  double? changePerDay;

  if (reading24hAgo != null) {
    change24h = latest.valueFt - reading24hAgo.valueFt;
  }

  if (reading7dAgo != null) {
    change7d = latest.valueFt - reading7dAgo.valueFt;
    final daysDiff = now.difference(reading7dAgo.timestamp).inHours / 24.0;
    if (daysDiff > 0) {
      changePerDay = change7d / daysDiff;
    }
  }

  // Determine trend based on recent changes
  LevelTrend trend;
  const threshold = 0.05; // ft/day threshold for "stable"

  if (changePerDay == null) {
    // Fallback to 24h change
    if (change24h == null) {
      trend = LevelTrend.unknown;
    } else if (change24h > threshold) {
      trend = LevelTrend.rising;
    } else if (change24h < -threshold) {
      trend = LevelTrend.falling;
    } else {
      trend = LevelTrend.stable;
    }
  } else {
    if (changePerDay > threshold) {
      trend = LevelTrend.rising;
    } else if (changePerDay < -threshold) {
      trend = LevelTrend.falling;
    } else {
      trend = LevelTrend.stable;
    }
  }

  // Generate fishing tips based on trend and level status
  final tips = _getFishingTips(
    trend: trend,
    levelStatus: conditions.levelStatus,
    levelDifference: conditions.levelDifference,
    change24h: change24h,
  );

  return LevelAnalysis(
    conditions: conditions,
    trend: trend,
    changePerDay: changePerDay,
    change24h: change24h,
    change7d: change7d,
    fishingTips: tips,
  );
}

List<String> _getUnknownTips() {
  return [
    'Insufficient data to analyze trends.',
    'Check back when more readings are available.',
    'Focus on structure and attractor locations.',
  ];
}

List<String> _getFishingTips({
  required LevelTrend trend,
  required String levelStatus,
  double? levelDifference,
  double? change24h,
}) {
  final tips = <String>[];

  // Trend-based tips
  switch (trend) {
    case LevelTrend.rising:
      tips.add(
          '🎣 Rising water pushes baitfish and crappie toward newly flooded cover.');
      tips.add(
          '🌿 Target brush piles and timber near the shoreline as fish move shallow.');
      if (change24h != null && change24h > 0.3) {
        tips.add(
            '⚡ Rapid rise! Fish may scatter - focus on main channel structure.');
      }
      break;

    case LevelTrend.falling:
      tips.add('📍 Falling water concentrates fish in deeper structure.');
      tips.add(
          '🎯 Focus on main lake attractors and creek channel edges.');
      if (change24h != null && change24h < -0.3) {
        tips.add(
            '⚠️ Rapid drop! Fish head deep fast - target 15-25ft structure.');
      }
      break;

    case LevelTrend.stable:
      tips.add('✅ Stable levels = predictable fish behavior.');
      tips.add(
          '🔄 Fish establish patterns - yesterday\'s spots should still produce.');
      break;

    case LevelTrend.unknown:
      break;
  }

  // Level status tips
  if (levelStatus == 'Above Normal') {
    tips.add('🌊 Above normal pool opens access to shallow flooded cover.');
    if ((levelDifference ?? 0) > 2.0) {
      tips.add(
          '🌳 Check flooded timber and bushes - crappie love this cover.');
    }
  } else if (levelStatus == 'Below Normal') {
    tips.add('⬇️ Below normal pool - fish concentrated in deeper water.');
    if ((levelDifference ?? 0) < -2.0) {
      tips.add(
          '🎯 Very low water - focus exclusively on main lake structure.');
    }
  }

  // Seasonal context (basic - could be enhanced)
  final month = DateTime.now().month;
  if (month >= 3 && month <= 5) {
    // Spring
    if (trend == LevelTrend.rising) {
      tips.add(
          '🌸 Spring + rising water = prime spawn conditions in shallows.');
    }
  } else if (month >= 10 || month <= 2) {
    // Fall/Winter
    if (trend == LevelTrend.falling) {
      tips.add('❄️ Fall/winter drawdown - fish stack on deep structure.');
    }
  }

  return tips.take(5).toList(); // Limit to 5 tips
}
