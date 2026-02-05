import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import '../models/wind_data.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';

/// Service for fetching wind data and calculating wind effects on lakes.
class WindService {
  static const _cacheDuration = Duration(minutes: 15);
  final Map<String, (WindForecast, DateTime)> _cache = {};

  /// Fetch wind forecast for a location.
  /// Returns 2 days of history + 7 days of forecast.
  Future<WindForecast> getWindForecast(double lat, double lon) async {
    final cacheKey = '${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
    
    // Check cache
    final cached = _cache[cacheKey];
    if (cached != null) {
      final (forecast, cachedAt) = cached;
      if (DateTime.now().difference(cachedAt) < _cacheDuration) {
        return forecast;
      }
    }

    try {
      final url = Uri.parse(
        '${ApiUrls.openMeteoBase}'
        '?latitude=$lat&longitude=$lon'
        '&current=wind_speed_10m,wind_direction_10m,wind_gusts_10m'
        '&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m'
        '&wind_speed_unit=mph'
        '&timezone=auto'
        '&past_days=2'
        '&forecast_days=7',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final forecast = _parseWindForecast(json.decode(response.body), lat, lon);
        _cache[cacheKey] = (forecast, DateTime.now());
        return forecast;
      }
    } catch (e, st) {
      AppLogger.error('WindService', 'getWindForecast($lat, $lon)', e, st);
    }

    return _mockWindForecast(lat, lon);
  }

  WindForecast _parseWindForecast(Map<String, dynamic> data, double lat, double lon) {
    final current = data['current'] ?? {};
    final hourly = data['hourly'] ?? {};

    final hourlyTimes = (hourly['time'] as List?)?.cast<String>() ?? [];
    final hourlySpeed = (hourly['wind_speed_10m'] as List?) ?? [];
    final hourlyDir = (hourly['wind_direction_10m'] as List?) ?? [];
    final hourlyGusts = (hourly['wind_gusts_10m'] as List?) ?? [];

    return WindForecast(
      current: WindConditions(
        speedMph: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
        gustsMph: (current['wind_gusts_10m'] as num?)?.toDouble() ?? 0,
        directionDeg: (current['wind_direction_10m'] as num?)?.toInt() ?? 0,
        timestamp: DateTime.now(),
      ),
      hourly: List.generate(
        hourlyTimes.length,
        (i) => WindForecastHour(
          time: DateTime.parse(hourlyTimes[i]),
          speedMph: (hourlySpeed[i] as num?)?.toDouble() ?? 0,
          gustsMph: (hourlyGusts[i] as num?)?.toDouble() ?? 0,
          directionDeg: (hourlyDir[i] as num?)?.toInt() ?? 0,
        ),
      ),
      fetchedAt: DateTime.now(),
      latitude: lat,
      longitude: lon,
    );
  }

  WindForecast _mockWindForecast(double lat, double lon) {
    final now = DateTime.now();
    const baseDirection = 210; // SSW
    const baseSpeed = 8.5;

    return WindForecast(
      current: WindConditions(
        speedMph: baseSpeed,
        gustsMph: baseSpeed * 1.4,
        directionDeg: baseDirection,
        timestamp: now,
      ),
      hourly: List.generate(
        216, // 9 days * 24 hours
        (i) {
          final hourOffset = i - 48; // Start 2 days ago
          final time = now.add(Duration(hours: hourOffset));
          // Simulate daily pattern: calmer at night, windier afternoon
          final hourOfDay = time.hour;
          final dailyFactor = 0.5 + 0.5 * math.sin((hourOfDay - 6) * math.pi / 12);
          // Add some daily variation
          final dayFactor = 1.0 + 0.3 * math.sin(i / 24 * math.pi);
          final speed = baseSpeed * dailyFactor * dayFactor;
          // Direction shifts slightly through the day
          final direction = (baseDirection + (hourOfDay * 2) % 30 - 15) % 360;

          return WindForecastHour(
            time: time,
            speedMph: speed.clamp(0.5, 25.0),
            gustsMph: (speed * 1.4).clamp(0.5, 35.0),
            directionDeg: direction.toInt(),
          );
        },
      ),
      fetchedAt: now,
      latitude: lat,
      longitude: lon,
    );
  }

