// Trip Log / Catch Tracking Models
//
// Track fishing trips, catches, and patterns over time.
// Crappie-focused but supports other species.

import 'dart:math' show pow;

import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Fish species for catch logging
enum FishSpecies {
  whiteCrappie,
  blackCrappie,
  largemouthBass,
  smallmouthBass,
  spottedBass,
  bluegill,
  redearSunfish,
  catfish,
  sauger,
  walleye,
  stripedBass,
  hybridStriper,
  other,
}

extension FishSpeciesX on FishSpecies {
  String get displayName {
    switch (this) {
      case FishSpecies.whiteCrappie:
        return 'White Crappie';
      case FishSpecies.blackCrappie:
        return 'Black Crappie';
      case FishSpecies.largemouthBass:
        return 'Largemouth Bass';
      case FishSpecies.smallmouthBass:
        return 'Smallmouth Bass';
      case FishSpecies.spottedBass:
        return 'Spotted Bass';
      case FishSpecies.bluegill:
        return 'Bluegill';
      case FishSpecies.redearSunfish:
        return 'Redear Sunfish';
      case FishSpecies.catfish:
        return 'Catfish';
      case FishSpecies.sauger:
        return 'Sauger';
      case FishSpecies.walleye:
        return 'Walleye';
      case FishSpecies.stripedBass:
        return 'Striped Bass';
      case FishSpecies.hybridStriper:
        return 'Hybrid Striper';
      case FishSpecies.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case FishSpecies.whiteCrappie:
      case FishSpecies.blackCrappie:
        return '🐟';
      case FishSpecies.largemouthBass:
      case FishSpecies.smallmouthBass:
      case FishSpecies.spottedBass:
        return '🐠';
      case FishSpecies.bluegill:
      case FishSpecies.redearSunfish:
        return '🐡';
      case FishSpecies.catfish:
        return '🐈';
      case FishSpecies.sauger:
      case FishSpecies.walleye:
        return '🐟';
      case FishSpecies.stripedBass:
      case FishSpecies.hybridStriper:
        return '🐟';
      case FishSpecies.other:
        return '🎣';
    }
  }

  bool get isCrappie =>
      this == FishSpecies.whiteCrappie || this == FishSpecies.blackCrappie;

  /// Estimates weight in pounds from length in inches using species-specific
  /// length-weight regression formulas. Returns null for unsupported species.
  double? estimateWeightLbs(double lengthInches) {
    if (lengthInches <= 0) return null;
    switch (this) {
      case FishSpecies.whiteCrappie:
        // W(oz) = length^3.198 * 0.000213
        return (pow(lengthInches, 3.198) * 0.000213) / 16.0;
      case FishSpecies.blackCrappie:
        // W(oz) = length^3.332 * 0.000143
        return (pow(lengthInches, 3.332) * 0.000143) / 16.0;
      default:
        return null;
    }
  }
}

/// Moon phases for pattern tracking
enum MoonPhase {
  newMoon,
  waxingCrescent,
  firstQuarter,
  waxingGibbous,
  fullMoon,
  waningGibbous,
  lastQuarter,
  waningCrescent,
}

extension MoonPhaseX on MoonPhase {
  String get displayName {
    switch (this) {
      case MoonPhase.newMoon:
        return 'New Moon';
      case MoonPhase.waxingCrescent:
        return 'Waxing Crescent';
      case MoonPhase.firstQuarter:
        return 'First Quarter';
      case MoonPhase.waxingGibbous:
        return 'Waxing Gibbous';
      case MoonPhase.fullMoon:
        return 'Full Moon';
      case MoonPhase.waningGibbous:
        return 'Waning Gibbous';
      case MoonPhase.lastQuarter:
        return 'Last Quarter';
      case MoonPhase.waningCrescent:
        return 'Waning Crescent';
    }
  }

  String get icon {
    switch (this) {
      case MoonPhase.newMoon:
        return '🌑';
      case MoonPhase.waxingCrescent:
        return '🌒';
      case MoonPhase.firstQuarter:
        return '🌓';
      case MoonPhase.waxingGibbous:
        return '🌔';
      case MoonPhase.fullMoon:
        return '🌕';
      case MoonPhase.waningGibbous:
        return '🌖';
      case MoonPhase.lastQuarter:
        return '🌗';
      case MoonPhase.waningCrescent:
        return '🌘';
    }
  }
}

