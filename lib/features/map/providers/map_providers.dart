import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/app/providers.dart';
import 'package:slabhaul/core/models/attractor.dart';
import 'package:slabhaul/core/models/lake.dart';

/// Loads all lakes from the attractor service.
final lakesProvider = FutureProvider<List<Lake>>((ref) async {
  final service = ref.watch(attractorServiceProvider);
  return service.getLakes();
});

/// Loads all attractors from the attractor service.
final attractorsProvider = FutureProvider<List<Attractor>>((ref) async {
  final service = ref.watch(attractorServiceProvider);
  return service.getAttractors();
});

/// Currently selected lake ID for filtering attractors on the map.
/// Null means "All Lakes".
final selectedLakeProvider = StateProvider<String?>((ref) => null);

/// Currently selected attractor type for filtering.
/// Null means "All" types.
final selectedTypeProvider = StateProvider<String?>((ref) => null);

/// Derived provider that filters the full attractor list by the currently
/// selected lake and type. Returns the full list when both filters are null.
final filteredAttractorsProvider = FutureProvider<List<Attractor>>((ref) async {
  final allAttractors = await ref.watch(attractorsProvider.future);
  final selectedLake = ref.watch(selectedLakeProvider);
  final selectedType = ref.watch(selectedTypeProvider);

  var result = allAttractors;

  if (selectedLake != null) {
    result = result.where((a) => a.lakeId == selectedLake).toList();
  }

  if (selectedType != null) {
    result = result.where((a) => a.type == selectedType).toList();
  }

  return result;
});

/// The attractor currently selected by the user (tapped marker).
/// When non-null the bottom sheet is shown.
final selectedAttractorProvider = StateProvider<Attractor?>((ref) => null);
