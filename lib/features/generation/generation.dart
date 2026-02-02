/// Dam generation tracking feature for SlabHaul.
///
/// Tracks TVA dam generation schedules to help anglers time their fishing
/// around current conditions that trigger feeding behavior.
library;

// Models
export 'package:slabhaul/core/models/generation_data.dart';

// Service
export 'package:slabhaul/core/services/generation_service.dart';

// Providers
export 'providers/generation_providers.dart';
export 'providers/generation_lake_provider.dart';

// Widgets
export 'widgets/generation_status_card.dart';
