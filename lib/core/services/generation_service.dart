import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/generation_data.dart';
import '../utils/constants.dart';

/// Service to fetch dam generation schedules and discharge data.
///
/// Currently uses USGS discharge data as a proxy for generation status.
/// High discharge rates indicate turbines are running.
///
/// Future enhancement: Add direct TVA API scraping when available.
class GenerationService {
  static const _usgsBase = 'https://waterservices.usgs.gov/nwis/iv/';

  /// Get generation data for a specific dam
  Future<GenerationData> getGenerationData(DamConfig dam) async {
    // Try USGS data first if we have a gage ID
    if (dam.usgsGageId != null) {
      try {
        return await _fetchUsgsDischarge(dam);
      } catch (_) {
        // Fall back to simulated data
      }
    }

    // Use pattern-based simulation for TVA dams
    return _simulateGeneration(dam);
  }

  /// Fetch discharge data from USGS and infer generation status
  Future<GenerationData> _fetchUsgsDischarge(DamConfig dam) async {
    final url = Uri.parse(
      '$_usgsBase?format=json'
      '&sites=${dam.usgsGageId}'
      '&parameterCd=00060' // Discharge (cfs)
      '&period=P2D', // Last 2 days
    );

    final response = await http.get(url).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      throw Exception('USGS request failed: ${response.statusCode}');
    }

