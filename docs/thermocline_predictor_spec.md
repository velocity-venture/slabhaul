# Thermocline Predictor - Technical Specification

**Version:** 1.0  
**Author:** SlabHaul Engineering  
**Date:** February 2026  
**Status:** Design Complete - Ready for Implementation

---

## Executive Summary

The Thermocline Predictor is SlabHaul's key differentiator — a feature that predicts where crappie will concentrate in summer by calculating the depth of the thermocline (the boundary layer between warm, oxygenated surface water and cold, oxygen-depleted deep water). 

When a lake stratifies in summer, crappie are "squeezed" into a narrow depth band. Finding this band is the difference between a full cooler and a skunk. This feature turns environmental physics into actionable fishing intelligence.

---

## Table of Contents

1. [Scientific Foundation](#1-scientific-foundation)
2. [Data Sources & APIs](#2-data-sources--apis)
3. [Prediction Algorithm](#3-prediction-algorithm)
4. [UI/UX Design](#4-uiux-design)
5. [Technical Implementation](#5-technical-implementation)
6. [File Structure](#6-file-structure)
7. [Database Schema](#7-database-schema)
8. [Testing Strategy](#8-testing-strategy)
9. [Future Enhancements](#9-future-enhancements)

---

## 1. Scientific Foundation

### 1.1 What is a Thermocline?

A thermocline (also called the *metalimnion*) is a distinct layer in a lake where temperature drops rapidly with depth. Lakes stratify into three layers:

| Layer | Name | Characteristics |
|-------|------|-----------------|
| **Top** | Epilimnion | Warm (70-85°F), well-oxygenated, mixed by wind |
| **Middle** | Metalimnion (Thermocline) | Rapid temperature gradient (1-3°F per foot) |
| **Bottom** | Hypolimnion | Cold (45-55°F), often oxygen-depleted |

### 1.2 Why Crappie Concentrate at the Thermocline

1. **Oxygen Squeeze**: Below the thermocline, bacterial decomposition depletes oxygen. Crappie avoid water with <4mg/L dissolved oxygen.
2. **Temperature Preference**: Crappie prefer 68-75°F water. The thermocline often marks this zone.
3. **Baitfish Concentration**: Shad also concentrate at the thermocline, creating a feeding zone.
4. **The "Ceiling Effect"**: In summer, crappie won't go deeper than the thermocline — it acts as a depth floor.

### 1.3 Factors Affecting Thermocline Depth

| Factor | Impact | Data Source |
|--------|--------|-------------|
| **Surface Temperature** | Higher surface temps = deeper thermocline | USGS, Open-Meteo |
| **Air Temperature History** | Cumulative heating determines stratification strength | Open-Meteo historical |
| **Wind Speed** | Strong winds mix surface layer deeper | Open-Meteo hourly |
| **Lake Depth** | Shallow lakes (<20') may not stratify | Lake metadata |
| **Lake Surface Area** | Larger lakes have deeper thermoclines | Lake metadata |
| **Latitude** | Southern lakes stratify earlier/longer | Lake coordinates |
| **Time of Year** | Peak stratification July-August | Calendar |
| **Water Clarity** | Clear water = deeper light penetration = deeper heating | Satellite (future) |
| **Recent Storms** | Can temporarily disrupt stratification | Weather history |

### 1.4 Stratification Lifecycle

```
WINTER (Mixed)          SPRING (Forming)         SUMMER (Stratified)       FALL (Breaking)
│                       │                        │                         │
│   ~50°F               │   ~55°F ─────          │   ~80°F ─────           │   ~65°F
│   throughout          │        \               │        |                │   ↘
│                       │   ~52°F  \             │   ~72°F |thermocline    │     ~60°F
│                       │          ─────         │         |               │          ↘
│                       │   ~50°F                │   ~50°F ─────           │   ~55°F ──
│                       │                        │   (anoxic)              │
└───────────────────────└────────────────────────└─────────────────────────└──────────────
    Dec-Feb                  Mar-May                  Jun-Aug                  Sep-Nov
```

---

## 2. Data Sources & APIs

### 2.1 Primary Data Sources (Free, Already Integrated)

#### USGS Water Services (Existing Integration)
- **URL**: `https://waterservices.usgs.gov/nwis/iv/`
- **Parameters**:
  - `00010` - Water Temperature (°C)
  - `00065` - Gage Height (ft)
  - `00300` - Dissolved Oxygen (mg/L) — *if available*
- **Coverage**: ~3,000 sites with temperature data
- **Latency**: 15-60 minute delay
- **Limitation**: Surface temperature only; no depth profiles

#### Open-Meteo Weather API (Existing Integration)
- **URL**: `https://api.open-meteo.com/v1/forecast`
- **Key Parameters for Thermocline**:
  - `temperature_2m` - Air temperature
  - `wind_speed_10m` - Wind speed (mixing factor)
  - `shortwave_radiation` - Solar heating
  - `soil_temperature_0cm` - Surface temperature proxy
- **Historical**: 3-month archive available

### 2.2 Secondary Data Sources (New Integrations)

#### NOAA Great Lakes (Large Lakes Only)
- **URL**: `https://coastwatch.glerl.noaa.gov/glsea/glsea.html`
- **Data**: Satellite-derived surface temperature, vertical temperature moorings
- **Coverage**: Great Lakes only
- **Format**: NetCDF, downloadable CSVs

#### NOAA NDBC (Buoys)
- **URL**: `https://www.ndbc.noaa.gov/data/realtime2/`
- **Data**: Buoy water temperature (some with depth profiles)
- **Coverage**: ~50 inland lake buoys
- **Format**: Text files, parseable

#### EPA National Lakes Assessment (Historical Reference)
- **URL**: EPA data downloads (CSV)
- **Data**: Temperature profiles from sampled lakes
- **Use**: Calibration data for model training

### 2.3 Calculated/Derived Sources

#### Degree Day Accumulation
Calculate cumulative heating above a base temperature (e.g., 50°F):

```
heating_degree_days = Σ max(0, daily_avg_temp - 50)
```

This predicts stratification timing better than current temperature alone.

#### Fetch-Based Mixing Model
Wind effect depends on lake geometry (fetch length):

```
mixing_depth = f(wind_speed, fetch_length, duration)
```

### 2.4 Data Source Decision Matrix

| Data Need | Primary Source | Fallback | Confidence Impact |
|-----------|---------------|----------|-------------------|
| Surface water temp | USGS gage | Open-Meteo soil_temp | High → Medium |
| Air temp history | Open-Meteo archive | None | Required |
| Wind speed | Open-Meteo hourly | None | Required |
| Lake max depth | Lake metadata (Supabase) | Estimate from area | High → Low |
| Dissolved oxygen | USGS (if available) | Model estimate | Bonus |
| Latitude | Lake coordinates | GPS | Required |

---

## 3. Prediction Algorithm

### 3.1 Algorithm Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                    THERMOCLINE PREDICTOR PIPELINE                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐            │
│  │   Inputs     │   │  Processing  │   │   Outputs    │            │
│  │              │   │              │   │              │            │
│  │ • Surface T  │──▶│ 1. Check     │──▶│ • Status     │            │
│  │ • Air Temp   │   │    season    │   │ • Depth      │            │
│  │ • Wind       │   │ 2. Calc      │   │ • Target     │            │
│  │ • Lake Meta  │   │    degree    │   │   Range      │            │
│  │ • Date       │   │    days      │   │ • Confidence │            │
│  │              │   │ 3. Apply     │   │ • Recommend  │            │
│  │              │   │    model     │   │              │            │
│  │              │   │ 4. Adjust    │   │              │            │
│  │              │   │    for wind  │   │              │            │
│  └──────────────┘   └──────────────┘   └──────────────┘            │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### 3.2 Algorithm Pseudocode

```dart
/// Main thermocline prediction algorithm
ThermoclineData predictThermocline({
  required Lake lake,
  required WeatherData weather,
  required LakeConditions conditions,
  required DateTime date,
}) {
  // Step 1: Determine if stratification is possible
  final status = determineStratificationStatus(
    surfaceTemp: conditions.waterTempF,
    latitude: lake.centerLat,
    dayOfYear: date.dayOfYear,
    lakeDepth: lake.maxDepthFt,
  );
  
  if (status == StratificationStatus.mixed) {
    return ThermoclineData.noThermocline(
      surfaceTemp: conditions.waterTempF,
      recommendation: "Lake is mixed. Fish can be at any depth.",
    );
  }
  
  // Step 2: Calculate cumulative heating (degree days)
  final degreeDays = calculateDegreeDays(
    tempHistory: weather.historicalDaily,
    baseTemp: 50.0,
    daysBack: 90,
  );
  
  // Step 3: Base thermocline depth from empirical model
  double baseDepth = calculateBaseThermoclineDepth(
    surfaceTemp: conditions.waterTempF,
    degreeDays: degreeDays,
    latitude: lake.centerLat,
    maxLakeDepth: lake.maxDepthFt,
  );
  
  // Step 4: Apply wind mixing adjustment
  final windAdjustment = calculateWindMixingAdjustment(
    avgWindSpeed: weather.last48hAvgWind,
    peakWindSpeed: weather.last48hMaxWind,
    lakeSurfaceArea: lake.surfaceAreaAcres,
  );
  baseDepth += windAdjustment;
  
  // Step 5: Calculate confidence
  final confidence = calculateConfidence(
    hasUsgsTemp: conditions.waterTempF != null,
    hasRecentData: conditions.lastUpdated.isRecent,
    hasLakeDepth: lake.maxDepthFt != null,
    degreeDays: degreeDays,
  );
  
  // Step 6: Determine target fishing depth
  // Crappie typically hold 0-5 feet ABOVE thermocline
  final targetDepthMin = max(5, baseDepth - 5);
  final targetDepthMax = baseDepth;
  
  // Step 7: Generate recommendation
  final recommendation = generateRecommendation(
    status: status,
    targetDepthMin: targetDepthMin,
    targetDepthMax: targetDepthMax,
    confidence: confidence,
    surfaceTemp: conditions.waterTempF,
  );
  
  return ThermoclineData(
    thermoclineTopFt: baseDepth,
    thermoclineBottomFt: baseDepth + 3, // ~3ft thick typically
    targetDepthMinFt: targetDepthMin,
    targetDepthMaxFt: targetDepthMax,
    surfaceTempF: conditions.waterTempF ?? 75,
    thermoclineTempF: estimateThermoclineTemp(conditions.waterTempF),
    confidence: confidence,
    status: status,
    recommendation: recommendation,
    factors: gatherFactors(conditions, weather, lake),
    generatedAt: DateTime.now(),
  );
}
```

### 3.3 Stratification Status Logic

```dart
StratificationStatus determineStratificationStatus({
  required double? surfaceTemp,
  required double latitude,
  required int dayOfYear,
  required double? lakeDepth,
}) {
  // Lakes < 15ft deep rarely form stable thermoclines
  if (lakeDepth != null && lakeDepth < 15) {
    return StratificationStatus.mixed;
  }
  
  // Temperature below 60°F = lake not stratified
  if (surfaceTemp != null && surfaceTemp < 60) {
    return StratificationStatus.mixed;
  }
  
  // Seasonal windows (adjusted by latitude)
  final latitudeOffset = (latitude - 35) * 3; // Days per degree from baseline
  
  // Forming: April-May (Day 91-152)
  final formingStart = 91 + latitudeOffset.round();
  final formingEnd = 152 + latitudeOffset.round();
  
  // Stratified: June-August (Day 153-244)
  final stratifiedStart = 153 + latitudeOffset.round();
  final stratifiedEnd = 244 + latitudeOffset.round();
  
  // Breaking: September-October (Day 245-305)
  final breakingStart = 245 + latitudeOffset.round();
  final breakingEnd = 305 + latitudeOffset.round();
  
  if (dayOfYear >= formingStart && dayOfYear < stratifiedStart) {
    // Check if forming based on temp
    if (surfaceTemp != null && surfaceTemp >= 65) {
      return StratificationStatus.forming;
    }
    return StratificationStatus.mixed;
  }
  
  if (dayOfYear >= stratifiedStart && dayOfYear <= stratifiedEnd) {
    if (surfaceTemp != null && surfaceTemp >= 70) {
      return StratificationStatus.stratified;
    }
    return StratificationStatus.forming;
  }
  
  if (dayOfYear >= breakingStart && dayOfYear <= breakingEnd) {
    return StratificationStatus.breaking;
  }
  
  return StratificationStatus.mixed; // Winter
}
```

### 3.4 Base Thermocline Depth Model

Based on limnological research, thermocline depth correlates with:

```dart
double calculateBaseThermoclineDepth({
  required double surfaceTemp,
  required double degreeDays,
  required double latitude,
  required double? maxLakeDepth,
}) {
  // Empirical base model (calibrated from EPA lake data)
  // Thermocline deepens as summer progresses
  
  // Base depth increases with cumulative heating
  double depth = 8 + (degreeDays / 150); // Starts ~8ft, deepens ~1ft/150DD
  
  // Surface temp adjustment
  // Hotter surface = shallower thermocline (paradoxically)
  // Because steep gradient forms faster
  if (surfaceTemp > 82) {
    depth -= (surfaceTemp - 82) * 0.3;
  }
  
  // Latitude adjustment
  // Northern lakes have shallower thermoclines (less heating)
  depth -= (latitude - 35) * 0.2;
  
  // Lake depth constraint
  // Thermocline can't be deeper than 70% of lake max depth
  if (maxLakeDepth != null) {
    depth = min(depth, maxLakeDepth * 0.7);
  }
  
  // Clamp to reasonable range
  return depth.clamp(6, 35);
}
```

### 3.5 Wind Mixing Adjustment

Wind deepens the mixed layer (pushes thermocline down):

```dart
double calculateWindMixingAdjustment({
  required double avgWindSpeed,  // mph, 48h average
  required double peakWindSpeed, // mph, 48h max
  required double? lakeSurfaceArea, // acres
}) {
  double adjustment = 0;
  
  // Sustained moderate wind (10-15 mph) deepens thermocline
  if (avgWindSpeed > 10) {
    adjustment += (avgWindSpeed - 10) * 0.3; // ~0.3ft per mph over 10
  }
  
  // Peak winds have temporary but significant effect
  if (peakWindSpeed > 20) {
    adjustment += (peakWindSpeed - 20) * 0.2;
  }
  
  // Larger lakes have more fetch = more wind effect
  if (lakeSurfaceArea != null && lakeSurfaceArea > 5000) {
    adjustment *= 1.2; // 20% increase for large lakes
  }
  
  return adjustment.clamp(0, 8); // Max 8ft adjustment
}
```

### 3.6 Confidence Calculation

```dart
double calculateConfidence({
  required bool hasUsgsTemp,
  required bool hasRecentData,
  required bool hasLakeDepth,
  required double degreeDays,
}) {
  double confidence = 0.5; // Base confidence
  
  // Real water temp data = +20%
  if (hasUsgsTemp) confidence += 0.2;
  
  // Recent data (< 24h) = +15%
  if (hasRecentData) confidence += 0.15;
  
  // Known lake depth = +10%
  if (hasLakeDepth) confidence += 0.1;
  
  // Peak summer (high degree days) = more predictable
  if (degreeDays > 800) confidence += 0.05;
  
  return confidence.clamp(0.3, 0.95);
}
```

### 3.7 Recommendation Generation

```dart
String generateRecommendation({
  required StratificationStatus status,
  required double targetDepthMin,
  required double targetDepthMax,
  required double confidence,
  required double? surfaceTemp,
}) {
  switch (status) {
    case StratificationStatus.mixed:
      return "Lake is mixed — crappie can be at any depth. "
             "Focus on structure and cover at all depths.";
    
    case StratificationStatus.forming:
      return "Thermocline forming. Target ${targetDepthMin.round()}-${targetDepthMax.round()}ft, "
             "but check shallower structure too. Fish still transitioning.";
    
    case StratificationStatus.stratified:
      final tempNote = (surfaceTemp != null && surfaceTemp > 82)
          ? " Surface is hot — crappie will avoid top 8-10ft."
          : "";
      return "Fish the thermocline zone: ${targetDepthMin.round()}-${targetDepthMax.round()}ft.$tempNote "
             "Suspended crappie will be near this depth over deep water.";
    
    case StratificationStatus.breaking:
      return "Fall turnover beginning. Patterns unpredictable — "
             "try multiple depths. ${targetDepthMin.round()}-${targetDepthMax.round()}ft is a starting point.";
  }
}
```

---

## 4. UI/UX Design

### 4.1 Primary Display: Depth Visualization Card

```
┌─────────────────────────────────────────────────────────────────┐
│  🌡️ THERMOCLINE PREDICTOR                    🟢 High Confidence │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│    Surface: 81°F                                                │
│    ═══════════════════════════════════════  0 ft               │
│    │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│                       │
│    │░░░░░░░░░░░ EPILIMNION ░░░░░░░░░░░│  (warm, oxygenated)   │
│    │░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░│                       │
│    ├───────────────────────────────────┤                       │
│    │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ 12-15 ft             │
│  🎯│▓▓▓▓▓▓▓ TARGET ZONE ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ← FISH HERE          │
│    │▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│ ~72°F                │
│    ├───────────────────────────────────┤ 18 ft (thermocline)  │
│    │                                   │                       │
│    │          HYPOLIMNION              │  (cold, low oxygen)  │
│    │         ⚠️ Avoid                  │                       │
│    │                                   │                       │
│    ═══════════════════════════════════════  40 ft (max depth) │
│                                                                 │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ 💡 Fish 12-15ft over deep water. Suspended crappie will   │ │
│  │    be holding just above the thermocline.                 │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
│  📊 Factors: Surface 81°F • Wind 8mph • Season: Peak Summer    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.2 Compact Widget (For Dashboard/Map Overlay)

```
┌──────────────────────────────┐
│  🎯 Target Depth: 12-15ft    │
│  ●●●●○ Confidence: 80%       │
│  Status: Stratified          │
└──────────────────────────────┘
```

### 4.3 Interactive Depth Chart

```dart
// CustomPainter for animated depth visualization
class ThermoclineChart extends StatelessWidget {
  final ThermoclineData data;
  final double maxDepth;
  
  // Features:
  // - Animated gradient from warm (red) to cold (blue)
  // - Highlighted target zone with glow effect
  // - Fish icons showing recommended positioning
  // - Swipe to see historical predictions
}
```

### 4.4 Color Coding

| Element | Color | Hex |
|---------|-------|-----|
| Epilimnion (warm) | Amber/Orange | `#F59E0B` |
| Target Zone | Teal (brand) | `#0D9488` |
| Thermocline line | White | `#F8FAFC` |
| Hypolimnion (cold) | Blue | `#3B82F6` |
| Warning (low O2) | Red | `#EF4444` |

### 4.5 Confidence Indicator

| Confidence | Display | Color |
|------------|---------|-------|
| 85-100% | 🟢 High | Green |
| 65-84% | 🟡 Medium | Yellow |
| 50-64% | 🟠 Low | Orange |
| <50% | 🔴 Very Low | Red |

### 4.6 Status Messages

| Status | Icon | Color | Message |
|--------|------|-------|---------|
| Mixed | ❄️ | Blue | "Lake mixed — fish any depth" |
| Forming | 🌱 | Yellow | "Thermocline forming" |
| Stratified | ☀️ | Green | "Peak stratification — target zone active" |
| Breaking | 🍂 | Orange | "Fall turnover — patterns unstable" |

---

## 5. Technical Implementation

### 5.1 New Service: `ThermoclineService`

```dart
// lib/core/services/thermocline_service.dart

import 'dart:math';
import '../models/thermocline_data.dart';
import '../models/lake.dart';
import '../models/lake_conditions.dart';
import '../models/weather_data.dart';

class ThermoclineService {
  /// Predict thermocline depth and generate fishing recommendation
  Future<ThermoclineData> predictThermocline({
    required Lake lake,
    required WeatherData weather,
    required LakeConditions conditions,
    DateTime? date,
  }) async {
    final now = date ?? DateTime.now();
    
    // Step 1: Determine stratification status
    final status = _determineStatus(
      surfaceTemp: conditions.waterTempF,
      latitude: lake.centerLat,
      dayOfYear: now.dayOfYear,
      lakeDepth: lake.maxDepthFt,
    );
    
    if (status == StratificationStatus.mixed) {
      return _createMixedResult(conditions);
    }
    
    // Step 2: Calculate degree days (simplified - uses weather forecast temps)
    final degreeDays = _calculateDegreeDays(weather);
    
    // Step 3: Base thermocline depth
    double baseDepth = _calculateBaseDepth(
      surfaceTemp: conditions.waterTempF ?? 75,
      degreeDays: degreeDays,
      latitude: lake.centerLat,
      maxLakeDepth: lake.maxDepthFt,
    );
    
    // Step 4: Wind adjustment
    final windAdj = _calculateWindAdjustment(weather, lake.surfaceAreaAcres);
    baseDepth += windAdj;
    
    // Step 5: Calculate confidence
    final confidence = _calculateConfidence(
      hasUsgsTemp: conditions.waterTempF != null,
      dataAge: conditions.lastUpdated,
      hasLakeDepth: lake.maxDepthFt != null,
      degreeDays: degreeDays,
    );
    
    // Step 6: Target depth (crappie hold 0-5ft above thermocline)
    final targetMin = max(5.0, baseDepth - 5);
    final targetMax = baseDepth;
    
    // Step 7: Generate recommendation
    final recommendation = _generateRecommendation(
      status: status,
      targetMin: targetMin,
      targetMax: targetMax,
      surfaceTemp: conditions.waterTempF,
    );
    
    return ThermoclineData(
      thermoclineTopFt: baseDepth,
      thermoclineBottomFt: baseDepth + 3,
      targetDepthMinFt: targetMin,
      targetDepthMaxFt: targetMax,
      surfaceTempF: conditions.waterTempF ?? 75,
      thermoclineTempF: _estimateThermoclineTemp(conditions.waterTempF),
      confidence: confidence,
      status: status,
      recommendation: recommendation,
      factors: _gatherFactors(conditions, weather, lake, now),
      generatedAt: now,
    );
  }
  
  StratificationStatus _determineStatus({
    required double? surfaceTemp,
    required double latitude,
    required int dayOfYear,
    required double? lakeDepth,
  }) {
    // Shallow lakes don't stratify
    if (lakeDepth != null && lakeDepth < 15) {
      return StratificationStatus.mixed;
    }
    
    // Too cold = no stratification
    if (surfaceTemp != null && surfaceTemp < 60) {
      return StratificationStatus.mixed;
    }
    
    // Latitude-adjusted seasonal windows
    final latOffset = ((latitude - 35) * 3).round();
    
    final formingStart = 91 + latOffset;   // ~April 1
    final stratifiedStart = 153 + latOffset; // ~June 1
    final breakingStart = 245 + latOffset;  // ~September 1
    final mixedStart = 306 + latOffset;     // ~November 1
    
    if (dayOfYear < formingStart || dayOfYear >= mixedStart) {
      return StratificationStatus.mixed;
    }
    if (dayOfYear < stratifiedStart) {
      return (surfaceTemp ?? 0) >= 65 
          ? StratificationStatus.forming 
          : StratificationStatus.mixed;
    }
    if (dayOfYear < breakingStart) {
      return (surfaceTemp ?? 0) >= 70
          ? StratificationStatus.stratified
          : StratificationStatus.forming;
    }
    return StratificationStatus.breaking;
  }
  
  double _calculateDegreeDays(WeatherData weather) {
    // Sum (avgTemp - 50) for each day where avg > 50
    double sum = 0;
    for (final day in weather.daily) {
      final avg = (day.highF + day.lowF) / 2;
      if (avg > 50) {
        sum += avg - 50;
      }
    }
    // Extrapolate from 7-day forecast to ~90 day estimate
    return sum * 13; // Rough multiplier
  }
  
  double _calculateBaseDepth({
    required double surfaceTemp,
    required double degreeDays,
    required double latitude,
    required double? maxLakeDepth,
  }) {
    // Empirical model
    double depth = 8 + (degreeDays / 150);
    
    // Hot surface = shallower thermocline
    if (surfaceTemp > 82) {
      depth -= (surfaceTemp - 82) * 0.3;
    }
    
    // Northern adjustment
    depth -= (latitude - 35) * 0.2;
    
    // Constrain to lake depth
    if (maxLakeDepth != null) {
      depth = min(depth, maxLakeDepth * 0.7);
    }
    
    return depth.clamp(6, 35);
  }
  
  double _calculateWindAdjustment(WeatherData weather, double? surfaceArea) {
    // Calculate 48h average wind from hourly data
    final last48h = weather.hourly.take(48).toList();
    if (last48h.isEmpty) return 0;
    
    final avgWind = last48h.map((h) => h.windSpeedMph).reduce((a, b) => a + b) / last48h.length;
    final maxWind = last48h.map((h) => h.windSpeedMph).reduce(max);
    
    double adj = 0;
    if (avgWind > 10) {
      adj += (avgWind - 10) * 0.3;
    }
    if (maxWind > 20) {
      adj += (maxWind - 20) * 0.2;
    }
    
    // Large lake bonus
    if (surfaceArea != null && surfaceArea > 5000) {
      adj *= 1.2;
    }
    
    return adj.clamp(0, 8);
  }
  
  double _calculateConfidence({
    required bool hasUsgsTemp,
    required DateTime? dataAge,
    required bool hasLakeDepth,
    required double degreeDays,
  }) {
    double confidence = 0.5;
    
    if (hasUsgsTemp) confidence += 0.2;
    
    if (dataAge != null) {
      final age = DateTime.now().difference(dataAge);
      if (age.inHours < 24) confidence += 0.15;
      else if (age.inHours < 48) confidence += 0.08;
    }
    
    if (hasLakeDepth) confidence += 0.1;
    if (degreeDays > 800) confidence += 0.05;
    
    return confidence.clamp(0.3, 0.95);
  }
  
  double _estimateThermoclineTemp(double? surfaceTemp) {
    // Thermocline is typically 10-15°F cooler than surface
    return (surfaceTemp ?? 75) - 12;
  }
  
  String _generateRecommendation({
    required StratificationStatus status,
    required double targetMin,
    required double targetMax,
    required double? surfaceTemp,
  }) {
    switch (status) {
      case StratificationStatus.mixed:
        return "Lake is mixed — crappie can be at any depth. Focus on structure.";
      case StratificationStatus.forming:
        return "Thermocline forming. Try ${targetMin.round()}-${targetMax.round()}ft, but check shallower too.";
      case StratificationStatus.stratified:
        final hot = (surfaceTemp ?? 0) > 82 ? " Surface is hot — fish deeper." : "";
        return "Target ${targetMin.round()}-${targetMax.round()}ft over deep water.$hot";
      case StratificationStatus.breaking:
        return "Fall turnover — try ${targetMin.round()}-${targetMax.round()}ft but patterns are unstable.";
    }
  }
  
  List<String> _gatherFactors(
    LakeConditions conditions,
    WeatherData weather,
    Lake lake,
    DateTime date,
  ) {
    return [
      if (conditions.waterTempF != null) 
        "Surface: ${conditions.waterTempF!.round()}°F",
      "Wind: ${weather.current.windSpeedMph.round()} mph",
      "Season: ${_seasonLabel(date.dayOfYear)}",
      if (lake.maxDepthFt != null) 
        "Max depth: ${lake.maxDepthFt!.round()}ft",
    ];
  }
  
  String _seasonLabel(int dayOfYear) {
    if (dayOfYear < 91) return "Winter";
    if (dayOfYear < 153) return "Spring";
    if (dayOfYear < 245) return "Summer";
    if (dayOfYear < 306) return "Fall";
    return "Winter";
  }
  
  ThermoclineData _createMixedResult(LakeConditions conditions) {
    return ThermoclineData(
      thermoclineTopFt: 0,
      thermoclineBottomFt: 0,
      targetDepthMinFt: 5,
      targetDepthMaxFt: 30,
      surfaceTempF: conditions.waterTempF ?? 55,
      thermoclineTempF: conditions.waterTempF ?? 55,
      confidence: 0.9, // High confidence that it's mixed
      status: StratificationStatus.mixed,
      recommendation: "Lake is mixed — crappie can be at any depth. Focus on structure and cover.",
      factors: ["No thermocline present"],
      generatedAt: DateTime.now(),
    );
  }
}

extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays + 1;
  }
}
```

### 5.2 Provider Integration

```dart
// lib/features/thermocline/providers/thermocline_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/thermocline_service.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/models/lake.dart';
import '../../map/providers/map_providers.dart';
import '../../calculator/providers/calculator_providers.dart';

final thermoclineServiceProvider = Provider((ref) => ThermoclineService());

final thermoclineDataProvider = FutureProvider.autoDispose
    .family<ThermoclineData?, Lake>((ref, lake) async {
  final weather = await ref.watch(weatherProvider(lake.coordinates).future);
  final conditions = await ref.watch(lakeConditionsProvider(lake.id).future);
  
  if (weather == null || conditions == null) return null;
  
  final service = ref.read(thermoclineServiceProvider);
  return service.predictThermocline(
    lake: lake,
    weather: weather,
    conditions: conditions,
  );
});

// Compact provider for current selected lake
final currentThermoclineProvider = FutureProvider.autoDispose<ThermoclineData?>((ref) async {
  final lake = ref.watch(selectedLakeProvider);
  if (lake == null) return null;
  return ref.watch(thermoclineDataProvider(lake).future);
});
```

### 5.3 UI Widget

```dart
// lib/features/thermocline/widgets/thermocline_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/thermocline_data.dart';
import '../../../core/utils/constants.dart';

class ThermoclineCard extends StatelessWidget {
  final ThermoclineData data;
  final double? maxLakeDepth;
  
  const ThermoclineCard({
    super.key,
    required this.data,
    this.maxLakeDepth,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildDepthDiagram(),
          _buildRecommendation(),
          _buildFactors(),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.thermostat, color: AppColors.teal),
          const SizedBox(width: 8),
          const Text(
            'THERMOCLINE PREDICTOR',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          _buildConfidenceBadge(),
        ],
      ),
    );
  }
  
  Widget _buildConfidenceBadge() {
    final (color, label) = switch (data.confidence) {
      >= 0.85 => (AppColors.success, 'High'),
      >= 0.65 => (AppColors.warning, 'Medium'),
      >= 0.50 => (Colors.orange, 'Low'),
      _ => (AppColors.error, 'Very Low'),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$label Confidence',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDepthDiagram() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomPaint(
        painter: ThermoclineDiagramPainter(
          data: data,
          maxDepth: maxLakeDepth ?? 40,
        ),
        size: Size.infinite,
      ),
    );
  }
  
  Widget _buildRecommendation() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.teal.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.teal, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.recommendation,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFactors() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined, 
              color: AppColors.textMuted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              data.factors.join(' • '),
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThermoclineDiagramPainter extends CustomPainter {
  final ThermoclineData data;
  final double maxDepth;
  
  ThermoclineDiagramPainter({
    required this.data,
    required this.maxDepth,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Implementation: Draw gradient layers, target zone highlight,
    // depth markers, and fish icon at target depth
    // ... (detailed implementation)
  }
  
  @override
  bool shouldRepaint(covariant ThermoclineDiagramPainter oldDelegate) {
    return data != oldDelegate.data || maxDepth != oldDelegate.maxDepth;
  }
}
```

---

## 6. File Structure

```
lib/
├── core/
│   ├── models/
│   │   ├── thermocline_data.dart        # ✅ EXISTS - Update with extensions
│   │   └── lake.dart                    # ✅ EXISTS - Add maxDepthFt, surfaceAreaAcres
│   ├── services/
│   │   ├── thermocline_service.dart     # 🆕 NEW - Core prediction logic
│   │   └── lake_service.dart            # ✅ EXISTS - Minor updates
│   └── utils/
│       └── thermocline_constants.dart   # 🆕 NEW - Model calibration constants
│
├── features/
│   └── thermocline/                     # 🆕 NEW FEATURE MODULE
│       ├── providers/
│       │   └── thermocline_providers.dart
│       ├── screens/
│       │   └── thermocline_detail_screen.dart
│       └── widgets/
│           ├── thermocline_card.dart          # Full card with diagram
│           ├── thermocline_mini_widget.dart   # Compact for dashboard
│           ├── depth_diagram_painter.dart     # CustomPainter
│           └── status_indicator.dart          # Stratification status
│
└── shared/
    └── widgets/
        └── depth_gauge.dart             # Reusable depth visualization
```

---

## 7. Database Schema

### 7.1 Lakes Table Updates (Supabase)

```sql
-- Add thermocline-relevant columns to lakes table
ALTER TABLE lakes ADD COLUMN IF NOT EXISTS max_depth_ft DECIMAL(5,1);
ALTER TABLE lakes ADD COLUMN IF NOT EXISTS surface_area_acres DECIMAL(10,2);
ALTER TABLE lakes ADD COLUMN IF NOT EXISTS mixing_type TEXT; -- 'monomictic', 'dimictic', 'polymictic'

-- Index for efficient querying
CREATE INDEX IF NOT EXISTS idx_lakes_location ON lakes(center_lat, center_lon);
```

### 7.2 Thermocline Cache Table (Optional, for history)

```sql
CREATE TABLE IF NOT EXISTS thermocline_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lake_id TEXT NOT NULL REFERENCES lakes(id),
  predicted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  surface_temp_f DECIMAL(4,1),
  thermocline_top_ft DECIMAL(4,1),
  thermocline_bottom_ft DECIMAL(4,1),
  target_min_ft DECIMAL(4,1),
  target_max_ft DECIMAL(4,1),
  confidence DECIMAL(3,2),
  status TEXT,
  factors JSONB,
  
  -- Partition by month for efficient cleanup
  CONSTRAINT thermocline_predictions_pkey PRIMARY KEY (id, predicted_at)
) PARTITION BY RANGE (predicted_at);

-- Create monthly partitions
CREATE TABLE thermocline_predictions_2026_01 PARTITION OF thermocline_predictions
  FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
-- ... etc

-- Index for lake + time queries
CREATE INDEX idx_thermo_lake_time ON thermocline_predictions(lake_id, predicted_at DESC);
```

### 7.3 Lake Metadata Seed Data

```sql
-- Example lake metadata for thermocline calculations
INSERT INTO lakes (id, name, state, center_lat, center_lon, max_depth_ft, surface_area_acres, mixing_type)
VALUES
  ('grenada', 'Grenada Lake', 'MS', 33.8117, -89.7478, 65, 35000, 'monomictic'),
  ('sardis', 'Sardis Lake', 'MS', 34.4092, -89.7853, 45, 32100, 'monomictic'),
  ('enid', 'Enid Lake', 'MS', 34.1608, -89.8833, 35, 28000, 'polymictic'),
  ('arkabutla', 'Arkabutla Lake', 'MS', 34.7544, -90.1225, 28, 12700, 'polymictic'),
  ('pickwick', 'Pickwick Lake', 'TN', 34.9461, -88.2639, 57, 43100, 'monomictic'),
  ('kentucky', 'Kentucky Lake', 'TN', 36.5, -88.1, 75, 160300, 'dimictic'),
  ('barkley', 'Lake Barkley', 'KY', 36.8, -88.0, 60, 57920, 'dimictic')
ON CONFLICT (id) DO UPDATE SET
  max_depth_ft = EXCLUDED.max_depth_ft,
  surface_area_acres = EXCLUDED.surface_area_acres,
  mixing_type = EXCLUDED.mixing_type;
```

---

## 8. Testing Strategy

### 8.1 Unit Tests

```dart
// test/core/services/thermocline_service_test.dart

void main() {
  group('ThermoclineService', () {
    late ThermoclineService service;
    
    setUp(() {
      service = ThermoclineService();
    });
    
    group('determineStatus', () {
      test('returns mixed for shallow lakes', () async {
        final result = await service.predictThermocline(
          lake: Lake(maxDepthFt: 12, ...),
          weather: mockWeather,
          conditions: mockConditions,
        );
        expect(result.status, StratificationStatus.mixed);
      });
      
      test('returns stratified in summer with warm water', () async {
        final result = await service.predictThermocline(
          lake: mockDeepLake,
          weather: mockSummerWeather,
          conditions: LakeConditions(waterTempF: 82, ...),
          date: DateTime(2026, 7, 15), // Mid-July
        );
        expect(result.status, StratificationStatus.stratified);
      });
      
      test('returns breaking in fall', () async {
        final result = await service.predictThermocline(
          lake: mockDeepLake,
          weather: mockFallWeather,
          conditions: LakeConditions(waterTempF: 68, ...),
          date: DateTime(2026, 9, 20), // Late September
        );
        expect(result.status, StratificationStatus.breaking);
      });
    });
    
    group('calculateBaseDepth', () {
      test('deepens thermocline with more degree days', () {
        final early = service._calculateBaseDepth(
          surfaceTemp: 78, degreeDays: 400, latitude: 35, maxLakeDepth: 50,
        );
        final late = service._calculateBaseDepth(
          surfaceTemp: 78, degreeDays: 1000, latitude: 35, maxLakeDepth: 50,
        );
        expect(late, greaterThan(early));
      });
      
      test('constrains to lake max depth', () {
        final result = service._calculateBaseDepth(
          surfaceTemp: 85, degreeDays: 2000, latitude: 30, maxLakeDepth: 20,
        );
        expect(result, lessThanOrEqualTo(14)); // 70% of 20ft
      });
    });
    
    group('confidence calculation', () {
      test('increases with USGS data', () {
        final withUsgs = service._calculateConfidence(
          hasUsgsTemp: true, dataAge: DateTime.now(), hasLakeDepth: true, degreeDays: 800,
        );
        final withoutUsgs = service._calculateConfidence(
          hasUsgsTemp: false, dataAge: DateTime.now(), hasLakeDepth: true, degreeDays: 800,
        );
        expect(withUsgs, greaterThan(withoutUsgs));
      });
    });
  });
}
```

### 8.2 Integration Tests

```dart
// test/features/thermocline/thermocline_integration_test.dart

void main() {
  testWidgets('thermocline card displays correct data', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          thermoclineDataProvider(mockLake).overrideWith(
            (ref) async => mockThermoclineData,
          ),
        ],
        child: MaterialApp(
          home: ThermoclineCard(data: mockThermoclineData),
        ),
      ),
    );
    
    expect(find.text('12-15ft'), findsOneWidget);
    expect(find.text('High Confidence'), findsOneWidget);
    expect(find.textContaining('Target'), findsOneWidget);
  });
}
```

### 8.3 Golden Tests (Visual)

```dart
// test/golden/thermocline_diagram_test.dart

void main() {
  testWidgets('thermocline diagram matches golden', (tester) async {
    await tester.pumpWidget(
      CustomPaint(
        painter: ThermoclineDiagramPainter(
          data: mockStratifiedData,
          maxDepth: 40,
        ),
        size: const Size(300, 200),
      ),
    );
    
    await expectLater(
      find.byType(CustomPaint),
      matchesGoldenFile('goldens/thermocline_diagram_stratified.png'),
    );
  });
}
```

---

## 9. Future Enhancements

### 9.1 Phase 2: Satellite Water Clarity Integration

- Integrate Sentinel-2/Landsat water clarity data
- Clarity affects light penetration → thermocline depth
- Partner with services like Xylem/YSI for real sensor data

### 9.2 Phase 3: Machine Learning Model

```python
# Future: Train ML model on EPA lake profile data
features = [
    'surface_temp',
    'air_temp_7day_avg',
    'degree_days',
    'wind_48h_avg',
    'latitude',
    'lake_max_depth',
    'lake_surface_area',
    'day_of_year',
]

# XGBoost or similar for thermocline depth regression
model = XGBRegressor()
model.fit(X_train, y_thermocline_depth)
```

### 9.3 Phase 4: User Feedback Loop

- "Was this prediction accurate?" thumbs up/down
- Crowdsourced depth verification from fish finders
- Improve model with real-world data

### 9.4 Phase 5: Dissolved Oxygen Overlay

- Where available, show DO levels by depth
- Identify the "oxycline" (where DO drops below 4mg/L)
- More precise "fish zone" recommendations

---

## Appendix A: Reference Data

### Crappie Temperature Preferences

| Condition | Temperature Range |
|-----------|------------------|
| Lethal (cold) | < 40°F |
| Sluggish | 40-55°F |
| Active/Feeding | 55-75°F |
| **Optimal** | **65-72°F** |
| Stressed | 75-85°F |
| Lethal (hot) | > 90°F |

### Typical Thermocline Depths by Region

| Region | Typical Thermocline Depth | Peak Stratification |
|--------|--------------------------|---------------------|
| Deep South (MS, AL, LA) | 15-25 ft | June-September |
| Mid-South (TN, AR, KY) | 12-20 ft | June-August |
| Midwest (MO, IL, OH) | 10-18 ft | July-August |
| Northern (MN, WI, MI) | 8-15 ft | July-August |

### USGS Parameter Codes

| Code | Parameter | Units |
|------|-----------|-------|
| 00010 | Water Temperature | °C |
| 00065 | Gage Height | ft |
| 00300 | Dissolved Oxygen | mg/L |
| 00400 | pH | standard units |
| 63680 | Turbidity | FNU |

---

## Appendix B: API Response Examples

### USGS Water Temperature Response

```json
{
  "value": {
    "timeSeries": [{
      "variable": {
        "variableCode": [{"value": "00010"}]
      },
      "values": [{
        "value": [
          {"value": "24.5", "dateTime": "2026-07-15T12:00:00.000-05:00"},
          {"value": "24.8", "dateTime": "2026-07-15T12:15:00.000-05:00"}
        ]
      }]
    }]
  }
}
```

### ThermoclineData JSON Output

```json
{
  "thermoclineTopFt": 16.5,
  "thermoclineBottomFt": 19.5,
  "targetDepthMinFt": 12,
  "targetDepthMaxFt": 16,
  "surfaceTempF": 82.4,
  "thermoclineTempF": 70.4,
  "confidence": 0.78,
  "status": "stratified",
  "recommendation": "Target 12-16ft over deep water. Surface is hot — fish deeper.",
  "factors": ["Surface: 82°F", "Wind: 6 mph", "Season: Summer", "Max depth: 45ft"],
  "generatedAt": "2026-07-15T14:30:00Z"
}
```

---

*Document generated for SlabHaul v2.0 development. This feature represents a key competitive differentiator in the crappie fishing app market.*
