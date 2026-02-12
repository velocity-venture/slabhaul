import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Enums
// ---------------------------------------------------------------------------

/// Primary crappie fishing techniques
enum CrappieTechnique {
  spiderRigging,
  verticalJigging,
  dockShooting,
  slipBobber,
  longLineTrolling,
  tightLining,
}

extension CrappieTechniqueX on CrappieTechnique {
  String get displayName {
    switch (this) {
      case CrappieTechnique.spiderRigging:
        return 'Spider Rigging';
      case CrappieTechnique.verticalJigging:
        return 'Vertical Jigging';
      case CrappieTechnique.dockShooting:
        return 'Dock Shooting';
      case CrappieTechnique.slipBobber:
        return 'Slip Bobber';
      case CrappieTechnique.longLineTrolling:
        return 'Long-Line Trolling';
      case CrappieTechnique.tightLining:
        return 'Tight-Lining';
    }
  }
}

// ---------------------------------------------------------------------------
// Data Models
// ---------------------------------------------------------------------------

/// Profile describing a crappie fishing technique and its ideal conditions
class TechniqueProfile {
  final CrappieTechnique technique;
  final String displayName;
  final String description;
  final double optimalWindSpeedMaxMph;
  final double optimalDepthMin;
  final double optimalDepthMax;
  final double optimalTempMin;
  final double optimalTempMax;
  final List<String> bestClarityLevels;
  final List<String> bestSeasons;
  final bool requiresElectronics;
  final IconData icon;

  const TechniqueProfile({
    required this.technique,
    required this.displayName,
    required this.description,
    required this.optimalWindSpeedMaxMph,
    required this.optimalDepthMin,
    required this.optimalDepthMax,
    required this.optimalTempMin,
    required this.optimalTempMax,
    required this.bestClarityLevels,
    required this.bestSeasons,
    required this.requiresElectronics,
    required this.icon,
  });
}

/// A scored technique recommendation with reasoning and tips
class TechniqueRecommendation {
  final TechniqueProfile profile;
  final double score; // 0.0 - 1.0
  final List<String> reasons;
  final List<String> tips;

  const TechniqueRecommendation({
    required this.profile,
    required this.score,
    required this.reasons,
    required this.tips,
  });
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Crappie Technique Recommendation Engine
///
/// Conditions-based technique selection algorithm that weighs:
///
/// **Wind Speed:** Determines boat control and presentation viability.
/// Spider rigging and slip bobber need calm; trolling handles chop.
///
/// **Water Temperature:** Cold water favors vertical/tight-lining finesse.
/// Warm water opens up trolling and dock shooting.
///
/// **Depth:** Shallow = bobbers and dock shooting. Deep = vertical and spider.
///
/// **Water Clarity:** Stained/muddy favors dock shooting. Clear favors vertical.
///
/// **Barometric Trend:** Falling = aggressive techniques. Stable/rising = finesse.
///
/// **Season:** Schooling patterns in fall-spring favor spider rigs.
/// Post-spawn through fall favors trolling to cover water.
class TechniqueRecommendationService {
  // ---------------------------------------------------------------------------
  // Technique Database
  // ---------------------------------------------------------------------------

