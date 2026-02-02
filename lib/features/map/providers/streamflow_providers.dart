import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/streamflow_data.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Controls whether the streamflow/inflow layer is visible on the map.
final streamflowEnabledProvider = StateProvider<bool>((ref) => false);

/// The streamflow service provider.
final streamflowServiceProvider = Provider((ref) {
  return ref.watch(streamflowServiceProviderImpl);
});

/// All inflow points loaded from local JSON.
final allInflowsProvider = FutureProvider<List<InflowPoint>>((ref) async {
  final service = ref.watch(streamflowServiceProvider);
  return service.loadInflowPoints();
});

/// Inflow points for the currently selected lake.
final inflowPointsProvider = FutureProvider<List<InflowPoint>>((ref) async {
  final selectedLakeId = ref.watch(selectedLakeProvider);
  if (selectedLakeId == null) return [];

  final service = ref.watch(streamflowServiceProvider);
  return service.getInflowsForLake(selectedLakeId);
});

/// Full inflow conditions (with live data where available) for selected lake.
/// This fetches from USGS for any inflows that have gage IDs.
final inflowConditionsProvider = FutureProvider<List<InflowConditions>>((ref) async {
  final inflows = await ref.watch(inflowPointsProvider.future);
  if (inflows.isEmpty) return [];

  final service = ref.watch(streamflowServiceProvider);
  return service.getInflowConditions(inflows);
});

/// Currently selected inflow point (for showing detail sheet).
final selectedInflowProvider = StateProvider<InflowConditions?>((ref) => null);

/// Streamflow history for the selected inflow (for graph display).
final selectedInflowHistoryProvider = FutureProvider<List<StreamflowReading>>((ref) async {
  final selectedInflow = ref.watch(selectedInflowProvider);
  if (selectedInflow == null || !selectedInflow.inflow.hasRealtimeData) {
    return [];
  }

  final service = ref.watch(streamflowServiceProvider);
  return service.getHistory(selectedInflow.inflow.usgsGageId!, days: 7);
});

/// Flow trend summary for the selected lake.
/// Returns overall trend based on all inflows with live data.
final lakeTrendSummaryProvider = Provider<FlowTrendSummary?>((ref) {
  final conditionsAsync = ref.watch(inflowConditionsProvider);
  
  return conditionsAsync.whenOrNull(data: (conditions) {
    if (conditions.isEmpty) return null;

    final liveConditions = conditions.where((c) => c.hasLiveData).toList();
    if (liveConditions.isEmpty) return null;

    // Count trends
    int rising = 0;
    int falling = 0;
    int stable = 0;
    double totalFlow = 0;

    for (final c in liveConditions) {
      totalFlow += c.currentFlowCfs;
      switch (c.trend) {
        case FlowTrend.rising:
          rising++;
          break;
        case FlowTrend.falling:
          falling++;
          break;
        case FlowTrend.stable:
          stable++;
          break;
      }
    }

    // Determine dominant trend
    FlowTrend dominantTrend;
    if (rising > falling && rising > stable) {
      dominantTrend = FlowTrend.rising;
    } else if (falling > rising && falling > stable) {
      dominantTrend = FlowTrend.falling;
    } else {
      dominantTrend = FlowTrend.stable;
    }

    return FlowTrendSummary(
      totalFlowCfs: totalFlow,
      dominantTrend: dominantTrend,
      risingCount: rising,
      fallingCount: falling,
      stableCount: stable,
      liveDataCount: liveConditions.length,
      totalInflowCount: conditions.length,
    );
  });
});

/// Summary of flow trends for a lake.
class FlowTrendSummary {
  final double totalFlowCfs;
  final FlowTrend dominantTrend;
  final int risingCount;
  final int fallingCount;
  final int stableCount;
  final int liveDataCount;
  final int totalInflowCount;

  const FlowTrendSummary({
    required this.totalFlowCfs,
    required this.dominantTrend,
    required this.risingCount,
    required this.fallingCount,
    required this.stableCount,
    required this.liveDataCount,
    required this.totalInflowCount,
  });

  String get trendLabel {
    switch (dominantTrend) {
      case FlowTrend.rising:
        return 'Rising';
      case FlowTrend.falling:
        return 'Falling';
      case FlowTrend.stable:
        return 'Stable';
    }
  }

  String get trendEmoji {
    switch (dominantTrend) {
      case FlowTrend.rising:
        return '↗️';
      case FlowTrend.falling:
        return '↘️';
      case FlowTrend.stable:
        return '→';
    }
  }

  String get flowDisplay {
    if (totalFlowCfs >= 10000) {
      return '${(totalFlowCfs / 1000).toStringAsFixed(1)}K cfs';
    }
    return '${totalFlowCfs.toStringAsFixed(0)} cfs';
  }
}

/// Fishing impact assessment for selected inflow.
final inflowFishingImpactProvider = Provider<StreamflowFishingImpact?>((ref) {
  final selectedInflow = ref.watch(selectedInflowProvider);
  if (selectedInflow == null || selectedInflow.conditions == null) {
    return null;
  }

  return StreamflowFishingImpact.fromConditions(selectedInflow.conditions!);
});

/// Filter for which inflows to show based on size.
final inflowSizeFilterProvider = StateProvider<Set<InflowSize>>((ref) {
  return {InflowSize.small, InflowSize.medium, InflowSize.large, InflowSize.major};
});

/// Filtered inflow conditions based on size filter.
final filteredInflowConditionsProvider = Provider<AsyncValue<List<InflowConditions>>>((ref) {
  final conditionsAsync = ref.watch(inflowConditionsProvider);
  final sizeFilter = ref.watch(inflowSizeFilterProvider);

  return conditionsAsync.whenData((conditions) {
    return conditions.where((c) => sizeFilter.contains(c.inflow.size)).toList();
  });
});

/// Whether to show only inflows with live USGS data.
final showOnlyLiveDataProvider = StateProvider<bool>((ref) => false);

/// Conditions filtered by live data toggle.
final displayInflowConditionsProvider = Provider<AsyncValue<List<InflowConditions>>>((ref) {
  final conditionsAsync = ref.watch(filteredInflowConditionsProvider);
  final showOnlyLive = ref.watch(showOnlyLiveDataProvider);

  if (!showOnlyLive) return conditionsAsync;

  return conditionsAsync.whenData((conditions) {
    return conditions.where((c) => c.hasLiveData).toList();
  });
});
