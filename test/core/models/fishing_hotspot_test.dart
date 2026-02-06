import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/core/models/fishing_hotspot.dart';

void main() {
  // -------------------------------------------------------------------------
  // HotspotConditions
  // -------------------------------------------------------------------------

  group('HotspotConditions', () {
    test('fromJson creates valid instance', () {
      final json = {
        'min_water_temp_f': 55.0,
        'max_water_temp_f': 70.0,
        'water_level_trend': 'stable',
        'pressure_trend': 'rising',
        'time_of_day': 'early_morning',
        'min_cloud_cover': 20,
        'max_cloud_cover': 80,
        'max_wind_mph': 15.0,
        'preferred_wind_direction': 'SW',
      };
      final cond = HotspotConditions.fromJson(json);
      expect(cond.minWaterTempF, 55.0);
      expect(cond.maxWaterTempF, 70.0);
      expect(cond.waterLevelTrend, 'stable');
      expect(cond.pressureTrend, 'rising');
      expect(cond.timeOfDay, 'early_morning');
      expect(cond.minCloudCover, 20);
      expect(cond.maxCloudCover, 80);
      expect(cond.maxWindMph, 15.0);
      expect(cond.preferredWindDirection, 'SW');
    });

    test('fromJson handles all null fields', () {
      final cond = HotspotConditions.fromJson({});
      expect(cond.minWaterTempF, isNull);
      expect(cond.maxWaterTempF, isNull);
      expect(cond.waterLevelTrend, isNull);
    });

    test('toJson round-trip preserves data', () {
      const original = HotspotConditions(
        minWaterTempF: 50.0,
        maxWaterTempF: 65.0,
        pressureTrend: 'falling',
        maxWindMph: 10.0,
      );
      final json = original.toJson();
      final restored = HotspotConditions.fromJson(json);
      expect(restored.minWaterTempF, original.minWaterTempF);
      expect(restored.maxWaterTempF, original.maxWaterTempF);
      expect(restored.pressureTrend, original.pressureTrend);
      expect(restored.maxWindMph, original.maxWindMph);
    });
  });

  // -------------------------------------------------------------------------
  // FishingHotspot
  // -------------------------------------------------------------------------

  group('FishingHotspot', () {
    final sampleJson = {
      'id': 'hs-001',
      'name': 'Bridge Pilings South',
      'latitude': 36.35,
      'longitude': -89.41,
      'lake_id': 'reelfoot',
      'lake_name': 'Reelfoot Lake',
      'structure_type': 'bridge_piling',
      'description': 'Main bridge support columns on south end',
      'min_depth_ft': 8.0,
      'max_depth_ft': 15.0,
      'best_seasons': ['spawn', 'fall'],
      'techniques': ['vertical_jigging', 'slip_float'],
      'ideal_conditions': {
        'min_water_temp_f': 55.0,
        'max_water_temp_f': 70.0,
        'pressure_trend': 'stable',
      },
      'notes': 'Best on cloudy days',
      'confidence_score': 85,
    };

    test('fromJson creates fully populated hotspot', () {
      final hs = FishingHotspot.fromJson(sampleJson);
      expect(hs.id, 'hs-001');
      expect(hs.name, 'Bridge Pilings South');
      expect(hs.latitude, 36.35);
      expect(hs.longitude, -89.41);
      expect(hs.lakeId, 'reelfoot');
      expect(hs.lakeName, 'Reelfoot Lake');
      expect(hs.structureType, 'bridge_piling');
      expect(hs.description, 'Main bridge support columns on south end');
      expect(hs.minDepthFt, 8.0);
      expect(hs.maxDepthFt, 15.0);
      expect(hs.bestSeasons, ['spawn', 'fall']);
      expect(hs.techniques, ['vertical_jigging', 'slip_float']);
      expect(hs.idealConditions.minWaterTempF, 55.0);
      expect(hs.notes, 'Best on cloudy days');
      expect(hs.confidenceScore, 85);
    });

    test('toJson round-trip preserves all fields', () {
      final original = FishingHotspot.fromJson(sampleJson);
      final json = original.toJson();
      final restored = FishingHotspot.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.structureType, original.structureType);
      expect(restored.bestSeasons, original.bestSeasons);
      expect(restored.techniques, original.techniques);
      expect(restored.confidenceScore, original.confidenceScore);
    });

    test('structureLabel maps known types', () {
      final types = {
        'brush_pile': 'Brush Pile Complex',
        'bridge_piling': 'Bridge Pilings',
        'dock': 'Dock/Marina',
        'creek_channel': 'Creek Channel',
        'point': 'Main Lake Point',
        'timber': 'Standing Timber',
        'flat': 'Spawning Flat',
        'ledge': 'Channel Ledge',
        'hump': 'Submerged Hump',
        'riprap': 'Riprap Bank',
      };
      for (final entry in types.entries) {
        final hs = FishingHotspot(
          id: 'test', name: 'Test', latitude: 0, longitude: 0,
          lakeId: 'l', lakeName: 'L', structureType: entry.key,
          description: '', minDepthFt: 5, maxDepthFt: 15,
          bestSeasons: const [], techniques: const [],
          idealConditions: const HotspotConditions(),
        );
        expect(hs.structureLabel, entry.value);
      }
    });

    test('structureLabel returns raw type for unknown types', () {
      final hs = FishingHotspot(
        id: 'test', name: 'Test', latitude: 0, longitude: 0,
        lakeId: 'l', lakeName: 'L', structureType: 'custom_type',
        description: '', minDepthFt: 5, maxDepthFt: 15,
        bestSeasons: const [], techniques: const [],
        idealConditions: const HotspotConditions(),
      );
      expect(hs.structureLabel, 'custom_type');
    });

    test('depthRangeString formats correctly', () {
      final hs = FishingHotspot.fromJson(sampleJson);
      expect(hs.depthRangeString, '8-15 ft');
    });

    test('coordinateString formats to 6 decimal places', () {
      final hs = FishingHotspot.fromJson(sampleJson);
      expect(hs.coordinateString, '36.350000, -89.410000');
    });

    test('seasonString maps known seasons', () {
      final hs = FishingHotspot.fromJson(sampleJson);
      expect(hs.seasonString, 'Spawn, Fall');
    });

    test('techniqueString maps known techniques', () {
      final hs = FishingHotspot.fromJson(sampleJson);
      expect(hs.techniqueString, 'Vertical Jigging, Slip Float');
    });

    test('techniqueLabel maps all known techniques', () {
      expect(FishingHotspot.techniqueLabel('spider_rigging'), 'Spider Rigging');
      expect(FishingHotspot.techniqueLabel('vertical_jigging'), 'Vertical Jigging');
      expect(FishingHotspot.techniqueLabel('casting'), 'Casting');
      expect(FishingHotspot.techniqueLabel('slip_float'), 'Slip Float');
      expect(FishingHotspot.techniqueLabel('tight_lining'), 'Tight-Lining');
      expect(FishingHotspot.techniqueLabel('shooting_docks'), 'Shooting Docks');
      expect(FishingHotspot.techniqueLabel('trolling'), 'Trolling');
      expect(FishingHotspot.techniqueLabel('long_lining'), 'Long-Lining');
      expect(FishingHotspot.techniqueLabel('unknown'), 'unknown');
    });
  });

  // -------------------------------------------------------------------------
  // HotspotRating
  // -------------------------------------------------------------------------

  group('HotspotRating', () {
    HotspotRating makeRating(double score) {
      return HotspotRating(
        hotspot: FishingHotspot(
          id: 'test', name: 'Test', latitude: 0, longitude: 0,
          lakeId: 'l', lakeName: 'L', structureType: 'brush_pile',
          description: '', minDepthFt: 5, maxDepthFt: 15,
          bestSeasons: const [], techniques: const [],
          idealConditions: const HotspotConditions(),
        ),
        overallScore: score,
        seasonScore: score,
        temperatureScore: score,
        waterLevelScore: score,
        timeOfDayScore: score,
        weatherScore: score,
        ratingLabel: 'Test',
        whyGoodNow: const [],
        concerns: const [],
        suggestedTechniques: const [],
      );
    }

    test('matchPercentage converts score to 0-100', () {
      expect(makeRating(0.85).matchPercentage, 85);
      expect(makeRating(0.0).matchPercentage, 0);
      expect(makeRating(1.0).matchPercentage, 100);
    });

    test('isExcellent returns true for score >= 0.8', () {
      expect(makeRating(0.85).isExcellent, isTrue);
      expect(makeRating(0.80).isExcellent, isTrue);
      expect(makeRating(0.79).isExcellent, isFalse);
    });

    test('isGood returns true for 0.6 <= score < 0.8', () {
      expect(makeRating(0.70).isGood, isTrue);
      expect(makeRating(0.60).isGood, isTrue);
      expect(makeRating(0.80).isGood, isFalse);
      expect(makeRating(0.59).isGood, isFalse);
    });

    test('isFair returns true for 0.4 <= score < 0.6', () {
      expect(makeRating(0.50).isFair, isTrue);
      expect(makeRating(0.40).isFair, isTrue);
      expect(makeRating(0.60).isFair, isFalse);
      expect(makeRating(0.39).isFair, isFalse);
    });

    test('isPoor returns true for score < 0.4', () {
      expect(makeRating(0.30).isPoor, isTrue);
      expect(makeRating(0.0).isPoor, isTrue);
      expect(makeRating(0.40).isPoor, isFalse);
    });
  });

  // -------------------------------------------------------------------------
  // CurrentConditions
  // -------------------------------------------------------------------------

  group('CurrentConditions', () {
    test('timeOfDay maps hour ranges correctly', () {
      expect(
        const CurrentConditions(season: 'summer', hourOfDay: 6).timeOfDay,
        'early_morning',
      );
      expect(
        const CurrentConditions(season: 'summer', hourOfDay: 12).timeOfDay,
        'midday',
      );
      expect(
        const CurrentConditions(season: 'summer', hourOfDay: 18).timeOfDay,
        'evening',
      );
      expect(
        const CurrentConditions(season: 'summer', hourOfDay: 22).timeOfDay,
        'night',
      );
      expect(
        const CurrentConditions(season: 'summer', hourOfDay: 3).timeOfDay,
        'night',
      );
    });

    test('windDirection maps degrees to cardinal directions', () {
      const base = CurrentConditions(season: 'summer', hourOfDay: 12);

      // N
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 0).windDirection,
        'N',
      );
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 350).windDirection,
        'N',
      );
      // NE
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 45).windDirection,
        'NE',
      );
      // E
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 90).windDirection,
        'E',
      );
      // SE
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 135).windDirection,
        'SE',
      );
      // S
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 180).windDirection,
        'S',
      );
      // SW
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 225).windDirection,
        'SW',
      );
      // W
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 270).windDirection,
        'W',
      );
      // NW
      expect(
        CurrentConditions(season: 'summer', hourOfDay: 12, windDirectionDeg: 315).windDirection,
        'NW',
      );
    });

    test('windDirection returns null when no direction set', () {
      const cc = CurrentConditions(season: 'winter', hourOfDay: 10);
      expect(cc.windDirection, isNull);
    });

    test('estimateWaterTemp warms cold air temps', () {
      final wt = CurrentConditions.estimateWaterTemp(30.0);
      expect(wt, 35.0); // +5
    });

    test('estimateWaterTemp cools hot air temps', () {
      final wt = CurrentConditions.estimateWaterTemp(90.0);
      expect(wt, 80.0); // -10
    });

    test('estimateWaterTemp moderates mid-range temps', () {
      final wt = CurrentConditions.estimateWaterTemp(70.0);
      expect(wt, 67.0); // -3
    });
  });
}
