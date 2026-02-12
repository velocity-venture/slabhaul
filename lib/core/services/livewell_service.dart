// Livewell Evaluation Service
//
// Scores livewell conditions against crappie survival thresholds and
// generates actionable alerts. Based on tournament livewell best practices
// and crappie-specific thermal tolerance data.

import '../models/livewell.dart';

// ---------------------------------------------------------------------------
// Crappie Livewell Thresholds
// ---------------------------------------------------------------------------

/// Water temperature thresholds for crappie survival
class _TempThresholds {
  /// Crappie begin showing stress signs above this water temp
  static const double stressF = 80.0;

  /// Lethal range for sustained exposure
  static const double lethalF = 85.0;

  /// Comfortable upper range for crappie
  static const double comfortMaxF = 78.0;

  /// Air-to-water differential that causes rapid livewell heating
  static const double dangerousDiffF = 10.0;

  /// Air temp where ice recommendation kicks in
  static const double iceRecommendAirF = 85.0;

  /// Water temp approaching stress where ice should be considered
  static const double iceRecommendWaterF = 78.0;
}

/// Stocking density thresholds (gallons per fish)
class _DensityThresholds {
  /// Recommended minimum: 1 fish per 3 gallons
  static const double safeGallonsPerFish = 3.0;

  /// Caution zone: getting crowded
  static const double cautionGallonsPerFish = 2.0;

  /// Danger zone: critically overcrowded
  static const double dangerGallonsPerFish = 1.0;
}

// ---------------------------------------------------------------------------
// Scoring Constants
// ---------------------------------------------------------------------------

/// Risk points assigned per factor. Total determines final status.
class _RiskPoints {
  // Temperature risks
  static const int waterTempLethal = 50;
  static const int waterTempStress = 25;
  static const int waterTempWarm = 10;
  static const int airWaterDiffHigh = 15;
  static const int airWaterDiffModerate = 8;

  // Density risks
  static const int densityDanger = 40;
  static const int densityCaution = 15;
  static const int densityModerate = 5;

  // Equipment mitigations (negative = reduces risk)
  static const int aeratorReduction = -15;
  static const int recirculatorReduction = -10;
  static const int insulatedReduction = -8;

  // Status thresholds (cumulative risk score)
  static const int cautionThreshold = 15;
  static const int dangerThreshold = 35;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Evaluates livewell conditions and produces alerts with recommendations
/// tuned for crappie survival during warm-weather fishing.
class LivewellService {
  /// Evaluate current livewell conditions and return an alert.
  ///
  /// The algorithm scores individual risk factors (temperature, density,
  /// equipment) then combines them into a composite risk score that maps
  /// to [LivewellStatus.safe], [LivewellStatus.caution], or
  /// [LivewellStatus.danger].
  LivewellAlert evaluate(LivewellConditions conditions) {
    int riskScore = 0;
    final issues = <String>[];
    final recommendations = <String>[];

    // --- Temperature evaluation ---
    riskScore += _evaluateTemperature(conditions, issues, recommendations);

    // --- Stocking density evaluation ---
    riskScore += _evaluateDensity(conditions, issues, recommendations);

    // --- Equipment mitigations ---
    riskScore += _evaluateEquipment(conditions, issues, recommendations);

    // --- Ice recommendation ---
    _evaluateIceNeed(conditions, recommendations);

    // Clamp risk score to zero minimum (equipment can reduce below zero)
    if (riskScore < 0) riskScore = 0;

    // --- Determine final status ---
    final LivewellStatus status;
    if (riskScore >= _RiskPoints.dangerThreshold) {
      status = LivewellStatus.danger;
    } else if (riskScore >= _RiskPoints.cautionThreshold) {
      status = LivewellStatus.caution;
    } else {
      status = LivewellStatus.safe;
    }

    // Build human-readable message
    final message = issues.isEmpty
        ? 'Livewell conditions look good for crappie.'
        : issues.join(' ');

    // Build recommendation string
    final recommendation = recommendations.isEmpty
        ? 'No action needed. Keep monitoring conditions.'
        : recommendations.join(' ');

    return LivewellAlert(
      status: status,
      message: message,
      recommendation: recommendation,
      timestamp: DateTime.now(),
    );
  }

