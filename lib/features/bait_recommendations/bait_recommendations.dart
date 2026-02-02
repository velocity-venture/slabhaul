/// Bait Recommendations Feature
/// 
/// Science-backed crappie bait recommendation engine that considers:
/// - Water temperature (seasonal patterns)
/// - Water clarity (color visibility)
/// - Depth/thermocline positioning
/// - Time of day / solunar periods
/// - Weather conditions (pressure, fronts)
/// - Structure type
/// 
/// Example usage:
/// ```dart
/// // Set conditions
/// ref.read(fishingConditionsProvider.notifier).setWaterTemp(58);
/// ref.read(fishingConditionsProvider.notifier).setClarity(WaterClarity.stained);
/// ref.read(fishingConditionsProvider.notifier).setTargetDepth(12);
/// 
/// // Get recommendations
/// final result = ref.watch(baitRecommendationsProvider);
/// final topPick = result?.topPick;
/// ```

// Models
export '../../core/models/bait_recommendation.dart';

// Service
export '../../core/services/bait_recommendation_service.dart';

// Providers
export 'providers/bait_recommendation_providers.dart';

// Screens
export 'screens/bait_recommendations_screen.dart';

// Widgets
export 'widgets/bait_recommendation_card.dart';
export 'widgets/bait_recommendation_mini.dart';
export 'widgets/conditions_input_form.dart';
