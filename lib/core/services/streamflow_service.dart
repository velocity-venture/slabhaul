import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import '../models/streamflow_data.dart';

/// Service for fetching streamflow data from USGS Water Services API.
/// 
/// USGS API is free and requires no authentication.
/// Endpoints:
/// - Instantaneous Values: https://waterservices.usgs.gov/nwis/iv/
/// - Daily Values: https://waterservices.usgs.gov/nwis/dv/
/// 
/// Parameters:
/// - 00060: Discharge (cfs)
/// - 00065: Gage height (ft)
class StreamflowService {
  static const String _baseUrl = 'https://waterservices.usgs.gov/nwis/iv/';
  static const Duration _timeout = Duration(seconds: 15);

  // USGS Parameter codes
  static const String _dischargeParam = '00060';
  static const String _gageHeightParam = '00065';

  List<InflowPoint>? _cachedInflows;

  /// Load inflow points from local JSON asset.
  Future<List<InflowPoint>> loadInflowPoints() async {
    if (_cachedInflows != null) return _cachedInflows!;

    try {
      final jsonString = await rootBundle.loadString('assets/data/inflows.json');
      final jsonData = json.decode(jsonString);
      final inflows = (jsonData['inflows'] as List)
          .map((e) => InflowPoint.fromJson(e as Map<String, dynamic>))
          .toList();
      _cachedInflows = inflows;
      return inflows;
    } catch (e) {
      // Return empty list on error (file might not exist yet)
      return [];
    }
  }

  /// Get inflow points for a specific lake.
  Future<List<InflowPoint>> getInflowsForLake(String lakeId) async {
    final allInflows = await loadInflowPoints();
    return allInflows.where((i) => i.lakeId == lakeId).toList();
  }

  /// Fetch current streamflow readings from USGS for given site IDs.
  /// 
  /// Returns a map of site ID -> StreamflowReading.
  Future<Map<String, StreamflowReading>> getCurrentReadings(
    List<String> siteIds,
  ) async {
    if (siteIds.isEmpty) return {};

    try {
      final sites = siteIds.join(',');
      final url = Uri.parse(
        '$_baseUrl?format=json'
        '&sites=$sites'
        '&parameterCd=$_dischargeParam,$_gageHeightParam'
        '&siteStatus=active',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseInstantaneousValues(json.decode(response.body));
      }
    } catch (e) {
      // Silently fail - will return empty map
    }

    return {};
  }

  /// Fetch 7-day history for a specific site.
  Future<List<StreamflowReading>> getHistory(
    String siteId, {
    int days = 7,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));
      