  /// Score temperature-related risks
  int _evaluateTemperature(
    LivewellConditions c,
    List<String> issues,
    List<String> recs,
  ) {
    int score = 0;

    // Water temperature
    if (c.waterTempF >= _TempThresholds.lethalF) {
      score += _RiskPoints.waterTempLethal;
      issues.add(
        'Water temp ${c.waterTempF.round()}F is in the lethal range for crappie.',
      );
      recs.add(
        'Immediately add bagged ice and consider releasing fish.',
      );
    } else if (c.waterTempF >= _TempThresholds.stressF) {
      score += _RiskPoints.waterTempStress;
      issues.add(
        'Water temp ${c.waterTempF.round()}F is causing crappie stress.',
      );
      recs.add(
        'Add bagged ice to bring livewell temp below 80F.',
      );
    } else if (c.waterTempF >= _TempThresholds.comfortMaxF) {
      score += _RiskPoints.waterTempWarm;
      issues.add(
        'Water temp ${c.waterTempF.round()}F is approaching the stress zone.',
      );
    }

    // Air-to-water temperature differential (livewell heating rate)
    final diff = c.tempDifferentialF;
    if (diff >= _TempThresholds.dangerousDiffF) {
      score += _RiskPoints.airWaterDiffHigh;
      issues.add(
        'Air is ${diff.round()}F warmer than water — livewell will heat up fast.',
      );
      if (!c.hasRecirculator && !c.isInsulated) {
        recs.add(
          'Use a recirculating pump or insulated livewell to slow heating.',
        );
      }
    } else if (diff >= _TempThresholds.dangerousDiffF * 0.6) {
      score += _RiskPoints.airWaterDiffModerate;
      issues.add(
        'Air is ${diff.round()}F warmer than water — monitor livewell temp.',
      );
    }

    return score;
  }

  /// Score stocking density risks
  int _evaluateDensity(
    LivewellConditions c,
    List<String> issues,
    List<String> recs,
  ) {
    if (c.fishCount == 0) return 0;

    int score = 0;
    final gallonsPerFish = c.gallonsPerFish;

    if (gallonsPerFish < _DensityThresholds.dangerGallonsPerFish) {
      score += _RiskPoints.densityDanger;
      issues.add(
        'Severely overcrowded: ${c.fishCount} fish in '
        '${c.livewellSizeGallons.round()} gallons '
        '(${gallonsPerFish.toStringAsFixed(1)} gal/fish).',
      );
      recs.add(
        'Release some fish immediately. Crappie need at least 3 gallons each.',
      );
    } else if (gallonsPerFish < _DensityThresholds.cautionGallonsPerFish) {
      score += _RiskPoints.densityCaution;
      issues.add(
        'Getting crowded: ${c.fishCount} fish in '
        '${c.livewellSizeGallons.round()} gallons '
        '(${gallonsPerFish.toStringAsFixed(1)} gal/fish).',
      );
      recs.add(
        'Limit is approaching. Cull or release to maintain 3 gallons per fish.',
      );
    } else if (gallonsPerFish < _DensityThresholds.safeGallonsPerFish) {
      score += _RiskPoints.densityModerate;
      issues.add(
        '${c.fishCount} fish in ${c.livewellSizeGallons.round()} gallons — '
        'room is limited.',
      );
    }

    return score;
  }

  /// Score equipment mitigations (reduce risk)
  int _evaluateEquipment(
    LivewellConditions c,
    List<String> issues,
    List<String> recs,
  ) {
    int score = 0;

    if (c.hasAerator) {
      score += _RiskPoints.aeratorReduction;
    } else {
      // No aerator is only a problem when fish are present
      if (c.fishCount > 0) {
        issues.add('No aerator detected.');
        recs.add(
          'Turn on the aerator — dissolved oxygen drops fast without aeration.',
        );
      }
    }

    if (c.hasRecirculator) {
      score += _RiskPoints.recirculatorReduction;
    }

    if (c.isInsulated) {
      score += _RiskPoints.insulatedReduction;
    }

    return score;
  }

  /// Add ice recommendation when thermal conditions warrant it
  void _evaluateIceNeed(
    LivewellConditions c,
    List<String> recs,
  ) {
    final needsIce = c.airTempF >= _TempThresholds.iceRecommendAirF ||
        c.waterTempF >= _TempThresholds.iceRecommendWaterF;

    if (needsIce) {
      // Only add if we haven't already recommended ice above
      final alreadyRecommended = recs.any((r) => r.contains('ice'));
      if (!alreadyRecommended) {
        recs.add(
          'Consider adding ice in a sealed bag to gradually cool the livewell. '
          'Never dump loose ice directly — rapid temperature swings cause thermal shock.',
        );
      }
    }
  }
}
