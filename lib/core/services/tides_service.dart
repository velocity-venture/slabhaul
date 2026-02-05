import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../models/tides_data.dart';
import '../utils/app_logger.dart';

/// Service for fetching tide data from NOAA CO-OPS API.
/// 
/// NOAA CO-OPS API is free and requires no authentication.
/// Base endpoint: https://api.tidesandcurrents.noaa.gov/api/prod/datagetter
/// 
/// Key products:
/// - predictions: Tide predictions (high/low times and heights)
/// - water_level: Actual water level readings
/// 
/// Parameters:
/// - datum: MLLW (Mean Lower Low Water) is standard
/// - time_zone: lst_ldt (local time with daylight savings)
/// - units: english (feet)
/// - format: json
class TidesService {
  static const String _baseUrl = 
      'https://api.tidesandcurrents.noaa.gov/api/prod/datagetter';
  static const Duration _timeout = Duration(seconds: 15);

  // Cache for loaded data
  List<TidalWater>? _cachedTidalWaters;
  Map<String, TideStation>? _cachedStations;

  /// Load tidal waters configuration from local JSON asset.
  Future<List<TidalWater>> loadTidalWaters() async {
    if (_cachedTidalWaters != null) return _cachedTidalWaters!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/tidal_waters.json');
      final jsonData = json.decode(jsonString);
      
      // Load stations
      final stationsData = jsonData['stations'] as List?;
      if (stationsData != null) {
        _cachedStations = {};
        for (final s in stationsData) {
          final station = TideStation.fromJson(s as Map<String, dynamic>);
          _cachedStations![station.id] = station;
        }
      }

      // Load tidal waters
      final watersData = jsonData['tidal_waters'] as List?;
      if (watersData != null) {
        _cachedTidalWaters = watersData
            .map((e) => TidalWater.fromJson(e as Map<String, dynamic>))
            .toList();
        return _cachedTidalWaters!;
      }

      return [];
    } catch (e, st) {
      AppLogger.error('TidesService', 'loadTidalWaters', e, st);
      return [];
    }
  }

  /// Get station info by ID.
  Future<TideStation?> getStation(String stationId) async {
    await loadTidalWaters(); // Ensure stations are loaded
    return _cachedStations?[stationId];
  }

  /// Check if a lake has tidal influence.
  Future<TidalWater?> getTidalWater(String lakeId) async {
    final waters = await loadTidalWaters();
    try {
      return waters.firstWhere((w) => w.lakeId == lakeId);
    } catch (_) {
      AppLogger.warn('TidesService', 'No tidal water found for lake: $lakeId');
      return null;
    }
  }

  /// Check if a lake is tidal.
  Future<bool> isLakeTidal(String lakeId) async {
    final water = await getTidalWater(lakeId);
    return water != null;
  }

  /// Fetch tide predictions (high/low times) for a station.
  /// 
  /// Returns predictions for the next [hours] hours (default 48).
  Future<List<TidePrediction>> getPredictions(
    String stationId, {
    int hours = 48,
  }) async {
    try {
      final now = DateTime.now();
      final end = now.add(Duration(hours: hours));

      final url = Uri.parse(
        '$_baseUrl?'
        'station=$stationId'
        '&product=predictions'
        '&datum=MLLW'
        '&time_zone=lst_ldt'
        '&units=english'
        '&format=json'
        '&begin_date=${_formatDate(now)}'
        '&end_date=${_formatDate(end)}'
        '&interval=hilo', // High/Low only
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List?;
        
        if (predictions != null) {
          return predictions
              .map((p) => TidePrediction.fromNoaaJson(p as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e, st) {
      AppLogger.error('TidesService', 'getPredictions($stationId)', e, st);
    }

    return [];
  }

  /// Fetch hourly tide predictions for chart display.
  /// 
  /// Returns hourly water levels for the next [hours] hours.
  Future<List<TideReading>> getHourlyPredictions(
    String stationId, {
    int hours = 48,
  }) async {
    try {
      final now = DateTime.now();
      final end = now.add(Duration(hours: hours));

      final url = Uri.parse(
        '$_baseUrl?'
        'station=$stationId'
        '&product=predictions'
        '&datum=MLLW'
        '&time_zone=lst_ldt'
        '&units=english'
        '&format=json'
        '&begin_date=${_formatDate(now)}'
        '&end_date=${_formatDate(end)}'
        '&interval=h', // Hourly
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List?;
        
        if (predictions != null) {
          return predictions.map((p) {
            final timestamp = DateTime.parse(
                (p['t'] as String).replaceFirst(' ', 'T'));
            final height = double.tryParse(p['v'] as String? ?? '') ?? 0;
            return TideReading(
              timestamp: timestamp,
              heightFt: height,
              type: TideType.slack, // Will be calculated later
              isPrediction: true,
            );
          }).toList();
        }
      }
    } catch (e, st) {
      AppLogger.error('TidesService', 'getHourlyPredictions($stationId)', e, st);
    }

    return [];
  }

  /// Fetch actual water level readings for a station.
  /// 
  /// Returns readings for the past [hours] hours (default 24).
  Future<List<TideReading>> getWaterLevels(
    String stationId, {
    int hours = 24,
  }) async {
    try {
      final now = DateTime.now();
      final start = now.subtract(Duration(hours: hours));

      final url = Uri.parse(
        '$_baseUrl?'
        'station=$stationId'
        '&product=water_level'
        '&datum=MLLW'
        '&time_zone=lst_ldt'
        '&units=english'
        '&format=json'
        '&begin_date=${_formatDate(start)}'
        '&end_date=${_formatDate(now)}',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final levels = data['data'] as List?;
        
        if (levels != null) {
          return levels.map((l) {
            final timestamp = DateTime.parse(
                (l['t'] as String).replaceFirst(' ', 'T'));
            final height = double.tryParse(l['v'] as String? ?? '') ?? 0;
            return TideReading(
              timestamp: timestamp,
              heightFt: height,
              type: TideType.slack, // Will be calculated
              isPrediction: false,
            );
          }).toList();
        }
      }
    } catch (e, st) {
      AppLogger.error('TidesService', 'getWaterLevels($stationId)', e, st);
    }

    return [];
  }

  /// Get full tide conditions for a station.
  Future<TideConditions?> getConditions(String stationId) async {
    try {
      // Fetch station info, predictions, and history in parallel
      final results = await Future.wait([
        getStation(stationId),
        getPredictions(stationId, hours: 72), // 3 days
        getWaterLevels(stationId, hours: 24),
      ]);

      final station = results[0] as TideStation?;
      final predictions = results[1] as List<TidePrediction>;
      final history = results[2] as List<TideReading>;

      if (station == null) {
        // Create minimal station if not in our data
        return TideConditions(
          station: TideStation(
            id: stationId,
            name: 'NOAA Station $stationId',
            latitude: 0,
            longitude: 0,
          ),
          currentReading: history.isNotEmpty ? history.last : null,
          predictions: predictions,
          history: history,
          fetchedAt: DateTime.now(),
        );
      }

      return TideConditions(
        station: station,
        currentReading: history.isNotEmpty ? history.last : null,
        predictions: predictions,
        history: history,
        fetchedAt: DateTime.now(),
      );
    } catch (e, st) {
      AppLogger.error('TidesService', 'getConditions($stationId)', e, st);
      return null;
    }
  }

  /// Get conditions for a lake if it's tidal.
  Future<TideConditions?> getConditionsForLake(String lakeId) async {
    final tidalWater = await getTidalWater(lakeId);
    if (tidalWater == null) return null;

    return getConditions(tidalWater.primaryStationId);
  }

  /// Calculate fishing windows based on tide predictions.
  /// 
  /// Returns optimal fishing periods for the next [hours] hours.
  Future<List<TideFishingWindow>> getFishingWindows(
    String stationId, {
    int hours = 48,
  }) async {
    final predictions = await getPredictions(stationId, hours: hours);
    if (predictions.length < 2) return [];

    final windows = <TideFishingWindow>[];
    
    for (int i = 0; i < predictions.length - 1; i++) {
      final current = predictions[i];
      final next = predictions[i + 1];

      // Calculate tide cycle details
      final cycleDuration = next.timestamp.difference(current.timestamp);
      final heightChange = (next.heightFt - current.heightFt).abs();
      final movementRate = heightChange / (cycleDuration.inMinutes / 60.0);

      // Best fishing is during active movement (middle 60% of cycle)
      // Slack periods (20% at each end) are generally slower
      final slackDuration = Duration(minutes: (cycleDuration.inMinutes * 0.2).round());
      
      // Active period windows
      final activeStart = current.timestamp.add(slackDuration);
      final activeEnd = next.timestamp.subtract(slackDuration);

      // Peak movement is middle third
      final peakStart = current.timestamp.add(Duration(
          minutes: (cycleDuration.inMinutes * 0.35).round()));
      final peakEnd = current.timestamp.add(Duration(
          minutes: (cycleDuration.inMinutes * 0.65).round()));

      // Add slack period (poor)
      windows.add(TideFishingWindow(
        start: current.timestamp,
        end: activeStart,
        rating: TideFishingRating.poor,
        reason: '${current.isHigh ? "High" : "Low"} tide slack - minimal water movement',
        movementRate: movementRate * 0.2,
      ));

      // Add early movement (fair to good)
      windows.add(TideFishingWindow(
        start: activeStart,
        end: peakStart,
        rating: TideFishingRating.good,
        reason: 'Tide ${next.isHigh ? "rising" : "falling"} - fish becoming active',
        movementRate: movementRate * 0.7,
      ));

      // Add peak movement (excellent)
      windows.add(TideFishingWindow(
        start: peakStart,
        end: peakEnd,
        rating: movementRate > 0.3 
            ? TideFishingRating.excellent 
            : TideFishingRating.good,
        reason: 'Peak tide movement - prime feeding conditions',
        movementRate: movementRate,
      ));

      // Add late movement (good)
      windows.add(TideFishingWindow(
        start: peakEnd,
        end: activeEnd,
        rating: TideFishingRating.good,
        reason: 'Strong ${next.isHigh ? "rising" : "falling"} tide continues',
        movementRate: movementRate * 0.7,
      ));
    }

    // Merge adjacent windows with same rating if desired
    return windows;
  }

  /// Find the nearest tide station to given coordinates.
  Future<TideStation?> findNearestStation(
    double latitude,
    double longitude,
  ) async {
    await loadTidalWaters();
    if (_cachedStations == null || _cachedStations!.isEmpty) return null;

    TideStation? nearest;
    double? minDistance;

    for (final station in _cachedStations!.values) {
      final distance = _calculateDistance(
        latitude, longitude,
        station.latitude, station.longitude,
      );

      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        nearest = station;
      }
    }

    return nearest;
  }

  /// Calculate approximate distance between two points (in miles).
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadiusMiles = 3959;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = 
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) * _cos(_toRadians(lat2)) *
        _sin(dLon / 2) * _sin(dLon / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadiusMiles * c;
  }

  double _toRadians(double degrees) => degrees * 3.14159265359 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorSin(x + 3.14159265359 / 2);
  double _sqrt(double x) => _newtonSqrt(x);
  double _atan2(double y, double x) => _approximateAtan2(y, x);

  // Taylor series approximation for sin
  double _taylorSin(double x) {
    // Normalize to [-π, π]
    while (x > 3.14159265359) {
      x -= 2 * 3.14159265359;
    }
    while (x < -3.14159265359) {
      x += 2 * 3.14159265359;
    }
    
    double result = x;
    double term = x;
    for (int i = 1; i <= 7; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  // Newton's method for sqrt
  double _newtonSqrt(double x) {
    if (x <= 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  // Approximate atan2
  double _approximateAtan2(double y, double x) {
    if (x == 0) {
      return y > 0 ? 3.14159265359 / 2 : -3.14159265359 / 2;
    }
    double atan = _approximateAtan(y / x);
    if (x < 0) {
      return y >= 0 ? atan + 3.14159265359 : atan - 3.14159265359;
    }
    return atan;
  }

  double _approximateAtan(double x) {
    // For small x, atan(x) ≈ x - x³/3 + x⁵/5
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * 3.14159265359 / 2 - _approximateAtan(1 / x);
    }
    double x2 = x * x;
    return x * (1 - x2 * (1/3 - x2 * (1/5 - x2 * (1/7 - x2 / 9))));
  }

  /// Format date for NOAA API (YYYYMMDD HH:mm).
  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$y$m$d $h:$min';
  }
}
