import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/services/bait_recommendation_service.dart';
import '../../../core/models/weather_data.dart';

/// Provider for the bait recommendation service singleton
final baitRecommendationServiceProvider = Provider<BaitRecommendationService>(
  (ref) => BaitRecommendationService(),
);

/// State for user-inputted fishing conditions
class FishingConditionsState {
  final double? waterTempF;
  final WaterClarity clarity;
  final double targetDepthFt;
  final StructureType? structureType;
  final WeatherData? weather;
  final double? solunarRating;
  
  const FishingConditionsState({
    this.waterTempF,
    this.clarity = WaterClarity.stained,
    this.targetDepthFt = 10.0,
    this.structureType,
    this.weather,
    this.solunarRating,
  });
  
  FishingConditionsState copyWith({
    double? waterTempF,
    WaterClarity? clarity,
    double? targetDepthFt,
    StructureType? structureType,
    bool clearStructure = false,
    WeatherData? weather,
    double? solunarRating,
  }) {
    return FishingConditionsState(
      waterTempF: waterTempF ?? this.waterTempF,
      clarity: clarity ?? this.clarity,
      targetDepthFt: targetDepthFt ?? this.targetDepthFt,
      structureType: clearStructure ? null : (structureType ?? this.structureType),
      weather: weather ?? this.weather,
      solunarRating: solunarRating ?? this.solunarRating,
    );
  }
  
  /// Check if we have enough data to generate recommendations
  bool get canGenerateRecommendations => waterTempF != null;
}

/// Notifier for managing fishing conditions state
class FishingConditionsNotifier extends StateNotifier<FishingConditionsState> {
  FishingConditionsNotifier() : super(const FishingConditionsState());
  
  void setWaterTemp(double tempF) {
    state = state.copyWith(waterTempF: tempF);
  }
  
  void setClarity(WaterClarity clarity) {
    state = state.copyWith(clarity: clarity);
  }
  
  void setTargetDepth(double depthFt) {
    state = state.copyWith(targetDepthFt: depthFt);
  }
  
  void setStructureType(StructureType? type) {
    if (type == null) {
      state = state.copyWith(clearStructure: true);
    } else {
      state = state.copyWith(structureType: type);
    }
  }
  
  void setWeather(WeatherData weather) {
    // Also update water temp estimate from air temp if not set
    double? waterTemp = state.waterTempF;
    if (waterTemp == null) {
      // Rough estimate: water temp lags air by 5-10°F in warm months
      waterTemp = weather.current.temperatureF - 5;
    }
    state = state.copyWith(
      weather: weather,
      waterTempF: waterTemp,
    );
  }
  
  void setSolunarRating(double rating) {
    state = state.copyWith(solunarRating: rating);
  }
  
  void reset() {
    state = const FishingConditionsState();
  }
}

/// StateNotifierProvider for fishing conditions
final fishingConditionsProvider = 
    StateNotifierProvider<FishingConditionsNotifier, FishingConditionsState>(
  (ref) => FishingConditionsNotifier(),
);

/// Provider that generates recommendations based on current conditions
final baitRecommendationsProvider = Provider<BaitRecommendationResult?>((ref) {
  final service = ref.watch(baitRecommendationServiceProvider);
  final conditions = ref.watch(fishingConditionsProvider);
  
  if (!conditions.canGenerateRecommendations) {
    return null;
  }
  
  // Use weather data if available, otherwise basic conditions
  if (conditions.weather != null) {
    return service.getRecommendationsFromWeather(
      weather: conditions.weather!,
      waterTempF: conditions.waterTempF!,
      clarity: conditions.clarity,
      targetDepthFt: conditions.targetDepthFt,
      structureType: conditions.structureType,
      solunarRating: conditions.solunarRating,
    );
  }
  
  return service.getRecommendations(
    waterTempF: conditions.waterTempF!,
    clarity: conditions.clarity,
    targetDepthFt: conditions.targetDepthFt,
    structureType: conditions.structureType,
    solunarRating: conditions.solunarRating,
  );
});

/// Provider for the top 3 bait recommendations
final topBaitRecommendationsProvider = Provider<List<BaitRecommendation>>((ref) {
  final result = ref.watch(baitRecommendationsProvider);
  return result?.getTopN(3) ?? [];
});

/// Provider for the single top recommendation
final topBaitPickProvider = Provider<BaitRecommendation?>((ref) {
  final result = ref.watch(baitRecommendationsProvider);
  return result?.topPick;
});

/// Provider for current fishing season based on water temp
final currentSeasonProvider = Provider<CrappieSeason?>((ref) {
  final conditions = ref.watch(fishingConditionsProvider);
  final waterTemp = conditions.waterTempF;
  
  if (waterTemp == null) return null;
  
  if (waterTemp < 50) return CrappieSeason.winter;
  if (waterTemp < 60) return CrappieSeason.preSpawn;
  if (waterTemp < 68) return CrappieSeason.spawn;
  if (waterTemp < 75) return CrappieSeason.postSpawn;
  
  // Check calendar for summer vs fall
  final month = DateTime.now().month;
  if (month >= 9 && month <= 11) {
    return CrappieSeason.fall;
  }
  
  return CrappieSeason.summer;
});

/// Provider for recommended jig head weight
final recommendedJigWeightProvider = Provider<JigHeadWeight?>((ref) {
  final service = ref.watch(baitRecommendationServiceProvider);
  final conditions = ref.watch(fishingConditionsProvider);
  
  return service.getJigHeadWeight(
    depthFt: conditions.targetDepthFt,
    windSpeedMph: conditions.weather?.current.windSpeedMph,
  );
});