  /// Analyze wind effects on a lake given its boundaries.
  /// Uses simplified rectangular bounds for demonstration.
  LakeWindAnalysis analyzeWindEffects({
    required WindConditions wind,
    required double lakeCenterLat,
    required double lakeCenterLon,
    required double lakeRadiusKm,
    double? lakeAreaAcres,
  }) {
    final affectedBanks = _calculateAffectedBanks(
      wind: wind,
      centerLat: lakeCenterLat,
      centerLon: lakeCenterLon,
      radiusKm: lakeRadiusKm,
    );

    final calmPockets = _findCalmPockets(
      wind: wind,
      centerLat: lakeCenterLat,
      centerLon: lakeCenterLon,
      radiusKm: lakeRadiusKm,
    );

    final waves = _calculateWaveConditions(
      wind: wind,
      fetchMiles: _estimateFetch(lakeAreaAcres ?? 1000, wind.directionDeg),
    );

    return LakeWindAnalysis(
      wind: wind,
      affectedBanks: affectedBanks,
      calmPockets: calmPockets,
      openWaterWaves: waves,
      analyzedAt: DateTime.now(),
    );
  }

  List<WindAffectedBank> _calculateAffectedBanks({
    required WindConditions wind,
    required double centerLat,
    required double centerLon,
    required double radiusKm,
  }) {
    final banks = <WindAffectedBank>[];
    const segmentCount = 16; // Create 16 shoreline segments around the lake

    for (int i = 0; i < segmentCount; i++) {
      final angle1 = (i * 360 / segmentCount) * math.pi / 180;
      final angle2 = ((i + 1) * 360 / segmentCount) * math.pi / 180;

      // Calculate segment endpoints
      final latOffset = radiusKm / 111.0; // ~111km per degree latitude
      final lonOffset = radiusKm / (111.0 * math.cos(centerLat * math.pi / 180));

      final startLat = centerLat + latOffset * math.cos(angle1);
      final startLon = centerLon + lonOffset * math.sin(angle1);
      final endLat = centerLat + latOffset * math.cos(angle2);
      final endLon = centerLon + lonOffset * math.sin(angle2);

      // Bank orientation (direction the bank faces, towards center)
      final midAngle = (i + 0.5) * 360 / segmentCount;
      final bankFacesDeg = (midAngle + 180) % 360;

      // Calculate exposure based on wind direction vs bank orientation
      final exposure = _calculateBankExposure(wind.directionDeg, bankFacesDeg);

      // Calculate fetch for this bank
      final fetch = _calculateFetchForBank(
        bankFacesDeg: bankFacesDeg,
        windDir: wind.directionDeg,
        radiusKm: radiusKm,
      );

      // Estimate wave height at this bank
      final waveHeight = _calculateWaveHeight(wind.speedMph, fetch);

      banks.add(WindAffectedBank(
        startLat: startLat,
        startLon: startLon,
        endLat: endLat,
        endLon: endLon,
        orientationDeg: bankFacesDeg,
        exposure: exposure,
        waveHeightFt: waveHeight,
        fetchMiles: fetch,
      ));
    }

    return banks;
  }

  BankExposure _calculateBankExposure(int windFromDeg, double bankFacesDeg) {
    // Wind blowing towards direction
    final windTowardsDeg = (windFromDeg + 180) % 360;
    
    // Angle difference between wind direction and bank face
    var angleDiff = (bankFacesDeg - windTowardsDeg).abs();
    if (angleDiff > 180) angleDiff = 360 - angleDiff;

    // Bank is exposed if wind is blowing towards it
    if (angleDiff < 45) return BankExposure.exposed;
    if (angleDiff < 90) return BankExposure.partial;
    return BankExposure.sheltered;
  }