/// Water clarity for conditions tracking
enum TripWaterClarity {
  clear,
  lightStain,
  stained,
  muddy,
}

extension TripWaterClarityX on TripWaterClarity {
  String get displayName {
    switch (this) {
      case TripWaterClarity.clear:
        return 'Clear';
      case TripWaterClarity.lightStain:
        return 'Light Stain';
      case TripWaterClarity.stained:
        return 'Stained';
      case TripWaterClarity.muddy:
        return 'Muddy';
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Weather snapshot captured at trip start
@immutable
class WeatherSnapshot {
  final double? tempF;
  final double? windSpeedMph;
  final String? windDirection;
  final double? pressureMb;
  final int? cloudCoverPercent;
  final String? conditions; // sunny, cloudy, rainy, etc.

  const WeatherSnapshot({
    this.tempF,
    this.windSpeedMph,
    this.windDirection,
    this.pressureMb,
    this.cloudCoverPercent,
    this.conditions,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      tempF: (json['temp_f'] as num?)?.toDouble(),
      windSpeedMph: (json['wind_speed_mph'] as num?)?.toDouble(),
      windDirection: json['wind_direction'] as String?,
      pressureMb: (json['pressure_mb'] as num?)?.toDouble(),
      cloudCoverPercent: json['cloud_cover_percent'] as int?,
      conditions: json['conditions'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'temp_f': tempF,
        'wind_speed_mph': windSpeedMph,
        'wind_direction': windDirection,
        'pressure_mb': pressureMb,
        'cloud_cover_percent': cloudCoverPercent,
        'conditions': conditions,
      };

  String get summary {
    final parts = <String>[];
    if (tempF != null) parts.add('${tempF!.round()}°F');
    if (windSpeedMph != null && windDirection != null) {
      parts.add('$windDirection ${windSpeedMph!.round()}mph');
    }
    if (conditions != null) parts.add(conditions!);
    return parts.isEmpty ? 'No data' : parts.join(' • ');
  }
}

/// Conditions snapshot for trip - auto-captured at start
@immutable
class TripConditions {
  final WeatherSnapshot? weather;
  final double? waterTempF;
  final double? waterLevelFt;
  final TripWaterClarity? clarity;
  final MoonPhase? moonPhase;
  final double? solunarRating; // 0.0 - 1.0

  const TripConditions({
    this.weather,
    this.waterTempF,
    this.waterLevelFt,
    this.clarity,
    this.moonPhase,
    this.solunarRating,
  });

  factory TripConditions.fromJson(Map<String, dynamic> json) {
    return TripConditions(
      weather: json['weather'] != null
          ? WeatherSnapshot.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
      waterTempF: (json['water_temp_f'] as num?)?.toDouble(),
      waterLevelFt: (json['water_level_ft'] as num?)?.toDouble(),
      clarity: json['clarity'] != null
          ? TripWaterClarity.values.firstWhere(
              (e) => e.name == json['clarity'],
              orElse: () => TripWaterClarity.stained,
            )
          : null,
      moonPhase: json['moon_phase'] != null
          ? MoonPhase.values.firstWhere(
              (e) => e.name == json['moon_phase'],
              orElse: () => MoonPhase.firstQuarter,
            )
          : null,
      solunarRating: (json['solunar_rating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'weather': weather?.toJson(),
        'water_temp_f': waterTempF,
        'water_level_ft': waterLevelFt,
        'clarity': clarity?.name,
        'moon_phase': moonPhase?.name,
        'solunar_rating': solunarRating,
      };
}

/// GPS coordinates for catch location
@immutable
class CatchLocation {
  final double lat;
  final double lon;
  final String? description; // "Near the bridge", "Brush pile #3", etc.

  const CatchLocation({
    required this.lat,
    required this.lon,
    this.description,
  });

  factory CatchLocation.fromJson(Map<String, dynamic> json) {
    return CatchLocation(
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lon': lon,
        'description': description,
      };

  String get display => description ?? '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';
}

/// Bait used for a catch
@immutable
class BaitUsed {
  final String name;
  final String? color;
  final String? size;
  final String? type; // jig, live bait, crankbait, etc.

  const BaitUsed({
    required this.name,
    this.color,
    this.size,
    this.type,
  });

  factory BaitUsed.fromJson(Map<String, dynamic> json) {
    return BaitUsed(
      name: json['name'] as String,
      color: json['color'] as String?,
      size: json['size'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'size': size,
        'type': type,
      };

  String get display {
    final parts = <String>[name];
    if (color != null) parts.add(color!);
    if (size != null) parts.add(size!);
    return parts.join(' ');
  }
}

/// Individual catch record
@immutable
class CatchRecord {
  final String id;
  final String tripId;
  final FishSpecies species;
  final double? lengthInches;
  final double? weightLbs;
  final double? depthFt;
  final BaitUsed? bait;
  final CatchLocation? location;
  final DateTime caughtAt;
  final String? photoPath;
  final String? notes;
  final bool released;

  const CatchRecord({
    required this.id,
    required this.tripId,
    required this.species,
    this.lengthInches,
    this.weightLbs,
    this.depthFt,
    this.bait,
    this.location,
    required this.caughtAt,
    this.photoPath,
    this.notes,
    this.released = true,
  });

  factory CatchRecord.fromJson(Map<String, dynamic> json) {
    return CatchRecord(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      species: FishSpecies.values.firstWhere(
        (e) => e.name == json['species'],
        orElse: () => FishSpecies.whiteCrappie,
      ),
      lengthInches: (json['length_inches'] as num?)?.toDouble(),
      weightLbs: (json['weight_lbs'] as num?)?.toDouble(),
      depthFt: (json['depth_ft'] as num?)?.toDouble(),
      bait: json['bait'] != null
          ? BaitUsed.fromJson(json['bait'] as Map<String, dynamic>)
          : null,
      location: json['location'] != null
          ? CatchLocation.fromJson(json['location'] as Map<String, dynamic>)
          : null,
      caughtAt: DateTime.parse(json['caught_at'] as String),
      photoPath: json['photo_path'] as String?,
      notes: json['notes'] as String?,
      released: json['released'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_id': tripId,
        'species': species.name,
        'length_inches': lengthInches,
        'weight_lbs': weightLbs,
        'depth_ft': depthFt,
        'bait': bait?.toJson(),
        'location': location?.toJson(),
        'caught_at': caughtAt.toIso8601String(),
        'photo_path': photoPath,
        'notes': notes,
        'released': released,
      };

  CatchRecord copyWith({
    String? id,
    String? tripId,
    FishSpecies? species,
    double? lengthInches,
    double? weightLbs,
    double? depthFt,
    BaitUsed? bait,
    CatchLocation? location,
    DateTime? caughtAt,
    String? photoPath,
    String? notes,
    bool? released,
  }) {
    return CatchRecord(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      species: species ?? this.species,
      lengthInches: lengthInches ?? this.lengthInches,
      weightLbs: weightLbs ?? this.weightLbs,
      depthFt: depthFt ?? this.depthFt,
      bait: bait ?? this.bait,
      location: location ?? this.location,
      caughtAt: caughtAt ?? this.caughtAt,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      released: released ?? this.released,
    );
  }

  String get sizeDisplay {
    if (lengthInches == null && weightLbs == null) return 'No size';
    final parts = <String>[];
    if (lengthInches != null) parts.add('${lengthInches!.toStringAsFixed(1)}"');
    if (weightLbs != null) parts.add('${weightLbs!.toStringAsFixed(2)} lbs');
    return parts.join(' • ');
  }
}

/// Calculated trip statistics
@immutable
class TripStats {
  final int totalCatches;
  final int crappieCount;
  final double? biggestLengthInches;
  final double? biggestWeightLbs;
  final double? averageLengthInches;
  final Map<String, int> catchesBySpecies;
  final Map<String, int> catchesByBait;
  final Map<int, int> catchesByHour; // Hour of day -> count

  const TripStats({
    required this.totalCatches,
    required this.crappieCount,
    this.biggestLengthInches,
    this.biggestWeightLbs,
    this.averageLengthInches,
    this.catchesBySpecies = const {},
    this.catchesByBait = const {},
    this.catchesByHour = const {},
  });

  factory TripStats.fromCatches(List<CatchRecord> catches) {
    if (catches.isEmpty) {
      return const TripStats(totalCatches: 0, crappieCount: 0);
    }

    final bySpecies = <String, int>{};
    final byBait = <String, int>{};
    final byHour = <int, int>{};

    double? biggestLength;
    double? biggestWeight;
    double totalLength = 0;
    int lengthCount = 0;
    int crappieCount = 0;

    for (final c in catches) {
      // Species counts
      bySpecies[c.species.displayName] =
          (bySpecies[c.species.displayName] ?? 0) + 1;

      // Crappie count
      if (c.species.isCrappie) crappieCount++;

      // Bait counts
      if (c.bait != null) {
        byBait[c.bait!.display] = (byBait[c.bait!.display] ?? 0) + 1;
      }

      // Hourly counts
      byHour[c.caughtAt.hour] = (byHour[c.caughtAt.hour] ?? 0) + 1;

      // Size tracking
      if (c.lengthInches != null) {
        if (biggestLength == null || c.lengthInches! > biggestLength) {
          biggestLength = c.lengthInches;
        }
        totalLength += c.lengthInches!;
        lengthCount++;
      }
      if (c.weightLbs != null) {
        if (biggestWeight == null || c.weightLbs! > biggestWeight) {
          biggestWeight = c.weightLbs;
        }
      }
    }

    return TripStats(
      totalCatches: catches.length,
      crappieCount: crappieCount,
      biggestLengthInches: biggestLength,
      biggestWeightLbs: biggestWeight,
      averageLengthInches: lengthCount > 0 ? totalLength / lengthCount : null,
      catchesBySpecies: bySpecies,
      catchesByBait: byBait,
      catchesByHour: byHour,
    );
  }

  factory TripStats.fromJson(Map<String, dynamic> json) {
    return TripStats(
      totalCatches: json['total_catches'] as int,
      crappieCount: json['crappie_count'] as int,
      biggestLengthInches: (json['biggest_length_inches'] as num?)?.toDouble(),
      biggestWeightLbs: (json['biggest_weight_lbs'] as num?)?.toDouble(),
      averageLengthInches: (json['average_length_inches'] as num?)?.toDouble(),
      catchesBySpecies: Map<String, int>.from(json['catches_by_species'] ?? {}),
      catchesByBait: Map<String, int>.from(json['catches_by_bait'] ?? {}),
      catchesByHour: (json['catches_by_hour'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(int.parse(k), v as int)) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
        'total_catches': totalCatches,
        'crappie_count': crappieCount,
        'biggest_length_inches': biggestLengthInches,
        'biggest_weight_lbs': biggestWeightLbs,
        'average_length_inches': averageLengthInches,
        'catches_by_species': catchesBySpecies,
        'catches_by_bait': catchesByBait,
        'catches_by_hour':
            catchesByHour.map((k, v) => MapEntry(k.toString(), v)),
      };
}

/// A fishing trip
@immutable
class FishingTrip {
  final String id;
  final String? lakeId;
  final String? lakeName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TripConditions? conditions;
  final List<CatchRecord> catches;
  final String? notes;
  final bool isActive;

  const FishingTrip({
    required this.id,
    this.lakeId,
    this.lakeName,
    required this.startedAt,
    this.endedAt,
    this.conditions,
    this.catches = const [],
    this.notes,
    this.isActive = false,
  });

  factory FishingTrip.fromJson(Map<String, dynamic> json) {
    return FishingTrip(
      id: json['id'] as String,
      lakeId: json['lake_id'] as String?,
      lakeName: json['lake_name'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      conditions: json['conditions'] != null
          ? TripConditions.fromJson(json['conditions'] as Map<String, dynamic>)
          : null,
      catches: (json['catches'] as List<dynamic>?)
              ?.map((c) => CatchRecord.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lake_id': lakeId,
        'lake_name': lakeName,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'conditions': conditions?.toJson(),
        'catches': catches.map((c) => c.toJson()).toList(),
        'notes': notes,
        'is_active': isActive,
      };

  FishingTrip copyWith({
    String? id,
    String? lakeId,
    String? lakeName,
    DateTime? startedAt,
    DateTime? endedAt,
    TripConditions? conditions,
    List<CatchRecord>? catches,
    String? notes,
    bool? isActive,
  }) {
    return FishingTrip(
      id: id ?? this.id,
      lakeId: lakeId ?? this.lakeId,
      lakeName: lakeName ?? this.lakeName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      conditions: conditions ?? this.conditions,
      catches: catches ?? this.catches,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Duration of trip
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Formatted duration string
  String get durationDisplay {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Statistics for this trip
  TripStats get stats => TripStats.fromCatches(catches);

  /// Display title
  String get title {
    if (lakeName != null) return lakeName!;
    return 'Trip ${startedAt.month}/${startedAt.day}/${startedAt.year}';
  }

  /// Quick summary line
  String get summary {
    final fishCount = catches.length;
    final fish = fishCount == 1 ? 'fish' : 'fish';
    return '$fishCount $fish • $durationDisplay';
  }
}

/// Aggregate statistics across all trips
@immutable
class AggregateStats {
  final int totalTrips;
  final int totalCatches;
  final int totalCrappie;
  final Duration totalTime;
  final double? personalBestLengthInches;
  final double? personalBestWeightLbs;
  final double? averageCatchesPerTrip;
  final String? mostSuccessfulBait;
  final String? mostSuccessfulLake;
  final Map<String, int> catchesByMonth;
  final Map<String, int> catchesByConditions;

  const AggregateStats({
    required this.totalTrips,
    required this.totalCatches,
    required this.totalCrappie,
    required this.totalTime,
    this.personalBestLengthInches,
    this.personalBestWeightLbs,
    this.averageCatchesPerTrip,
    this.mostSuccessfulBait,
    this.mostSuccessfulLake,
    this.catchesByMonth = const {},
    this.catchesByConditions = const {},
  });

  factory AggregateStats.fromTrips(List<FishingTrip> trips) {
    if (trips.isEmpty) {
      return const AggregateStats(
        totalTrips: 0,
        totalCatches: 0,
        totalCrappie: 0,
        totalTime: Duration.zero,
      );
    }

    int totalCatches = 0;
    int totalCrappie = 0;
    Duration totalTime = Duration.zero;
    double? pbLength;
    double? pbWeight;
    final baitCounts = <String, int>{};
    final lakeCounts = <String, int>{};
    final monthCounts = <String, int>{};

    for (final trip in trips) {
      totalCatches += trip.catches.length;
      totalTime += trip.duration;

      // Lake tracking
      if (trip.lakeName != null) {
        lakeCounts[trip.lakeName!] =
            (lakeCounts[trip.lakeName!] ?? 0) + trip.catches.length;
      }

      for (final c in trip.catches) {
        // Crappie count
        if (c.species.isCrappie) totalCrappie++;

        // PB tracking
        if (c.lengthInches != null) {
          if (pbLength == null || c.lengthInches! > pbLength) {
            pbLength = c.lengthInches;
          }
        }
        if (c.weightLbs != null) {
          if (pbWeight == null || c.weightLbs! > pbWeight) {
            pbWeight = c.weightLbs;
          }
        }

        // Bait tracking
        if (c.bait != null) {
          baitCounts[c.bait!.display] =
              (baitCounts[c.bait!.display] ?? 0) + 1;
        }

        // Monthly tracking
        final monthKey =
            '${c.caughtAt.year}-${c.caughtAt.month.toString().padLeft(2, '0')}';
        monthCounts[monthKey] = (monthCounts[monthKey] ?? 0) + 1;
      }
    }

    // Find most successful bait
    String? topBait;
    int topBaitCount = 0;
    baitCounts.forEach((bait, count) {
      if (count > topBaitCount) {
        topBait = bait;
        topBaitCount = count;
      }
    });

    // Find most successful lake
    String? topLake;
    int topLakeCount = 0;
    lakeCounts.forEach((lake, count) {
      if (count > topLakeCount) {
        topLake = lake;
        topLakeCount = count;
      }
    });

    return AggregateStats(
      totalTrips: trips.length,
      totalCatches: totalCatches,
      totalCrappie: totalCrappie,
      totalTime: totalTime,
      personalBestLengthInches: pbLength,
      personalBestWeightLbs: pbWeight,
      averageCatchesPerTrip:
          trips.isNotEmpty ? totalCatches / trips.length : null,
      mostSuccessfulBait: topBait,
      mostSuccessfulLake: topLake,
      catchesByMonth: monthCounts,
    );
  }

  String get totalTimeDisplay {
    final hours = totalTime.inHours;
    if (hours > 24) {
      final days = hours ~/ 24;
      return '${days}d ${hours % 24}h';
    }
    return '${hours}h';
  }
}