      final url = Uri.parse(
        '$_baseUrl?format=json'
        '&sites=$siteId'
        '&parameterCd=$_dischargeParam,$_gageHeightParam'
        '&startDT=${_formatDate(startDate)}'
        '&endDT=${_formatDate(endDate)}',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseTimeSeriesValues(json.decode(response.body), siteId);
      }
    } catch (e) {
      // Silently fail
    }

    return [];
  }

  /// Fetch full streamflow conditions for a site (current + history).
  Future<StreamflowConditions?> getConditions(String siteId) async {
    try {
      // Fetch 7-day history (includes current)
      final history = await getHistory(siteId, days: 7);
      
      if (history.isEmpty) return null;

      // Latest reading is current
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      final current = history.first;

      // Fetch site info
      final station = await _getSiteInfo(siteId);
      if (station == null) return null;

      // Get historical statistics (median for this time of year)
      final stats = await _getHistoricalStats(siteId);

      return StreamflowConditions(
        station: station,
        currentReading: current,
        history: history,
        historicalMedianCfs: stats?['median'],
        historicalPercentile: stats?['percentile'],
      );
    } catch (e) {
      return null;
    }
  }

  /// Get conditions for multiple inflow points.
  Future<List<InflowConditions>> getInflowConditions(
    List<InflowPoint> inflows,
  ) async {
    final results = <InflowConditions>[];
    final now = DateTime.now();

    // Collect all site IDs that have USGS gages
    final siteIds = inflows
        .where((i) => i.usgsGageId != null)
        .map((i) => i.usgsGageId!)
        .toSet()
        .toList();

    // Batch fetch current readings
    final readings = await getCurrentReadings(siteIds);

    for (final inflow in inflows) {
      StreamflowConditions? conditions;

      if (inflow.usgsGageId != null && readings.containsKey(inflow.usgsGageId)) {
        // We have a current reading, fetch full conditions
        conditions = await getConditions(inflow.usgsGageId!);
      }

      results.add(InflowConditions(
        inflow: inflow,
        conditions: conditions,
        fetchedAt: now,
      ));
    }

    return results;
  }

  /// Parse instantaneous values response from USGS.
  Map<String, StreamflowReading> _parseInstantaneousValues(
    Map<String, dynamic> data,
  ) {
    final results = <String, StreamflowReading>{};

    try {
      final value = data['value'] as Map<String, dynamic>?;
      if (value == null) return results;

      final timeSeries = value['timeSeries'] as List?;
      if (timeSeries == null) return results;

      // Group by site - we may have discharge and gage height for same site
      final siteData = <String, Map<String, dynamic>>{};

      for (final series in timeSeries) {
        final sourceInfo = series['sourceInfo'] as Map<String, dynamic>?;
        final variable = series['variable'] as Map<String, dynamic>?;
        final values = series['values'] as List?;

        if (sourceInfo == null || variable == null || values == null) continue;

        final siteCode = sourceInfo['siteCode']?[0]?['value'] as String?;
        final variableCode = variable['variableCode']?[0]?['value'] as String?;

        if (siteCode == null || variableCode == null) continue;

        siteData.putIfAbsent(siteCode, () => {});

        // Get the most recent value
        for (final valueSet in values) {
          final valueList = valueSet['value'] as List?;
          if (valueList == null || valueList.isEmpty) continue;

          // Most recent is typically last
          final latest = valueList.last;
          final valueNum = double.tryParse(latest['value']?.toString() ?? '');
          final dateTime = DateTime.tryParse(latest['dateTime'] ?? '');

          if (valueNum != null && valueNum >= 0 && dateTime != null) {
            siteData[siteCode]![variableCode] = {
              'value': valueNum,
              'dateTime': dateTime,
              'qualifier': latest['qualifier'],
            };
          }
        }
      }

      // Build readings
      for (final entry in siteData.entries) {
        final siteCode = entry.key;
        final data = entry.value;

        final discharge = data[_dischargeParam];
        if (discharge == null) continue;

        final gageHeight = data[_gageHeightParam];

        results[siteCode] = StreamflowReading(
          timestamp: discharge['dateTime'] as DateTime,
          flowRateCfs: discharge['value'] as double,
          gageHeightFt: gageHeight?['value'] as double?,
          qualifier: discharge['qualifier']?.toString(),
        );
      }
    } catch (e) {
      // Parse error - return what we have
    }

    return results;
  }

  /// Parse time series for history.
  List<StreamflowReading> _parseTimeSeriesValues(
    Map<String, dynamic> data,
    String targetSiteId,
  ) {
    final readings = <StreamflowReading>[];

    try {
      final value = data['value'] as Map<String, dynamic>?;
      if (value == null) return readings;

      final timeSeries = value['timeSeries'] as List?;
      if (timeSeries == null) return readings;

      // Find discharge series for target site
      Map<DateTime, double>? dischargeByTime;
      Map<DateTime, double>? gageHeightByTime;

      for (final series in timeSeries) {
        final sourceInfo = series['sourceInfo'] as Map<String, dynamic>?;
        final variable = series['variable'] as Map<String, dynamic>?;
        final values = series['values'] as List?;

        if (sourceInfo == null || variable == null || values == null) continue;

        final siteCode = sourceInfo['siteCode']?[0]?['value'] as String?;
        final variableCode = variable['variableCode']?[0]?['value'] as String?;

        if (siteCode != targetSiteId || variableCode == null) continue;

        final timeMap = <DateTime, double>{};

        for (final valueSet in values) {
          final valueList = valueSet['value'] as List?;
          if (valueList == null) continue;

          for (final v in valueList) {
            final valueNum = double.tryParse(v['value']?.toString() ?? '');
            final dateTime = DateTime.tryParse(v['dateTime'] ?? '');

            if (valueNum != null && valueNum >= 0 && dateTime != null) {
              timeMap[dateTime] = valueNum;
            }
          }
        }

        if (variableCode == _dischargeParam) {
          dischargeByTime = timeMap;
        } else if (variableCode == _gageHeightParam) {
          gageHeightByTime = timeMap;
        }
      }

      // Build readings from discharge data
      if (dischargeByTime != null) {
        for (final entry in dischargeByTime.entries) {
          readings.add(StreamflowReading(
            timestamp: entry.key,
            flowRateCfs: entry.value,
            gageHeightFt: gageHeightByTime?[entry.key],
          ));
        }

        // Sort by time
        readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (e) {
      // Parse error
    }

    return readings;
  }

  /// Get site information.
  Future<StreamflowStation?> _getSiteInfo(String siteId) async {
    try {
      final url = Uri.parse(
        'https://waterservices.usgs.gov/nwis/site/'
        '?format=rdb&sites=$siteId&siteOutput=expanded',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseSiteInfo(response.body, siteId);
      }
    } catch (e) {
      // Fallback: create minimal station info
      return StreamflowStation(
        siteId: siteId,
        name: 'USGS $siteId',
        latitude: 0,
        longitude: 0,
        streamName: 'Unknown',
      );
    }

    return null;
  }

  /// Parse RDB format site info.
  StreamflowStation? _parseSiteInfo(String rdbData, String targetSiteId) {
    try {
      final lines = rdbData.split('\n');
      
      // Find header line (first line not starting with #)
      int headerIndex = -1;
      for (int i = 0; i < lines.length; i++) {
        if (!lines[i].startsWith('#') && lines[i].trim().isNotEmpty) {
          headerIndex = i;
          break;
        }
      }

      if (headerIndex < 0 || headerIndex + 2 >= lines.length) return null;

      final headers = lines[headerIndex].split('\t');
      // Skip format line (line after header)
      final dataLine = lines[headerIndex + 2].split('\t');

      // Find column indices
      final siteNoIdx = headers.indexOf('site_no');
      final nameIdx = headers.indexOf('station_nm');
      final latIdx = headers.indexOf('dec_lat_va');
      final lonIdx = headers.indexOf('dec_long_va');
      final stateIdx = headers.indexOf('state_cd');
      final countyIdx = headers.indexOf('county_nm');
      final drainIdx = headers.indexOf('drain_area_va');

      if (siteNoIdx < 0 || nameIdx < 0) return null;

      return StreamflowStation(
        siteId: dataLine[siteNoIdx],
        name: nameIdx < dataLine.length ? dataLine[nameIdx] : 'Unknown',
        latitude: latIdx < dataLine.length 
            ? double.tryParse(dataLine[latIdx]) ?? 0 
            : 0,
        longitude: lonIdx < dataLine.length 
            ? double.tryParse(dataLine[lonIdx]) ?? 0 
            : 0,
        streamName: nameIdx < dataLine.length 
            ? _extractStreamName(dataLine[nameIdx]) 
            : 'Unknown',
        stateCode: stateIdx < dataLine.length ? dataLine[stateIdx] : null,
        countyName: countyIdx < dataLine.length ? dataLine[countyIdx] : null,
        drainageAreaSqMi: drainIdx < dataLine.length 
            ? double.tryParse(dataLine[drainIdx]) 
            : null,
      );
    } catch (e) {
      return null;
    }
  }

  /// Extract stream name from station name (e.g., "OBION RIVER NR OBION, TN" -> "Obion River")
  String _extractStreamName(String stationName) {
    // Common patterns: "RIVER NAME at/nr/below/above LOCATION, STATE"
    final patterns = [' at ', ' nr ', ' near ', ' below ', ' above ', ' bl '];
    
    String name = stationName;
    for (final pattern in patterns) {
      final idx = name.toLowerCase().indexOf(pattern);
      if (idx > 0) {
        name = name.substring(0, idx);
        break;
      }
    }

    // Title case
    return name.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get historical statistics for a site.
  /// Returns {'median': double, 'percentile': double} or null.
  Future<Map<String, double>?> _getHistoricalStats(String siteId) async {
    // USGS statistics service
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');

      final url = Uri.parse(
        'https://waterservices.usgs.gov/nwis/stat/'
        '?format=json'
        '&sites=$siteId'
        '&statReportType=daily'
        '&statTypeCd=p50' // median
        '&parameterCd=$_dischargeParam',
      );

      final response = await http.get(url).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Parse the statistical data
        final statistics = data['value']?['timeSeries']?[0]?['values']?[0]?['value'];
        
        if (statistics != null) {
          // Find stat for current month/day
          for (final stat in statistics) {
            if (stat['month'] == month && stat['day'] == day) {
              final median = double.tryParse(stat['value']?.toString() ?? '');
              if (median != null) {
                return {'median': median};
              }
            }
          }
        }
      }
    } catch (e) {
      // Stats not available
    }

    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate flow trend from readings.
  FlowTrend calculateTrend(List<StreamflowReading> readings) {
    if (readings.length < 2) return FlowTrend.stable;

    final sorted = List<StreamflowReading>.from(readings)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Compare first third to last third
    final third = (sorted.length / 3).ceil();
    final oldReadings = sorted.take(third).toList();
    final newReadings = sorted.skip(sorted.length - third).toList();

    final oldAvg = oldReadings.fold(0.0, (sum, r) => sum + r.flowRateCfs) / oldReadings.length;
    final newAvg = newReadings.fold(0.0, (sum, r) => sum + r.flowRateCfs) / newReadings.length;

    final changePercent = ((newAvg - oldAvg) / oldAvg) * 100;

    if (changePercent > 15) return FlowTrend.rising;
    if (changePercent < -15) return FlowTrend.falling;
    return FlowTrend.stable;
  }
}
