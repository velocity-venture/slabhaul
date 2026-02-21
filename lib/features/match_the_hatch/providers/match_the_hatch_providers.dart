import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/models/hatch_recommendation.dart';
import '../../../core/services/match_the_hatch_engine.dart';
import '../../../core/data/region_classifier.dart';
import '../../weather/providers/weather_providers.dart';
import '../../weather/providers/solunar_providers.dart';
import '../../weather/providers/thermocline_providers.dart';
import '../../bait_recommendations/providers/bait_recommendation_providers.dart';

// ---------------------------------------------------------------------------
// Service registration
// ---------------------------------------------------------------------------

final matchTheHatchEngineProvider = Provider<MatchTheHatchEngine>((ref) {
  return MatchTheHatchEngine();
});

// ---------------------------------------------------------------------------
// Region from lake GPS
// ---------------------------------------------------------------------------

final fishingRegionProvider = Provider<FishingRegion>((ref) {
  final coords = ref.watch(selectedWeatherLakeProvider);
  return RegionClassifier.classify(coords.lat, coords.lon);
});

// ---------------------------------------------------------------------------
// Auto-detected conditions (reads existing providers)
// ---------------------------------------------------------------------------

final autoHatchConditionsProvider = Provider<_AutoConditions?>((ref) {
  final weatherAsync = ref.watch(weatherDataProvider);
  final barometricTrend = ref.watch(barometricTrendProvider);
  final solunar = ref.watch(solunarForecastProvider);
  final region = ref.watch(fishingRegionProvider);
  final seasonFromExisting = ref.watch(currentSeasonProvider);

  return weatherAsync.whenOrNull(
    data: (weather) {
      // Thermocline — may still be loading; that's fine
      double? targetDepth;
      final thermoAsync = ref.watch(thermoclineDataProvider);
      thermoAsync.whenData((thermo) {
        targetDepth = thermo.sweetSpotFt;
      });

      return _AutoConditions(
        airTempF: weather.current.temperatureF,
        pressureMb: weather.current.pressureMb,
        pressureTrend: barometricTrend,
        windSpeedMph: weather.current.windSpeedMph,
        windDirectionDeg: weather.current.windDirectionDeg,
        solunarRating: solunar.overallRating,
        targetDepthFt: targetDepth,
        region: region,
        season: seasonFromExisting,
      );
    },
  );
});

class _AutoConditions {
  final double airTempF;
  final double pressureMb;
  final String pressureTrend;
  final double windSpeedMph;
  final int? windDirectionDeg;
  final double solunarRating;
  final double? targetDepthFt;
  final FishingRegion region;
  final CrappieSeason? season;

  const _AutoConditions({
    required this.airTempF,
    required this.pressureMb,
    required this.pressureTrend,
    required this.windSpeedMph,
    this.windDirectionDeg,
    required this.solunarRating,
    this.targetDepthFt,
    required this.region,
    this.season,
  });
}

// ---------------------------------------------------------------------------
// User input state
// ---------------------------------------------------------------------------

class HatchUserInput {
  final WaterClarity? clarity;
  final double? waterTempF;
  final FishingPressure? fishingPressure;

  const HatchUserInput({this.clarity, this.waterTempF, this.fishingPressure});

  bool get isComplete => clarity != null && waterTempF != null;

  HatchUserInput copyWith({
    WaterClarity? clarity,
    double? waterTempF,
    FishingPressure? fishingPressure,
    bool clearPressure = false,
  }) {
    return HatchUserInput(
      clarity: clarity ?? this.clarity,
      waterTempF: waterTempF ?? this.waterTempF,
      fishingPressure: clearPressure ? null : (fishingPressure ?? this.fishingPressure),
    );
  }
}

class HatchUserInputNotifier extends StateNotifier<HatchUserInput> {
  HatchUserInputNotifier() : super(const HatchUserInput());

  void setClarity(WaterClarity clarity) {
    state = state.copyWith(clarity: clarity);
  }

  void setWaterTemp(double tempF) {
    state = state.copyWith(waterTempF: tempF);
  }

  void setFishingPressure(FishingPressure? pressure) {
    if (pressure == null) {
      state = state.copyWith(clearPressure: true);
    } else {
      state = state.copyWith(fishingPressure: pressure);
    }
  }

  void reset() {
    state = const HatchUserInput();
  }
}

final hatchUserInputProvider =
    StateNotifierProvider<HatchUserInputNotifier, HatchUserInput>((ref) {
  return HatchUserInputNotifier();
});

// ---------------------------------------------------------------------------
// Main recommendation (combines auto + user → engine)
// ---------------------------------------------------------------------------

final hatchRecommendationProvider = Provider<HatchRecommendation?>((ref) {
  final engine = ref.watch(matchTheHatchEngineProvider);
  final userInput = ref.watch(hatchUserInputProvider);
  final auto = ref.watch(autoHatchConditionsProvider);

  if (!userInput.isComplete) return null;

  final clarity = userInput.clarity!;
  final waterTempF = userInput.waterTempF!;

  // Determine season from water temp (same logic as existing)
  CrappieSeason season;
  if (auto?.season != null) {
    season = auto!.season!;
  } else {
    if (waterTempF < 50) {
      season = CrappieSeason.winter;
    } else if (waterTempF < 60) {
      season = CrappieSeason.preSpawn;
    } else if (waterTempF < 68) {
      season = CrappieSeason.spawn;
    } else if (waterTempF < 75) {
      season = CrappieSeason.postSpawn;
    } else {
      final month = DateTime.now().month;
      season = (month >= 9 && month <= 11)
          ? CrappieSeason.fall
          : CrappieSeason.summer;
    }
  }

  // Determine time of day
  final hour = DateTime.now().hour;
  TimeOfDay timeOfDay;
  if (hour >= 5 && hour < 8) {
    timeOfDay = TimeOfDay.dawn;
  } else if (hour >= 8 && hour < 10) {
    timeOfDay = TimeOfDay.morning;
  } else if (hour >= 10 && hour < 15) {
    timeOfDay = TimeOfDay.midday;
  } else if (hour >= 15 && hour < 18) {
    timeOfDay = TimeOfDay.afternoon;
  } else if (hour >= 18 && hour < 21) {
    timeOfDay = TimeOfDay.dusk;
  } else {
    timeOfDay = TimeOfDay.night;
  }

  final FishingRegion region = auto?.region ?? ref.watch(fishingRegionProvider);

  return engine.recommend(
    waterTempF: waterTempF,
    clarity: clarity,
    season: season,
    timeOfDay: timeOfDay,
    region: region,
    airTempF: auto?.airTempF,
    pressureMb: auto?.pressureMb,
    pressureTrend: auto?.pressureTrend,
    windSpeedMph: auto?.windSpeedMph,
    windDirectionDeg: auto?.windDirectionDeg,
    solunarRating: auto?.solunarRating,
    targetDepthFt: auto?.targetDepthFt,
    fishingPressure: userInput.fishingPressure,
  );
});
