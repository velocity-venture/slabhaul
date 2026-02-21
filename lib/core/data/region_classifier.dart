import '../models/hatch_recommendation.dart';

/// Classifies a GPS coordinate into a fishing region.
///
/// Region boundaries based on latitude/longitude:
/// - South: < 34N
/// - Mid-South: 34-37N
/// - Midwest: 37-43N (west of -80W)
/// - North: > 43N
/// - Northeast: > 38N and east of -80W
class RegionClassifier {
  const RegionClassifier._();

  static FishingRegion classify(double lat, double lon) {
    // Northeast: above 38N and east of -80W
    if (lat > 38 && lon > -80) return FishingRegion.northeast;

    if (lat < 34) return FishingRegion.south;
    if (lat < 37) return FishingRegion.midSouth;
    if (lat < 43) return FishingRegion.midwest;
    return FishingRegion.north;
  }
}