    return _parseUsgsResponse(json.decode(response.body), dam);
  }

  GenerationData _parseUsgsResponse(Map<String, dynamic> data, DamConfig dam) {
    final timeSeries = (data['value']?['timeSeries'] as List?) ?? [];
    if (timeSeries.isEmpty) {
      throw Exception('No time series data');
    }

    final List<GenerationReading> readings = [];
    double? currentDischarge;

    for (final series in timeSeries) {
      final paramCode =
          series['variable']?['variableCode']?[0]?['value'] as String?;
      if (paramCode != '00060') continue;

      final values = (series['values']?[0]?['value'] as List?) ?? [];
      for (final v in values) {
        final discharge = double.tryParse(v['value']?.toString() ?? '');
        final time = DateTime.tryParse(v['dateTime']?.toString() ?? '');

        if (discharge != null && time != null) {
          final isGenerating = dam.generationThresholdCfs != null
              ? discharge >= dam.generationThresholdCfs!
              : discharge > (dam.baseflowCfs ?? 0) * 2;

          readings.add(GenerationReading(
            timestamp: time,
            dischargeCfs: discharge,
            isGenerating: isGenerating,
          ));
        }
      }

      if (values.isNotEmpty) {
        currentDischarge =
            double.tryParse(values.last['value']?.toString() ?? '');
      }
    }

    // Sort by timestamp
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Determine current status
    final status = _determineStatus(
      currentDischarge,
      dam.baseflowCfs,
      dam.generationThresholdCfs,
      dam.typicalPattern,
    );

    return GenerationData(
      damId: dam.id,
      damName: dam.name,
      lakeName: dam.lakeName,
      powerAuthority: dam.powerAuthority,
      currentStatus: status,
      currentDischargeCfs: currentDischarge,
      baseflowCfs: dam.baseflowCfs,
      lastUpdated: readings.isNotEmpty ? readings.last.timestamp : DateTime.now(),
      recentReadings: readings,
      upcomingSchedule: _estimateSchedule(dam),
      typicalPattern: dam.typicalPattern,
    );
  }

  /// Determine generation status from discharge level
  GenerationStatus _determineStatus(
    double? discharge,
    double? baseflow,
    double? threshold,
    GenerationPattern? pattern,
  ) {
    if (discharge == null) return GenerationStatus.unknown;

    // If we have a threshold, use it
    if (threshold != null) {
      if (discharge >= threshold) return GenerationStatus.generating;
      // Check if scheduled soon based on pattern
      if (pattern != null && pattern.isCurrentlyPeakHour) {
        return GenerationStatus.scheduled;
      }
      return GenerationStatus.idle;
    }

    // Otherwise, use baseflow ratio
    if (baseflow != null && baseflow > 0) {
      final ratio = discharge / baseflow;
      if (ratio >= 2.5) return GenerationStatus.generating;
      if (ratio >= 1.5 && pattern?.isCurrentlyPeakHour == true) {
        return GenerationStatus.scheduled;
      }
    }

    return GenerationStatus.idle;
  }

  /// Estimate upcoming generation windows based on typical patterns
  List<ScheduledGeneration> _estimateSchedule(DamConfig dam) {
    final pattern = dam.typicalPattern;
    if (pattern == null) return [];

    final schedule = <ScheduledGeneration>[];
    final now = DateTime.now();

    // Look ahead 48 hours
    for (var i = 0; i < 48; i++) {
      final checkTime = now.add(Duration(hours: i));
      final hour = checkTime.hour;
      final isWeekday = checkTime.weekday <= 5;

      // Check if this is a peak hour
      if (pattern.peakHours.contains(hour)) {
        // Probability check
        final prob = isWeekday
            ? pattern.weekdayProbability
            : pattern.weekendProbability;

        // Use deterministic "randomness" based on date for consistency
        final seed = checkTime.year * 10000 +
            checkTime.month * 100 +
            checkTime.day +
            hour;
        final rng = Random(seed);

        if (rng.nextDouble() < prob) {
          // Find consecutive peak hours for window end
          var endHour = hour;
          while (pattern.peakHours.contains((endHour + 1) % 24) &&
              endHour - hour < 4) {
            endHour++;
          }

          schedule.add(ScheduledGeneration(
            startTime: DateTime(
              checkTime.year,
              checkTime.month,
              checkTime.day,
              hour,
            ),
            endTime: DateTime(
              checkTime.year,
              checkTime.month,
              checkTime.day,
              endHour + 1,
            ),
            notes: isWeekday ? 'Typical weekday generation' : 'Weekend generation',
          ));

          // Skip ahead past this window
          i += endHour - hour;
        }
      }
    }

    return schedule;
  }

  /// Simulate generation data based on patterns (fallback when USGS unavailable)
  GenerationData _simulateGeneration(DamConfig dam) {
    final now = DateTime.now();
    final pattern = dam.typicalPattern;
    final rng = Random(now.millisecondsSinceEpoch ~/ 300000); // Changes every 5 min

    // Determine if currently generating based on pattern
    final isGenerating = pattern != null &&
        pattern.isCurrentlyPeakHour &&
        rng.nextDouble() <
            (now.weekday <= 5
                ? pattern.weekdayProbability
                : pattern.weekendProbability);

    final baseflow = dam.baseflowCfs ?? 10000;
    final currentDischarge = isGenerating
        ? baseflow * (2.5 + rng.nextDouble() * 1.5)
        : baseflow * (0.8 + rng.nextDouble() * 0.4);

    // Generate historical readings (last 48 hours)
    final readings = <GenerationReading>[];
    for (var i = 48; i >= 0; i--) {
      final time = now.subtract(Duration(hours: i));
      final hour = time.hour;
      final wasGenerating = pattern != null &&
          pattern.peakHours.contains(hour) &&
          Random(time.millisecondsSinceEpoch ~/ 3600000).nextDouble() <
              (time.weekday <= 5
                  ? pattern.weekdayProbability
                  : pattern.weekendProbability);

      final discharge = wasGenerating
          ? baseflow * (2.2 + Random(time.millisecondsSinceEpoch).nextDouble())
          : baseflow * (0.8 + Random(time.millisecondsSinceEpoch).nextDouble() * 0.4);

      readings.add(GenerationReading(
        timestamp: time,
        dischargeCfs: discharge,
        isGenerating: wasGenerating,
      ));
    }

    return GenerationData(
      damId: dam.id,
      damName: dam.name,
      lakeName: dam.lakeName,
      powerAuthority: dam.powerAuthority,
      currentStatus: isGenerating
          ? GenerationStatus.generating
          : (pattern?.isCurrentlyPeakHour == true
              ? GenerationStatus.scheduled
              : GenerationStatus.idle),
      currentDischargeCfs: currentDischarge,
      baseflowCfs: baseflow,
      lastUpdated: now,
      recentReadings: readings,
      upcomingSchedule: _estimateSchedule(dam),
      typicalPattern: pattern,
    );
  }
}