  double _calculateFetchForBank({
    required double bankFacesDeg,
    required int windDir,
    required double radiusKm,
  }) {
    final windTowards = (windDir + 180) % 360;
    var angleDiff = (bankFacesDeg - windTowards).abs();
    if (angleDiff > 180) angleDiff = 360 - angleDiff;

    // Exposed banks have maximum fetch (wind travels across lake)
    // Sheltered banks have minimal fetch
    final fetchFactor = (180 - angleDiff) / 180;
    final fetchKm = radiusKm * 2 * fetchFactor;
    return fetchKm * 0.621371; // Convert to miles
  }

  List<CalmPocket> _findCalmPockets({
    required WindConditions wind,
    required double centerLat,
    required double centerLon,
    required double radiusKm,
  }) {
    final pockets = <CalmPocket>[];

    // Calm pocket is on the side the wind is blowing FROM (upwind = sheltered)
    final pocketOffset = radiusKm * 0.7 / 111.0;
    final pocketLat = centerLat + pocketOffset * math.cos(wind.directionRadians);
    final pocketLon = centerLon + pocketOffset * math.sin(wind.directionRadians) / 
        math.cos(centerLat * math.pi / 180);

    if (wind.speedMph > 5) {
      pockets.add(CalmPocket(
        centerLat: pocketLat,
        centerLon: pocketLon,
        radiusMiles: (radiusKm * 0.3 * 0.621371),
        description: 'Lee side calm area - protected from ${wind.compassDirection} wind',
      ));
    }

    return pockets;
  }

  WaveConditions _calculateWaveConditions({
    required WindConditions wind,
    required double fetchMiles,
  }) {
    final waveHeight = _calculateWaveHeight(wind.speedMph, fetchMiles);
    final period = _calculateWavePeriod(wind.speedMph, fetchMiles);
    final impact = _determineFishingImpact(waveHeight, wind.speedMph);

    return WaveConditions(
      heightFt: waveHeight,
      periodSeconds: period,
      fetchMiles: fetchMiles,
      fishingImpact: impact,
    );
  }

  /// Estimate wave height using simplified SMB method
  double _calculateWaveHeight(double windSpeedMph, double fetchMiles) {
    if (windSpeedMph < 1 || fetchMiles < 0.1) return 0;

    // Simplified significant wave height formula for freshwater lakes
    // Based on SMB method: Hs = f(U, F, g)
    final U = windSpeedMph * 0.44704; // Convert to m/s
    final F = fetchMiles * 1609.34; // Convert to meters

    final heightMeters = 0.0016 * math.pow(U, 2) * math.sqrt(F / 1000);
    final heightFt = heightMeters * 3.28084;

    // Cap at reasonable lake wave heights
    return heightFt.clamp(0.0, 6.0);
  }

  double _calculateWavePeriod(double windSpeedMph, double fetchMiles) {
    if (windSpeedMph < 1) return 0;
    // Simplified wave period calculation
    return (0.5 + fetchMiles * 0.3 + windSpeedMph * 0.05).clamp(0.5, 5.0);
  }

  double _estimateFetch(double areaAcres, int windDirection) {
    // Estimate fetch from lake area (simplified circular lake assumption)
    // Area in acres -> radius in miles -> diameter
    final radiusMiles = math.sqrt(areaAcres / 640) * math.sqrt(math.pi);
    return radiusMiles * 2 * 0.8; // ~80% of diameter as average fetch
  }

  WaveFishingImpact _determineFishingImpact(double waveHeightFt, double windSpeedMph) {
    if (windSpeedMph > 30 || waveHeightFt > 4) return WaveFishingImpact.dangerous;
    if (windSpeedMph > 20 || waveHeightFt > 3) return WaveFishingImpact.poor;
    if (windSpeedMph > 15 || waveHeightFt > 2) return WaveFishingImpact.fair;
    if (windSpeedMph > 8 || waveHeightFt > 0.5) return WaveFishingImpact.excellent;
    return WaveFishingImpact.good;
  }

  /// Clear the wind data cache
  void clearCache() {
    _cache.clear();
  }
}
