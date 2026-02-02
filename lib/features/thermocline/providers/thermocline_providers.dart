import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/thermocline_service.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/models/lake.dart';

/// Provider for the thermocline prediction service
final thermoclineServiceProvider = Provider((ref) => ThermoclineService());

/// Provider for thermocline data for a specific lake
/// 
/// Usage:
/// ```dart
/// final thermocline = ref.watch(thermoclineDataProvider(lake));
/// ```
/// 
/// Note: Requires weather and lake conditions to be available.
/// In the full app, this would depend on weatherProvider and lakeConditionsProvider.
final thermoclineDataProvider = FutureProvider.autoDispose
    .family<ThermoclineData?, Lake>((ref, lake) async {
  // In the full implementation, these would be real providers:
  // final weather = await ref.watch(weatherProvider(lake.coordinates).future);
  // final conditions = await ref.watch(lakeConditionsProvider(lake.id).future);
  
  // For now, return null - this will be connected when integrating with the app
  return null;
});

/// Simple state holder for selected lake's thermocline (for UI state management)
class ThermoclineState {
  final ThermoclineData? data;
  final bool isLoading;
  final String? error;
  
  const ThermoclineState({
    this.data,
    this.isLoading = false,
    this.error,
  });
  
  ThermoclineState copyWith({
    ThermoclineData? data,
    bool? isLoading,
    String? error,
  }) {
    return ThermoclineState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier for managing thermocline state
class ThermoclineNotifier extends StateNotifier<ThermoclineState> {
  final ThermoclineService _service;
  
  ThermoclineNotifier(this._service) : super(const ThermoclineState());
  
  /// Load thermocline prediction for a lake
  Future<void> loadPrediction({
    required Lake lake,
    required dynamic weather,      // WeatherData
    required dynamic conditions,   // LakeConditions
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final data = await _service.predictThermocline(
        lake: lake,
        weather: weather,
        conditions: conditions,
      );
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to predict thermocline: $e',
      );
    }
  }
  
  /// Clear current prediction
  void clear() {
    state = const ThermoclineState();
  }
}

/// StateNotifierProvider for thermocline state management
final thermoclineNotifierProvider = 
    StateNotifierProvider<ThermoclineNotifier, ThermoclineState>((ref) {
  return ThermoclineNotifier(ref.read(thermoclineServiceProvider));
});
