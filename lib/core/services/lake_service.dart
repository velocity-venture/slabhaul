import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/lake_conditions.dart';
import '../utils/constants.dart';

class LakeService {
  Future<LakeConditions> getLakeConditions(
    String lakeId,
    String usgsGageId, {
    double? normalPool,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiUrls.usgsWaterServices}'
        '?format=json&sites=$usgsGageId'
        '&parameterCd=00065,00010&period=P7D',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return _parseUsgs(
          json.decode(response.body),
          lakeId,
          usgsGageId,
          normalPool,
        );
      }
    } catch (_) {}

    return _mockConditions(lakeId, usgsGageId, normalPool);
  }

  LakeConditions _parseUsgs(
    Map<String, dynamic> data,
    String lakeId,
    String gageId,
    double? normalPool,
  ) {
    double? level;
    double? temp;
    final List<LevelReading> readings = [];

    final timeSeries =
        (data['value']?['timeSeries'] as List?) ?? [];

    for (final series in timeSeries) {
      final paramCode =
          series['variable']?['variableCode']?[0]?['value'] as String?;
      final values = (series['values']?[0]?['value'] as List?) ?? [];

      if (paramCode == '00065' && values.isNotEmpty) {
        // Gage height
        level = double.tryParse(values.last['value']?.toString() ?? '');
        for (final v in values) {
          final val = double.tryParse(v['value']?.toString() ?? '');
          final time = DateTime.tryParse(v['dateTime']?.toString() ?? '');
          if (val != null && time != null) {
            readings.add(LevelReading(timestamp: time, valueFt: val));
          }
        }
      } else if (paramCode == '00010' && values.isNotEmpty) {
        // Water temperature (Celsius → Fahrenheit)
        final tempC =
            double.tryParse(values.last['value']?.toString() ?? '');
        if (tempC != null) {
          temp = tempC * 9 / 5 + 32;
        }
      }
    }

    return LakeConditions(
      lakeId: lakeId,
      waterLevelFt: level,
      normalPoolFt: normalPool,
      waterTempF: temp,
      lastUpdated: readings.isNotEmpty ? readings.last.timestamp : null,
      usgsGageId: gageId,
      recentReadings: readings,
    );
  }

  LakeConditions _mockConditions(
    String lakeId,
    String gageId,
    double? normalPool,
  ) {
    final now = DateTime.now();
    final rng = Random(lakeId.hashCode);
    final baseLevel = normalPool ?? 359.0;

    return LakeConditions(
      lakeId: lakeId,
      waterLevelFt: baseLevel + (rng.nextDouble() * 2 - 0.5),
      normalPoolFt: normalPool,
      waterTempF: 52 + rng.nextDouble() * 10,
      lastUpdated: now,
      usgsGageId: gageId,
      recentReadings: List.generate(
        168, // 7 days hourly
        (i) => LevelReading(
          timestamp: now.subtract(Duration(hours: 168 - i)),
          valueFt: baseLevel +
              sin(i / 24.0 * 3.14159) * 0.3 +
              (rng.nextDouble() - 0.5) * 0.1,
        ),
      ),
    );
  }
}
