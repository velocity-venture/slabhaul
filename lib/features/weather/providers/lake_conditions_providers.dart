import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/lake_conditions.dart';

/// Fetches lake conditions for Reelfoot Lake from the USGS gage.
///
/// Gage ID: 07025400 (Reelfoot Lake near Tiptonville, TN)
/// Normal pool elevation: 282.0 ft
final lakeConditionsProvider = FutureProvider<LakeConditions>((ref) async {
  final lakeService = ref.read(lakeServiceProvider);
  return lakeService.getLakeConditions(
    'reelfoot',
    '07025400',
    normalPool: 282.0,
  );
});
