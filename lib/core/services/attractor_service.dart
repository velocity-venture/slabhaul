import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/attractor.dart';
import '../models/lake.dart';
import 'supabase_service.dart';

class AttractorService {
  List<Lake>? _cachedLakes;
  List<Attractor>? _cachedAttractors;

  Future<List<Lake>> getLakes() async {
    if (_cachedLakes != null) return _cachedLakes!;

    // Try Supabase first
    if (SupabaseService.isAvailable) {
      try {
        final data =
            await SupabaseService.client!.from('lakes').select();
        _cachedLakes =
            (data as List).map((e) => Lake.fromJson(e)).toList();
        return _cachedLakes!;
      } catch (_) {}
    }

    // Fall back to local JSON
    return _loadLocalLakes();
  }

  Future<List<Attractor>> getAttractors({String? lakeId}) async {
    if (_cachedAttractors != null) {
      return lakeId == null
          ? _cachedAttractors!
          : _cachedAttractors!.where((a) => a.lakeId == lakeId).toList();
    }

    // Try Supabase first
    if (SupabaseService.isAvailable) {
      try {
        var query = SupabaseService.client!.from('attractors').select();
        if (lakeId != null) {
          query = query.eq('lake_id', lakeId);
        }
        final data = await query;
        _cachedAttractors =
            (data as List).map((e) => Attractor.fromJson(e)).toList();
        return _cachedAttractors!;
      } catch (_) {}
    }

    // Fall back to local JSON
    return _loadLocalAttractors(lakeId: lakeId);
  }

  Future<List<Lake>> _loadLocalLakes() async {
    final jsonStr =
        await rootBundle.loadString('assets/data/attractors.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final lakesJson = data['lakes'] as List;
    _cachedLakes = lakesJson.map((e) => Lake.fromJson(e)).toList();
    return _cachedLakes!;
  }

  Future<List<Attractor>> _loadLocalAttractors({String? lakeId}) async {
    final jsonStr =
        await rootBundle.loadString('assets/data/attractors.json');
    final data = json.decode(jsonStr) as Map<String, dynamic>;
    final attractorsJson = data['attractors'] as List;
    _cachedAttractors =
        attractorsJson.map((e) => Attractor.fromJson(e)).toList();

    if (lakeId != null) {
      return _cachedAttractors!.where((a) => a.lakeId == lakeId).toList();
    }
    return _cachedAttractors!;
  }

  void clearCache() {
    _cachedLakes = null;
    _cachedAttractors = null;
  }
}
