# Dam Generation Schedule Feature

## Overview

This feature tracks TVA (Tennessee Valley Authority) dam generation schedules for reservoir fishing. When dams release water through their turbines ("generation"), it creates current that triggers feeding behavior in crappie and other species.

## Why It Matters

- **Current triggers feeding**: Generation creates water movement that pushes baitfish around, causing predator fish to become more active
- **Timing is critical**: Knowing when generation starts helps anglers position themselves at current breaks and structure edges
- **Pattern recognition**: Generation typically follows electricity demand patterns (morning/evening peaks on weekdays)

## Supported Dams

| Dam | Lake | Power Authority | Notes |
|-----|------|-----------------|-------|
| Kentucky Dam | Kentucky Lake | TVA | Largest TVA dam |
| Pickwick Dam | Pickwick Lake | TVA | Run-of-river |
| Wheeler Dam | Wheeler Lake | TVA | Run-of-river |
| Guntersville Dam | Guntersville Lake | TVA | Largest TVA reservoir |

## Data Sources

### Current Implementation
- **USGS Discharge Data**: Real-time discharge (cfs) from USGS gages below dams
- **Pattern-Based Simulation**: Uses historical patterns when live data unavailable
- **TVA Lake Info**: Future integration planned (currently Cloudflare protected)

### How Generation is Determined
1. **Discharge Threshold**: If current flow exceeds threshold (e.g., 25,000 cfs for Kentucky Dam), generation is active
2. **Baseflow Ratio**: If flow is >2.5x baseflow, likely generating
3. **Time Patterns**: Peak hours (6-9 AM, 5-8 PM) have higher generation probability

## Architecture

```
lib/
├── core/
│   ├── models/
│   │   └── generation_data.dart    # Data models (GenerationData, DamConfig, etc.)
│   └── services/
│       └── generation_service.dart  # Fetches/simulates generation data
├── features/
│   └── generation/
│       ├── providers/
│       │   ├── generation_providers.dart      # Riverpod providers
│       │   └── generation_lake_provider.dart  # Lake-specific providers
│       └── widgets/
│           └── generation_status_card.dart    # Main UI widget
```

## Usage

### Add to a screen
```dart
import 'package:slabhaul/features/generation/providers/generation_lake_provider.dart';
import 'package:slabhaul/features/generation/widgets/generation_status_card.dart';

// In your widget:
if (ref.watch(hasGenerationTrackingProvider))
  ref.watch(lakeGenerationProvider).when(
    data: (data) => data != null
        ? GenerationStatusCard(data: data)
        : const SizedBox.shrink(),
    loading: () => const CircularProgressIndicator(),
    error: (e, _) => Text('Error: $e'),
  ),
```

### Get data for a specific dam
```dart
final data = await ref.read(generationDataForDamProvider(TvaDams.kentucky).future);
```

## Fishing Tips (by status)

- **GENERATING**: Fish current breaks behind structure. Crappie position to ambush baitfish pushed by current.
- **SCHEDULED**: Position near ledges and main-channel points where fish stage before current starts.
- **IDLE**: Fish tighter to cover. Work brushpiles and timber more slowly.

## Future Enhancements

1. **Direct TVA API**: Server-side scraping of TVA's lake info pages
2. **Push Notifications**: Alert when generation starts at favorite lake
3. **Historical Analysis**: Show generation patterns over weeks/months
4. **Flow Forecast**: Predict generation based on weather and power demand
5. **USACE Integration**: Add support for Army Corps dams (Cumberland system)
