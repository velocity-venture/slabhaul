import 'package:slabhaul/features/weather/providers/weather_providers.dart';

/// Pre-configured TVA lake coordinates for weather/generation tracking.
class TvaLakes {
  static const kentucky = WeatherLakeCoords(
    lat: 36.6,
    lon: -88.1,
    name: 'Kentucky Lake',
    maxDepthFt: 75,
    areaAcres: 160309,
  );

  static const pickwick = WeatherLakeCoords(
    lat: 35.1,
    lon: -88.3,
    name: 'Pickwick Lake',
    maxDepthFt: 57,
    areaAcres: 43100,
  );

  static const wheeler = WeatherLakeCoords(
    lat: 34.6,
    lon: -87.1,
    name: 'Wheeler Lake',
    maxDepthFt: 50,
    areaAcres: 67100,
  );

  static const guntersville = WeatherLakeCoords(
    lat: 34.4,
    lon: -86.3,
    name: 'Guntersville Lake',
    maxDepthFt: 60,
    areaAcres: 69100,
  );

  static const reelfoot = WeatherLakeCoords(
    lat: 36.387,
    lon: -89.387,
    name: 'Reelfoot Lake',
    maxDepthFt: 18,
    areaAcres: 15000,
  );

  static List<WeatherLakeCoords> get all => [
        reelfoot,
        kentucky,
        pickwick,
        wheeler,
        guntersville,
      ];
}
