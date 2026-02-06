import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/core/models/lake.dart';

void main() {
  final sampleJson = {
    'id': 'reelfoot',
    'name': 'Reelfoot Lake',
    'state': 'TN',
    'center_lat': 36.3487,
    'center_lon': -89.4112,
    'zoom_level': 12.5,
    'normal_pool_elevation': 282.2,
    'usgs_gage_id': '07025500',
    'attractor_count': 45,
    'max_depth_ft': 18.0,
    'area_acres': 15000.0,
    'mixing_type': 'polymictic',
  };

  group('Lake', () {
    test('fromJson creates valid instance', () {
      final lake = Lake.fromJson(sampleJson);
      expect(lake.id, 'reelfoot');
      expect(lake.name, 'Reelfoot Lake');
      expect(lake.state, 'TN');
      expect(lake.centerLat, 36.3487);
      expect(lake.centerLon, -89.4112);
      expect(lake.zoomLevel, 12.5);
      expect(lake.normalPoolElevation, 282.2);
      expect(lake.usgsGageId, '07025500');
      expect(lake.attractorCount, 45);
      expect(lake.maxDepthFt, 18.0);
      expect(lake.areaAcres, 15000.0);
      expect(lake.mixingType, 'polymictic');
    });

    test('fromJson defaults zoomLevel to 13.0', () {
      final json = {
        'id': 'test',
        'name': 'Test Lake',
        'state': 'AR',
        'center_lat': 35.0,
        'center_lon': -92.0,
      };
      final lake = Lake.fromJson(json);
      expect(lake.zoomLevel, 13.0);
    });

    test('fromJson defaults attractorCount to 0', () {
      final json = {
        'id': 'test',
        'name': 'Test Lake',
        'state': 'AR',
        'center_lat': 35.0,
        'center_lon': -92.0,
      };
      final lake = Lake.fromJson(json);
      expect(lake.attractorCount, 0);
    });

    test('toJson round-trip preserves all fields', () {
      final original = Lake.fromJson(sampleJson);
      final json = original.toJson();
      final restored = Lake.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.state, original.state);
      expect(restored.centerLat, original.centerLat);
      expect(restored.centerLon, original.centerLon);
      expect(restored.zoomLevel, original.zoomLevel);
      expect(restored.normalPoolElevation, original.normalPoolElevation);
      expect(restored.usgsGageId, original.usgsGageId);
      expect(restored.attractorCount, original.attractorCount);
      expect(restored.maxDepthFt, original.maxDepthFt);
      expect(restored.areaAcres, original.areaAcres);
      expect(restored.mixingType, original.mixingType);
    });

    test('displayName combines name and state', () {
      final lake = Lake.fromJson(sampleJson);
      expect(lake.displayName, 'Reelfoot Lake, TN');
    });

    test('coordinates returns tuple', () {
      final lake = Lake.fromJson(sampleJson);
      expect(lake.coordinates, (36.3487, -89.4112));
    });

    test('canStratify returns true for deep lakes', () {
      final lake = Lake.fromJson(sampleJson);
      expect(lake.canStratify, isTrue);
    });

    test('canStratify returns false for shallow lakes', () {
      const lake = Lake(
        id: 'shallow',
        name: 'Shallow Pond',
        state: 'TN',
        centerLat: 35.0,
        centerLon: -89.0,
        maxDepthFt: 10.0,
      );
      expect(lake.canStratify, isFalse);
    });

    test('canStratify defaults to true when maxDepthFt is null', () {
      const lake = Lake(
        id: 'unknown',
        name: 'Unknown Depth',
        state: 'TN',
        centerLat: 35.0,
        centerLon: -89.0,
      );
      expect(lake.canStratify, isTrue); // defaults to 30 >= 15
    });

    test('surfaceAreaAcres aliases areaAcres', () {
      final lake = Lake.fromJson(sampleJson);
      expect(lake.surfaceAreaAcres, lake.areaAcres);
    });
  });
}
