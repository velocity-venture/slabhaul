import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/core/models/trip_log.dart';

void main() {
  // -------------------------------------------------------------------------
  // Enums
  // -------------------------------------------------------------------------

  group('FishSpecies', () {
    test('has 13 values', () {
      expect(FishSpecies.values.length, 13);
    });

    test('displayName returns human-readable names', () {
      expect(FishSpecies.whiteCrappie.displayName, 'White Crappie');
      expect(FishSpecies.blackCrappie.displayName, 'Black Crappie');
      expect(FishSpecies.largemouthBass.displayName, 'Largemouth Bass');
      expect(FishSpecies.hybridStriper.displayName, 'Hybrid Striper');
      expect(FishSpecies.other.displayName, 'Other');
    });

    test('icon returns emoji for each species', () {
      for (final species in FishSpecies.values) {
        expect(species.icon, isNotEmpty);
      }
    });

    test('isCrappie returns true only for crappie species', () {
      expect(FishSpecies.whiteCrappie.isCrappie, isTrue);
      expect(FishSpecies.blackCrappie.isCrappie, isTrue);
      expect(FishSpecies.largemouthBass.isCrappie, isFalse);
      expect(FishSpecies.catfish.isCrappie, isFalse);
      expect(FishSpecies.other.isCrappie, isFalse);
    });
  });

  group('MoonPhase', () {
    test('has 8 values', () {
      expect(MoonPhase.values.length, 8);
    });

    test('displayName returns human-readable names', () {
      expect(MoonPhase.newMoon.displayName, 'New Moon');
      expect(MoonPhase.fullMoon.displayName, 'Full Moon');
      expect(MoonPhase.waxingGibbous.displayName, 'Waxing Gibbous');
    });

    test('icon returns moon emoji for each phase', () {
      expect(MoonPhase.newMoon.icon, '🌑');
      expect(MoonPhase.fullMoon.icon, '🌕');
      for (final phase in MoonPhase.values) {
        expect(phase.icon, isNotEmpty);
      }
    });
  });

  group('TripWaterClarity', () {
    test('has 4 values', () {
      expect(TripWaterClarity.values.length, 4);
    });

    test('displayName returns human-readable names', () {
      expect(TripWaterClarity.clear.displayName, 'Clear');
      expect(TripWaterClarity.lightStain.displayName, 'Light Stain');
      expect(TripWaterClarity.stained.displayName, 'Stained');
      expect(TripWaterClarity.muddy.displayName, 'Muddy');
    });
  });

  // -------------------------------------------------------------------------
  // WeatherSnapshot
  // -------------------------------------------------------------------------

  group('WeatherSnapshot', () {
    test('fromJson creates valid instance', () {
      final json = {
        'temp_f': 72.5,
        'wind_speed_mph': 8.0,
        'wind_direction': 'SW',
        'pressure_mb': 1013.2,
        'cloud_cover_percent': 45,
        'conditions': 'Partly Cloudy',
      };
      final ws = WeatherSnapshot.fromJson(json);
      expect(ws.tempF, 72.5);
      expect(ws.windSpeedMph, 8.0);
      expect(ws.windDirection, 'SW');
      expect(ws.pressureMb, 1013.2);
      expect(ws.cloudCoverPercent, 45);
      expect(ws.conditions, 'Partly Cloudy');
    });

    test('fromJson handles null fields', () {
      final ws = WeatherSnapshot.fromJson({});
      expect(ws.tempF, isNull);
      expect(ws.windSpeedMph, isNull);
      expect(ws.conditions, isNull);
    });

    test('toJson round-trip preserves data', () {
      const original = WeatherSnapshot(
        tempF: 68.0,
        windSpeedMph: 12.0,
        windDirection: 'NE',
        pressureMb: 1020.0,
        cloudCoverPercent: 80,
        conditions: 'Overcast',
      );
      final json = original.toJson();
      final restored = WeatherSnapshot.fromJson(json);
      expect(restored.tempF, original.tempF);
      expect(restored.windSpeedMph, original.windSpeedMph);
      expect(restored.windDirection, original.windDirection);
      expect(restored.pressureMb, original.pressureMb);
      expect(restored.cloudCoverPercent, original.cloudCoverPercent);
      expect(restored.conditions, original.conditions);
    });

    test('summary includes temp, wind, and conditions', () {
      const ws = WeatherSnapshot(
        tempF: 72.0,
        windSpeedMph: 8.0,
        windDirection: 'SW',
        conditions: 'Sunny',
      );
      final s = ws.summary;
      expect(s, contains('72'));
      expect(s, contains('SW'));
      expect(s, contains('Sunny'));
    });

    test('summary returns "No data" when all fields null', () {
      const ws = WeatherSnapshot();
      expect(ws.summary, 'No data');
    });
  });

  // -------------------------------------------------------------------------
  // TripConditions
  // -------------------------------------------------------------------------

  group('TripConditions', () {
    test('fromJson creates valid instance with nested weather', () {
      final json = {
        'weather': {
          'temp_f': 70.0,
          'wind_speed_mph': 5.0,
          'wind_direction': 'N',
        },
        'water_temp_f': 62.0,
        'water_level_ft': 359.5,
        'clarity': 'lightStain',
        'moon_phase': 'fullMoon',
        'solunar_rating': 0.85,
      };
      final tc = TripConditions.fromJson(json);
      expect(tc.weather, isNotNull);
      expect(tc.weather!.tempF, 70.0);
      expect(tc.waterTempF, 62.0);
      expect(tc.waterLevelFt, 359.5);
      expect(tc.clarity, TripWaterClarity.lightStain);
      expect(tc.moonPhase, MoonPhase.fullMoon);
      expect(tc.solunarRating, 0.85);
    });

    test('fromJson handles null fields', () {
      final tc = TripConditions.fromJson({});
      expect(tc.weather, isNull);
      expect(tc.waterTempF, isNull);
      expect(tc.clarity, isNull);
      expect(tc.moonPhase, isNull);
    });

    test('toJson round-trip preserves data', () {
      const original = TripConditions(
        weather: WeatherSnapshot(tempF: 75.0),
        waterTempF: 65.0,
        clarity: TripWaterClarity.stained,
        moonPhase: MoonPhase.newMoon,
        solunarRating: 0.5,
      );
      final json = original.toJson();
      final restored = TripConditions.fromJson(json);
      expect(restored.weather!.tempF, original.weather!.tempF);
      expect(restored.waterTempF, original.waterTempF);
      expect(restored.clarity, original.clarity);
      expect(restored.moonPhase, original.moonPhase);
      expect(restored.solunarRating, original.solunarRating);
    });

    test('fromJson falls back to default enum for invalid clarity', () {
      final tc = TripConditions.fromJson({'clarity': 'nonexistent'});
      expect(tc.clarity, TripWaterClarity.stained);
    });

    test('fromJson falls back to default enum for invalid moon phase', () {
      final tc = TripConditions.fromJson({'moon_phase': 'nonexistent'});
      expect(tc.moonPhase, MoonPhase.firstQuarter);
    });
  });

  // -------------------------------------------------------------------------
  // CatchLocation
  // -------------------------------------------------------------------------

  group('CatchLocation', () {
    test('fromJson creates valid instance', () {
      final json = {'lat': 35.123456, 'lon': -89.654321, 'description': 'Near the bridge'};
      final loc = CatchLocation.fromJson(json);
      expect(loc.lat, 35.123456);
      expect(loc.lon, -89.654321);
      expect(loc.description, 'Near the bridge');
    });

    test('toJson round-trip preserves data', () {
      const original = CatchLocation(lat: 36.0, lon: -90.0, description: 'Brush pile #3');
      final json = original.toJson();
      final restored = CatchLocation.fromJson(json);
      expect(restored.lat, original.lat);
      expect(restored.lon, original.lon);
      expect(restored.description, original.description);
    });

    test('display shows description when available', () {
      const loc = CatchLocation(lat: 36.0, lon: -90.0, description: 'The Hump');
      expect(loc.display, 'The Hump');
    });

    test('display shows coordinates when no description', () {
      const loc = CatchLocation(lat: 36.1234, lon: -90.5678);
      expect(loc.display, '36.1234, -90.5678');
    });
  });

  // -------------------------------------------------------------------------
  // BaitUsed
  // -------------------------------------------------------------------------

  group('BaitUsed', () {
    test('fromJson creates valid instance', () {
      final json = {
        'name': 'Bobby Garland Stroll-R',
        'color': 'Monkey Milk',
        'size': '2"',
        'type': 'jig',
      };
      final bait = BaitUsed.fromJson(json);
      expect(bait.name, 'Bobby Garland Stroll-R');
      expect(bait.color, 'Monkey Milk');
      expect(bait.size, '2"');
      expect(bait.type, 'jig');
    });

    test('toJson round-trip preserves data', () {
      const original = BaitUsed(name: 'Minnow', color: 'Silver', type: 'live bait');
      final json = original.toJson();
      final restored = BaitUsed.fromJson(json);
      expect(restored.name, original.name);
      expect(restored.color, original.color);
      expect(restored.type, original.type);
    });

    test('display combines name, color, and size', () {
      const bait = BaitUsed(name: 'Jig', color: 'Chartreuse', size: '1/16oz');
      expect(bait.display, 'Jig Chartreuse 1/16oz');
    });

    test('display shows only name when no color or size', () {
      const bait = BaitUsed(name: 'Minnow');
      expect(bait.display, 'Minnow');
    });
  });

  // -------------------------------------------------------------------------
  // CatchRecord
  // -------------------------------------------------------------------------

  group('CatchRecord', () {
    final sampleJson = {
      'id': 'catch-001',
      'trip_id': 'trip-001',
      'species': 'whiteCrappie',
      'length_inches': 14.5,
      'weight_lbs': 1.75,
      'depth_ft': 12.0,
      'bait': {'name': 'Jig', 'color': 'White'},
      'location': {'lat': 35.5, 'lon': -89.5, 'description': 'Brush pile'},
      'caught_at': '2026-02-05T08:30:00.000',
      'photo_path': '/photos/catch001.jpg',
      'notes': 'Big slab!',
      'released': false,
    };

    test('fromJson creates fully populated record', () {
      final record = CatchRecord.fromJson(sampleJson);
      expect(record.id, 'catch-001');
      expect(record.tripId, 'trip-001');
      expect(record.species, FishSpecies.whiteCrappie);
      expect(record.lengthInches, 14.5);
      expect(record.weightLbs, 1.75);
      expect(record.depthFt, 12.0);
      expect(record.bait, isNotNull);
      expect(record.bait!.name, 'Jig');
      expect(record.location, isNotNull);
      expect(record.location!.description, 'Brush pile');
      expect(record.caughtAt, DateTime(2026, 2, 5, 8, 30));
      expect(record.photoPath, '/photos/catch001.jpg');
      expect(record.notes, 'Big slab!');
      expect(record.released, false);
    });

    test('fromJson defaults released to true when missing', () {
      final minimal = {
        'id': 'c1',
        'trip_id': 't1',
        'species': 'blackCrappie',
        'caught_at': '2026-01-01T12:00:00.000',
      };
      final record = CatchRecord.fromJson(minimal);
      expect(record.released, true);
    });

    test('fromJson defaults to whiteCrappie for unknown species', () {
      final json = {
        'id': 'c1',
        'trip_id': 't1',
        'species': 'nonexistent_fish',
        'caught_at': '2026-01-01T12:00:00.000',
      };
      final record = CatchRecord.fromJson(json);
      expect(record.species, FishSpecies.whiteCrappie);
    });

    test('toJson round-trip preserves all fields', () {
      final original = CatchRecord.fromJson(sampleJson);
      final json = original.toJson();
      final restored = CatchRecord.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.tripId, original.tripId);
      expect(restored.species, original.species);
      expect(restored.lengthInches, original.lengthInches);
      expect(restored.weightLbs, original.weightLbs);
      expect(restored.depthFt, original.depthFt);
      expect(restored.bait!.name, original.bait!.name);
      expect(restored.location!.lat, original.location!.lat);
      expect(restored.released, original.released);
    });

    test('copyWith overrides specified fields', () {
      final original = CatchRecord.fromJson(sampleJson);
      final copy = original.copyWith(
        species: FishSpecies.blackCrappie,
        lengthInches: 16.0,
        released: true,
      );
      expect(copy.species, FishSpecies.blackCrappie);
      expect(copy.lengthInches, 16.0);
      expect(copy.released, true);
      expect(copy.id, original.id);
      expect(copy.weightLbs, original.weightLbs);
    });

    test('sizeDisplay shows length and weight', () {
      final record = CatchRecord.fromJson(sampleJson);
      expect(record.sizeDisplay, contains('14.5"'));
      expect(record.sizeDisplay, contains('1.75 lbs'));
    });

    test('sizeDisplay returns "No size" when both null', () {
      final record = CatchRecord(
        id: 'c1',
        tripId: 't1',
        species: FishSpecies.whiteCrappie,
        caughtAt: DateTime.now(),
      );
      expect(record.sizeDisplay, 'No size');
    });

    test('sizeDisplay shows only length when weight is null', () {
      final record = CatchRecord(
        id: 'c1',
        tripId: 't1',
        species: FishSpecies.whiteCrappie,
        caughtAt: DateTime.now(),
        lengthInches: 12.0,
      );
      expect(record.sizeDisplay, '12.0"');
    });
  });

  // -------------------------------------------------------------------------
  // TripStats
  // -------------------------------------------------------------------------

  group('TripStats', () {
    test('fromCatches with empty list', () {
      final stats = TripStats.fromCatches([]);
      expect(stats.totalCatches, 0);
      expect(stats.crappieCount, 0);
      expect(stats.biggestLengthInches, isNull);
      expect(stats.biggestWeightLbs, isNull);
      expect(stats.averageLengthInches, isNull);
    });

    test('fromCatches computes correct totals', () {
      final catches = [
        CatchRecord(
          id: '1', tripId: 't1', species: FishSpecies.whiteCrappie,
          caughtAt: DateTime(2026, 2, 5, 8, 0),
          lengthInches: 12.0, weightLbs: 1.0,
          bait: const BaitUsed(name: 'Jig', color: 'White'),
        ),
        CatchRecord(
          id: '2', tripId: 't1', species: FishSpecies.blackCrappie,
          caughtAt: DateTime(2026, 2, 5, 9, 0),
          lengthInches: 14.0, weightLbs: 1.5,
          bait: const BaitUsed(name: 'Minnow'),
        ),
        CatchRecord(
          id: '3', tripId: 't1', species: FishSpecies.largemouthBass,
          caughtAt: DateTime(2026, 2, 5, 10, 0),
          lengthInches: 18.0, weightLbs: 3.0,
          bait: const BaitUsed(name: 'Jig', color: 'White'),
        ),
      ];

      final stats = TripStats.fromCatches(catches);
      expect(stats.totalCatches, 3);
      expect(stats.crappieCount, 2);
      expect(stats.biggestLengthInches, 18.0);
      expect(stats.biggestWeightLbs, 3.0);
      expect(stats.averageLengthInches, closeTo(14.67, 0.01));
      expect(stats.catchesBySpecies['White Crappie'], 1);
      expect(stats.catchesBySpecies['Black Crappie'], 1);
      expect(stats.catchesBySpecies['Largemouth Bass'], 1);
      expect(stats.catchesByBait['Jig White'], 2);
      expect(stats.catchesByBait['Minnow'], 1);
      expect(stats.catchesByHour[8], 1);
      expect(stats.catchesByHour[9], 1);
      expect(stats.catchesByHour[10], 1);
    });

    test('toJson round-trip preserves data', () {
      final original = TripStats(
        totalCatches: 5,
        crappieCount: 3,
        biggestLengthInches: 15.5,
        biggestWeightLbs: 2.0,
        averageLengthInches: 12.0,
        catchesBySpecies: {'White Crappie': 3, 'Bass': 2},
        catchesByBait: {'Jig': 4, 'Minnow': 1},
        catchesByHour: {8: 2, 9: 3},
      );
      final json = original.toJson();
      final restored = TripStats.fromJson(json);
      expect(restored.totalCatches, original.totalCatches);
      expect(restored.crappieCount, original.crappieCount);
      expect(restored.biggestLengthInches, original.biggestLengthInches);
      expect(restored.catchesBySpecies, original.catchesBySpecies);
      expect(restored.catchesByHour, original.catchesByHour);
    });
  });

  // -------------------------------------------------------------------------
  // FishingTrip
  // -------------------------------------------------------------------------

  group('FishingTrip', () {
    final sampleTripJson = {
      'id': 'trip-001',
      'lake_id': 'reelfoot',
      'lake_name': 'Reelfoot Lake',
      'started_at': '2026-02-05T06:00:00.000',
      'ended_at': '2026-02-05T14:00:00.000',
      'conditions': {
        'water_temp_f': 55.0,
        'clarity': 'lightStain',
      },
      'catches': [
        {
          'id': 'c1',
          'trip_id': 'trip-001',
          'species': 'whiteCrappie',
          'length_inches': 12.0,
          'caught_at': '2026-02-05T08:00:00.000',
        },
        {
          'id': 'c2',
          'trip_id': 'trip-001',
          'species': 'blackCrappie',
          'length_inches': 14.0,
          'caught_at': '2026-02-05T09:30:00.000',
        },
      ],
      'notes': 'Great morning bite',
      'is_active': false,
    };

    test('fromJson creates fully populated trip', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.id, 'trip-001');
      expect(trip.lakeId, 'reelfoot');
      expect(trip.lakeName, 'Reelfoot Lake');
      expect(trip.startedAt, DateTime(2026, 2, 5, 6, 0));
      expect(trip.endedAt, DateTime(2026, 2, 5, 14, 0));
      expect(trip.conditions, isNotNull);
      expect(trip.conditions!.waterTempF, 55.0);
      expect(trip.catches.length, 2);
      expect(trip.notes, 'Great morning bite');
      expect(trip.isActive, false);
    });

    test('fromJson handles minimal trip', () {
      final minimal = {
        'id': 't1',
        'started_at': '2026-01-01T12:00:00.000',
      };
      final trip = FishingTrip.fromJson(minimal);
      expect(trip.id, 't1');
      expect(trip.lakeId, isNull);
      expect(trip.lakeName, isNull);
      expect(trip.endedAt, isNull);
      expect(trip.conditions, isNull);
      expect(trip.catches, isEmpty);
      expect(trip.isActive, false);
    });

    test('toJson round-trip preserves all fields', () {
      final original = FishingTrip.fromJson(sampleTripJson);
      final json = original.toJson();
      final restored = FishingTrip.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.lakeId, original.lakeId);
      expect(restored.lakeName, original.lakeName);
      expect(restored.startedAt, original.startedAt);
      expect(restored.endedAt, original.endedAt);
      expect(restored.catches.length, original.catches.length);
      expect(restored.notes, original.notes);
      expect(restored.isActive, original.isActive);
    });

    test('copyWith overrides specified fields', () {
      final original = FishingTrip.fromJson(sampleTripJson);
      final copy = original.copyWith(
        lakeName: 'Kentucky Lake',
        isActive: true,
      );
      expect(copy.lakeName, 'Kentucky Lake');
      expect(copy.isActive, true);
      expect(copy.id, original.id);
      expect(copy.catches.length, original.catches.length);
    });

    test('duration calculates correctly for completed trip', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.duration, const Duration(hours: 8));
    });

    test('durationDisplay formats hours and minutes', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.durationDisplay, '8h 0m');
    });

    test('durationDisplay shows only minutes for short trips', () {
      final trip = FishingTrip(
        id: 't1',
        startedAt: DateTime(2026, 1, 1, 12, 0),
        endedAt: DateTime(2026, 1, 1, 12, 45),
      );
      expect(trip.durationDisplay, '45m');
    });

    test('stats computes from catches', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.stats.totalCatches, 2);
      expect(trip.stats.crappieCount, 2);
      expect(trip.stats.biggestLengthInches, 14.0);
    });

    test('title returns lake name when available', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.title, 'Reelfoot Lake');
    });

    test('title falls back to date format when no lake name', () {
      final trip = FishingTrip(
        id: 't1',
        startedAt: DateTime(2026, 3, 15),
      );
      expect(trip.title, 'Trip 3/15/2026');
    });

    test('summary includes fish count and duration', () {
      final trip = FishingTrip.fromJson(sampleTripJson);
      expect(trip.summary, contains('2 fish'));
      expect(trip.summary, contains('8h'));
    });
  });

  // -------------------------------------------------------------------------
  // AggregateStats
  // -------------------------------------------------------------------------

  group('AggregateStats', () {
    test('fromTrips with empty list', () {
      final stats = AggregateStats.fromTrips([]);
      expect(stats.totalTrips, 0);
      expect(stats.totalCatches, 0);
      expect(stats.totalCrappie, 0);
      expect(stats.totalTime, Duration.zero);
      expect(stats.personalBestLengthInches, isNull);
      expect(stats.personalBestWeightLbs, isNull);
      expect(stats.averageCatchesPerTrip, isNull);
    });

    test('fromTrips computes correct aggregates', () {
      final trips = [
        FishingTrip(
          id: 't1',
          lakeName: 'Reelfoot',
          startedAt: DateTime(2026, 1, 1, 6),
          endedAt: DateTime(2026, 1, 1, 14),
          catches: [
            CatchRecord(
              id: 'c1', tripId: 't1', species: FishSpecies.whiteCrappie,
              caughtAt: DateTime(2026, 1, 1, 8),
              lengthInches: 14.0, weightLbs: 1.5,
              bait: const BaitUsed(name: 'Jig'),
            ),
            CatchRecord(
              id: 'c2', tripId: 't1', species: FishSpecies.largemouthBass,
              caughtAt: DateTime(2026, 1, 1, 9),
              lengthInches: 18.0, weightLbs: 3.5,
              bait: const BaitUsed(name: 'Minnow'),
            ),
          ],
        ),
        FishingTrip(
          id: 't2',
          lakeName: 'Reelfoot',
          startedAt: DateTime(2026, 1, 2, 6),
          endedAt: DateTime(2026, 1, 2, 12),
          catches: [
            CatchRecord(
              id: 'c3', tripId: 't2', species: FishSpecies.blackCrappie,
              caughtAt: DateTime(2026, 1, 2, 7),
              lengthInches: 15.5, weightLbs: 2.0,
              bait: const BaitUsed(name: 'Jig'),
            ),
          ],
        ),
      ];

      final stats = AggregateStats.fromTrips(trips);
      expect(stats.totalTrips, 2);
      expect(stats.totalCatches, 3);
      expect(stats.totalCrappie, 2);
      expect(stats.totalTime, const Duration(hours: 14));
      expect(stats.personalBestLengthInches, 18.0);
      expect(stats.personalBestWeightLbs, 3.5);
      expect(stats.averageCatchesPerTrip, 1.5);
      expect(stats.mostSuccessfulBait, 'Jig');
      expect(stats.mostSuccessfulLake, 'Reelfoot');
    });

    test('totalTimeDisplay formats days and hours', () {
      const stats = AggregateStats(
        totalTrips: 5,
        totalCatches: 20,
        totalCrappie: 15,
        totalTime: Duration(hours: 50),
      );
      expect(stats.totalTimeDisplay, '2d 2h');
    });

    test('totalTimeDisplay formats hours only when under 24', () {
      const stats = AggregateStats(
        totalTrips: 1,
        totalCatches: 5,
        totalCrappie: 3,
        totalTime: Duration(hours: 8),
      );
      expect(stats.totalTimeDisplay, '8h');
    });
  });
}
