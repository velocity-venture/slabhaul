import 'package:flutter_test/flutter_test.dart';
import 'package:slabhaul/core/models/attractor.dart';

void main() {
  final sampleJson = {
    'id': 'attr-001',
    'name': 'AGFC Brush Pile #12',
    'latitude': 35.678901,
    'longitude': -89.123456,
    'lake_id': 'greers-ferry',
    'lake_name': "Greer's Ferry Lake",
    'state': 'AR',
    'type': 'brush_pile',
    'depth': 18.5,
    'description': 'Large brush pile near creek channel',
    'source': 'AGFC',
    'year_placed': 2023,
    'verified': true,
  };

  group('Attractor', () {
    test('fromJson creates fully populated instance', () {
      final attr = Attractor.fromJson(sampleJson);
      expect(attr.id, 'attr-001');
      expect(attr.name, 'AGFC Brush Pile #12');
      expect(attr.latitude, 35.678901);
      expect(attr.longitude, -89.123456);
      expect(attr.lakeId, 'greers-ferry');
      expect(attr.lakeName, "Greer's Ferry Lake");
      expect(attr.state, 'AR');
      expect(attr.type, 'brush_pile');
      expect(attr.depth, 18.5);
      expect(attr.description, 'Large brush pile near creek channel');
      expect(attr.source, 'AGFC');
      expect(attr.yearPlaced, 2023);
      expect(attr.verified, true);
    });

    test('fromJson defaults type to unknown when null', () {
      final json = Map<String, dynamic>.from(sampleJson)..remove('type');
      final attr = Attractor.fromJson(json);
      expect(attr.type, 'unknown');
    });

    test('fromJson defaults verified to false when null', () {
      final json = Map<String, dynamic>.from(sampleJson)..remove('verified');
      final attr = Attractor.fromJson(json);
      expect(attr.verified, false);
    });

    test('toJson round-trip preserves all fields', () {
      final original = Attractor.fromJson(sampleJson);
      final json = original.toJson();
      final restored = Attractor.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.latitude, original.latitude);
      expect(restored.longitude, original.longitude);
      expect(restored.lakeId, original.lakeId);
      expect(restored.lakeName, original.lakeName);
      expect(restored.state, original.state);
      expect(restored.type, original.type);
      expect(restored.depth, original.depth);
      expect(restored.description, original.description);
      expect(restored.source, original.source);
      expect(restored.yearPlaced, original.yearPlaced);
      expect(restored.verified, original.verified);
    });

    test('typeLabel maps known types', () {
      const types = {
        'brush_pile': 'Brush Pile',
        'pvc_tree': 'PVC Tree',
        'stake_bed': 'Stake Bed',
        'pallet': 'Pallet',
        'unknown': 'Unknown',
        'anything_else': 'Unknown',
      };
      for (final entry in types.entries) {
        final attr = Attractor(
          id: 'test', name: 'Test',
          latitude: 0, longitude: 0,
          lakeId: 'l', lakeName: 'L', state: 'TN',
          type: entry.key,
        );
        expect(attr.typeLabel, entry.value);
      }
    });

    test('coordinateString formats to 6 decimal places', () {
      final attr = Attractor.fromJson(sampleJson);
      expect(attr.coordinateString, '35.678901, -89.123456');
    });

    test('handles optional null fields', () {
      const attr = Attractor(
        id: 'min', name: 'Minimal',
        latitude: 36.0, longitude: -90.0,
        lakeId: 'l', lakeName: 'Lake', state: 'TN',
        type: 'brush_pile',
      );
      expect(attr.depth, isNull);
      expect(attr.description, isNull);
      expect(attr.source, isNull);
      expect(attr.yearPlaced, isNull);
      expect(attr.verified, false);
    });
  });
}