  static const List<TechniqueProfile> _techniqueDatabase = [
    TechniqueProfile(
      technique: CrappieTechnique.spiderRigging,
      displayName: 'Spider Rigging',
      description: 'Multiple rods fanned out from the bow, slow-trolling jigs '
          'or minnows over brush piles and channels. The ultimate crappie '
          'search-and-catch technique for covering structure methodically.',
      optimalWindSpeedMaxMph: 12,
      optimalDepthMin: 8,
      optimalDepthMax: 25,
      optimalTempMin: 38,
      optimalTempMax: 80,
      bestClarityLevels: ['clear', 'stained', 'muddy'],
      bestSeasons: ['winter', 'pre-spawn', 'fall', 'spring'],
      requiresElectronics: true,
      icon: Icons.pest_control,
    ),
    TechniqueProfile(
      technique: CrappieTechnique.verticalJigging,
      displayName: 'Vertical Jigging',
      description: 'Dropping a jig or spoon straight down to suspended or '
          'bottom-hugging crappie. Precise depth control with electronics. '
          'Deadly in cold water and deep summer thermocline situations.',
      optimalWindSpeedMaxMph: 8,
      optimalDepthMin: 15,
      optimalDepthMax: 35,
      optimalTempMin: 35,
      optimalTempMax: 85,
      bestClarityLevels: ['clear', 'stained'],
      bestSeasons: ['winter', 'summer'],
      requiresElectronics: true,
      icon: Icons.vertical_align_bottom,
    ),
    TechniqueProfile(
      technique: CrappieTechnique.dockShooting,
      displayName: 'Dock Shooting',
      description: 'Skipping jigs under boat docks by loading the rod tip and '
          'releasing. Reaches fish in heavy shade that other techniques cannot '
          'access. Highly effective in stained to muddy water.',
      optimalWindSpeedMaxMph: 15,
      optimalDepthMin: 2,
      optimalDepthMax: 12,
      optimalTempMin: 50,
      optimalTempMax: 78,
      bestClarityLevels: ['stained', 'muddy'],
      bestSeasons: ['spring', 'fall', 'post-spawn'],
      requiresElectronics: false,
      icon: Icons.home_work,
    ),
    TechniqueProfile(
      technique: CrappieTechnique.slipBobber,
      displayName: 'Slip Bobber',
      description: 'Suspending a jig or minnow at a precise depth under a '
          'slip float. Excellent for targeting brush pile tops and staging '
          'fish. Patient, finesse approach for pressured crappie.',
      optimalWindSpeedMaxMph: 8,
      optimalDepthMin: 4,
      optimalDepthMax: 15,
      optimalTempMin: 38,
      optimalTempMax: 75,
      bestClarityLevels: ['clear', 'stained'],
      bestSeasons: ['winter', 'pre-spawn', 'spring'],
      requiresElectronics: false,
      icon: Icons.sports_baseball,
    ),
    TechniqueProfile(
      technique: CrappieTechnique.longLineTrolling,
      displayName: 'Long-Line Trolling',
      description: 'Pulling crankbaits or jigs 50-100 feet behind the boat at '
          'controlled speed. Covers massive amounts of water to locate '
          'scattered, actively feeding crappie.',
      optimalWindSpeedMaxMph: 15,
      optimalDepthMin: 6,
      optimalDepthMax: 15,
      optimalTempMin: 55,
      optimalTempMax: 85,
      bestClarityLevels: ['clear', 'stained', 'muddy'],
      bestSeasons: ['post-spawn', 'summer', 'fall'],
      requiresElectronics: true,
      icon: Icons.directions_boat,
    ),
    TechniqueProfile(
      technique: CrappieTechnique.tightLining,
      displayName: 'Tight-Lining',
      description: 'Vertical presentation with a tight line and live minnow, '
          'feeling for subtle bites. Ultra-slow, finesse technique for '
          'cold-water crappie that refuse aggressive presentations.',
      optimalWindSpeedMaxMph: 8,
      optimalDepthMin: 10,
      optimalDepthMax: 30,
      optimalTempMin: 32,
      optimalTempMax: 55,
      bestClarityLevels: ['clear', 'stained', 'muddy'],
      bestSeasons: ['winter', 'early spring'],
      requiresElectronics: true,
      icon: Icons.straighten,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Generate technique recommendations based on current conditions.
  ///
  /// Returns the top 3 [TechniqueRecommendation] entries sorted by score.
  List<TechniqueRecommendation> recommend({
    required double waterTempF,
    required double windSpeedMph,
    required String waterClarity,
    required double depthFt,
    required String barometricTrend,
    required String timeOfDay,
    required String season,
    required int cloudCoverPercent,
  }) {
    final scored = <_ScoredTechnique>[];

    for (final profile in _techniqueDatabase) {
      final result = _scoreTechnique(
        profile: profile,
        waterTempF: waterTempF,
        windSpeedMph: windSpeedMph,
        waterClarity: waterClarity,
        depthFt: depthFt,
        barometricTrend: barometricTrend,
        timeOfDay: timeOfDay,
        season: season,
        cloudCoverPercent: cloudCoverPercent,
      );
      scored.add(result);
    }

    scored.sort((a, b) => b.score.compareTo(a.score));

    return scored.take(3).map((s) {
      return TechniqueRecommendation(
        profile: s.profile,
        score: s.score,
        reasons: s.reasons,
        tips: s.tips,
      );
    }).toList();
  }

  /// Get all available technique profiles
  List<TechniqueProfile> getAllTechniques() =>
      List.unmodifiable(_techniqueDatabase);

  // ---------------------------------------------------------------------------
  // Scoring Algorithm
  // ---------------------------------------------------------------------------

  _ScoredTechnique _scoreTechnique({
    required TechniqueProfile profile,
    required double waterTempF,
    required double windSpeedMph,
    required String waterClarity,
    required double depthFt,
    required String barometricTrend,
    required String timeOfDay,
    required String season,
    required int cloudCoverPercent,
  }) {
    double score = 0.5; // Baseline
    final reasons = <String>[];
    final tips = <String>[];

    switch (profile.technique) {
      case CrappieTechnique.spiderRigging:
        score = _scoreSpiderRigging(
          waterTempF: waterTempF,
          windSpeedMph: windSpeedMph,
          depthFt: depthFt,
          season: season,
          barometricTrend: barometricTrend,
          reasons: reasons,
          tips: tips,
        );
      case CrappieTechnique.verticalJigging:
        score = _scoreVerticalJigging(
          waterTempF: waterTempF,
          windSpeedMph: windSpeedMph,
          depthFt: depthFt,
          season: season,
          barometricTrend: barometricTrend,
          reasons: reasons,
          tips: tips,
        );
      case CrappieTechnique.dockShooting:
        score = _scoreDockShooting(
          waterTempF: waterTempF,
          waterClarity: waterClarity,
          season: season,
          cloudCoverPercent: cloudCoverPercent,
          reasons: reasons,
          tips: tips,
        );
      case CrappieTechnique.slipBobber:
        score = _scoreSlipBobber(
          waterTempF: waterTempF,
          windSpeedMph: windSpeedMph,
          depthFt: depthFt,
          season: season,
          timeOfDay: timeOfDay,
          reasons: reasons,
          tips: tips,
        );
      case CrappieTechnique.longLineTrolling:
        score = _scoreLongLineTrolling(
          waterTempF: waterTempF,
          windSpeedMph: windSpeedMph,
          depthFt: depthFt,
          season: season,
          barometricTrend: barometricTrend,
          reasons: reasons,
          tips: tips,
        );
      case CrappieTechnique.tightLining:
        score = _scoreTightLining(
          waterTempF: waterTempF,
          windSpeedMph: windSpeedMph,
          depthFt: depthFt,
          season: season,
          barometricTrend: barometricTrend,
          reasons: reasons,
          tips: tips,
        );
    }

    return _ScoredTechnique(
      profile: profile,
      score: score.clamp(0.0, 1.0),
      reasons: reasons,
      tips: tips,
    );
  }

  // ---------------------------------------------------------------------------
  // Per-Technique Scoring
  // ---------------------------------------------------------------------------

  double _scoreSpiderRigging({
    required double waterTempF,
    required double windSpeedMph,
    required double depthFt,
    required String season,
    required String barometricTrend,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.6;

    // Wind: best under 12 mph, penalize above
    if (windSpeedMph <= 12) {
      score += 0.15;
      reasons.add('Wind is manageable for multi-rod spider rig setup');
    } else {
      score -= 0.2 * ((windSpeedMph - 12) / 10).clamp(0.0, 1.0);
      reasons.add('High wind makes spider rigging difficult');
      tips.add('Use heavier jig heads (1/8-1/4 oz) to maintain contact');
    }

    // Depth: sweet spot 8-25 ft
    if (depthFt >= 8 && depthFt <= 25) {
      score += 0.15;
      reasons.add('Depth is ideal for spider rigging brush and channels');
    } else if (depthFt < 8) {
      score -= 0.15;
    } else {
      score -= 0.1;
    }

    // Season: higher in fall-spring when fish school tight
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'fall' ||
        seasonLower == 'winter' ||
        seasonLower == 'spring' ||
        seasonLower == 'pre-spawn') {
      score += 0.15;
      reasons.add('Fish are schooled tight during $season - perfect for spider rigging');
      tips.add('Fan rods at different depths to find the school\'s level');
    }

    // Barometric: falling pressure = active fish, good for searching
    if (barometricTrend.toLowerCase() == 'falling') {
      score += 0.05;
      tips.add('Falling pressure means active fish - cover water faster');
    }

    tips.add('Slow-troll at 0.3-0.5 mph over brush lines and channels');
    tips.add('Use your electronics to mark structure and stay on the fish');

    return score;
  }

  double _scoreVerticalJigging({
    required double waterTempF,
    required double windSpeedMph,
    required double depthFt,
    required String season,
    required String barometricTrend,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.45;

    // Wind: requires calm, under 8 mph
    if (windSpeedMph <= 8) {
      score += 0.15;
      reasons.add('Calm conditions allow precise vertical presentation');
    } else {
      score -= 0.25 * ((windSpeedMph - 8) / 10).clamp(0.0, 1.0);
      reasons.add('Wind makes it hard to stay vertical over fish');
      tips.add('Use a drift sock or anchor to maintain position');
    }

    // Depth: best 15-35 ft
    if (depthFt >= 15 && depthFt <= 35) {
      score += 0.15;
      reasons.add('Deep fish respond well to vertical presentations');
    } else if (depthFt < 15) {
      score -= 0.1;
    }

    // Cold water (<55F) or deep summer = electronics fish
    if (waterTempF < 55) {
      score += 0.2;
      reasons.add('Cold water crappie hold tight - vertical jigging is deadly');
      tips.add('Use a slow lift-drop cadence, 6-inch hops');
      tips.add('Watch your electronics - crappie will rise to the bait');
    } else if (waterTempF > 75 && depthFt >= 18) {
      score += 0.15;
      reasons.add('Summer fish suspend on the thermocline - drop right to them');
      tips.add('Find the thermocline on electronics and jig just above it');
    }

    // Season bonus for winter
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'winter') {
      score += 0.1;
      tips.add('Tip jig with a small minnow for extra scent in cold water');
    } else if (seasonLower == 'summer') {
      score += 0.05;
    }

    // Stable or rising pressure favors precise vertical work
    if (barometricTrend.toLowerCase() == 'stable' ||
        barometricTrend.toLowerCase() == 'steady') {
      score += 0.05;
    }

    return score;
  }

  double _scoreDockShooting({
    required double waterTempF,
    required String waterClarity,
    required String season,
    required int cloudCoverPercent,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.4;

    // Water clarity: best in stained/muddy
    final clarity = waterClarity.toLowerCase();
    if (clarity == 'stained' || clarity == 'muddy') {
      score += 0.2;
      reasons.add('Stained/muddy water pushes crappie under docks for shade');
    } else if (clarity == 'clear') {
      score += 0.05;
      tips.add('In clear water, target the darkest dock shadows');
    }

    // Temp: 50-78F sweet spot
    if (waterTempF >= 50 && waterTempF <= 78) {
      score += 0.15;
      reasons.add('Water temp is in the dock-shooting sweet spot');
    } else if (waterTempF < 50) {
      score -= 0.15;
      reasons.add('Cold water crappie are less likely to hold under docks');
    } else {
      score -= 0.05;
    }

    // Season: spring/fall
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'spring' ||
        seasonLower == 'pre-spawn' ||
        seasonLower == 'fall') {
      score += 0.1;
      reasons.add('$season crappie relate to dock structure');
    } else if (seasonLower == 'post-spawn') {
      score += 0.05;
    }

    // Cloud cover >50% bonus - fish tuck under shade structures more
    if (cloudCoverPercent > 50) {
      score += 0.1;
      reasons.add('Overcast skies improve dock shooting - fish feel secure');
      tips.add('Clouds reduce contrast, so try darker jig colors');
    }

    tips.add('Use a 1/16 oz jig with a 2" soft plastic minnow');
    tips.add('Skip the jig as far back under the dock as possible');
    tips.add('Let the bait pendulum-fall before starting a slow retrieve');

    return score;
  }

  double _scoreSlipBobber({
    required double waterTempF,
    required double windSpeedMph,
    required double depthFt,
    required String season,
    required String timeOfDay,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.5;

    // Wind: needs calm, under 8 mph
    if (windSpeedMph <= 8) {
      score += 0.15;
      reasons.add('Light wind allows the bobber to sit still over the target');
    } else {
      score -= 0.2 * ((windSpeedMph - 8) / 10).clamp(0.0, 1.0);
      tips.add('Use a larger bobber to combat wind drift');
    }

    // Depth: 4-15 ft sweet spot (brush pile tops, staging areas)
    if (depthFt >= 4 && depthFt <= 15) {
      score += 0.15;
      reasons.add('Perfect depth range for slip bobber presentations');
    } else if (depthFt < 4) {
      score -= 0.05;
    } else {
      score -= 0.15;
      reasons.add('Deeper water makes slip bobber less practical');
    }

    // Season: excellent in spring staging and winter
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'pre-spawn' || seasonLower == 'spring') {
      score += 0.15;
      reasons.add('Pre-spawn staging fish sit at precise depths - bobber excels');
      tips.add('Set bobber stop 6-12 inches above brush pile tops');
    } else if (seasonLower == 'winter') {
      score += 0.1;
      reasons.add('Winter crappie want a slow, stationary presentation');
      tips.add('Use a live minnow under the bobber for reluctant winter fish');
    }

    // Dawn/dusk bonus - bobber fishing shines during feeding windows
    final time = timeOfDay.toLowerCase();
    if (time == 'dawn' || time == 'dusk') {
      score += 0.05;
      tips.add('Prime feeding window - crappie will move up to the bait');
    }

    tips.add('Set the depth precisely - even 6 inches matters');
    tips.add('Use a small jig tipped with a minnow for best results');

    return score;
  }

  double _scoreLongLineTrolling({
    required double waterTempF,
    required double windSpeedMph,
    required double depthFt,
    required String season,
    required String barometricTrend,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.4;

    // Temp: best above 55F when fish are active
    if (waterTempF >= 55) {
      score += 0.15;
      reasons.add('Warm enough for fish to chase crankbaits and jigs');
    } else {
      score -= 0.2;
      reasons.add('Cold water crappie are too lethargic for trolling speed');
    }

    // Depth: 6-15 ft crankbait zone
    if (depthFt >= 6 && depthFt <= 15) {
      score += 0.15;
      reasons.add('Ideal crankbait diving depth for long-line trolling');
    } else if (depthFt < 6) {
      score -= 0.1;
      tips.add('Run shorter lines for shallow water trolling');
    } else {
      score -= 0.1;
      tips.add('Use heavier jigs or add weight to reach deeper fish');
    }

    // Season: post-spawn through fall
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'post-spawn' ||
        seasonLower == 'summer' ||
        seasonLower == 'fall') {
      score += 0.15;
      reasons.add('$season fish are scattered - trolling covers water fast');
    }

    // Wind: some wind/current actually helps (creates water movement)
    if (windSpeedMph >= 3 && windSpeedMph <= 15) {
      score += 0.1;
      reasons.add('Wind creates current that activates baitfish and crappie');
      tips.add('Troll with the wind for a natural presentation');
    } else if (windSpeedMph < 3) {
      score += 0.0;
      tips.add('In dead calm, use an S-pattern to vary lure speed');
    } else {
      score -= 0.1;
    }

    // Falling pressure = active feeding = trolling shines
    if (barometricTrend.toLowerCase() == 'falling') {
      score += 0.1;
      reasons.add('Falling pressure triggers aggressive feeding - cover water');
      tips.add('Speed up trolling to 1.0-1.5 mph to trigger reaction strikes');
    }

    tips.add('Troll at 0.8-1.2 mph and experiment with line length');
    tips.add('Use planer boards to spread lines and cover more water');

    return score;
  }

  double _scoreTightLining({
    required double waterTempF,
    required double windSpeedMph,
    required double depthFt,
    required String season,
    required String barometricTrend,
    required List<String> reasons,
    required List<String> tips,
  }) {
    double score = 0.35;

    // Cold water specialist: best under 55F
    if (waterTempF < 55) {
      score += 0.25;
      reasons.add('Cold water demands the slow, finesse presentation of tight-lining');
      tips.add('Use a lively minnow - scent and movement matter in cold water');
    } else if (waterTempF < 65) {
      score += 0.1;
    } else {
      score -= 0.15;
      reasons.add('Warm water fish are too active for tight-lining - try faster techniques');
    }

    // Wind: needs calm
    if (windSpeedMph <= 8) {
      score += 0.1;
      reasons.add('Calm conditions let you feel the subtle tight-line bites');
    } else {
      score -= 0.15;
      tips.add('Anchor up and use a sensitive rod to detect bites in wind');
    }

    // Depth: 10-30 ft
    if (depthFt >= 10 && depthFt <= 30) {
      score += 0.1;
      reasons.add('Good depth range for tight-lining over deep structure');
    } else if (depthFt < 10) {
      score -= 0.1;
    }

    // Season: winter and early spring
    final seasonLower = season.toLowerCase();
    if (seasonLower == 'winter') {
      score += 0.2;
      reasons.add('Winter is tight-lining prime time');
      tips.add('Fish the warmest part of the day - 10am to 2pm');
    } else if (seasonLower == 'early spring' ||
        seasonLower == 'pre-spawn' ||
        seasonLower == 'spring') {
      score += 0.1;
      tips.add('Transition fish still respond to slow minnow presentations');
    }

    // Rising/stable pressure after a front - fish are reluctant
    if (barometricTrend.toLowerCase() == 'rising' ||
        barometricTrend.toLowerCase() == 'stable' ||
        barometricTrend.toLowerCase() == 'steady') {
      score += 0.05;
      tips.add('Post-front conditions reward patience - tight-line and wait');
    }

    tips.add('Use a split shot 12-18 inches above a #4 hook with minnow');
    tips.add('Keep the line tight and watch for any twitch or load');

    return score;
  }
}

// ---------------------------------------------------------------------------
// Internal scoring helper
// ---------------------------------------------------------------------------

class _ScoredTechnique {
  final TechniqueProfile profile;
  final double score;
  final List<String> reasons;
  final List<String> tips;

  const _ScoredTechnique({
    required this.profile,
    required this.score,
    required this.reasons,
    required this.tips,
  });
}
