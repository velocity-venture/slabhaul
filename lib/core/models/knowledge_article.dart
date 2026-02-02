class SeasonalPattern {
  final String season;
  final String tempRange;
  final String depthRange;
  final List<String> locations;
  final List<String> techniques;
  final String baits;
  final List<String> colors;
  final String notes;

  const SeasonalPattern({
    required this.season,
    required this.tempRange,
    required this.depthRange,
    required this.locations,
    required this.techniques,
    required this.baits,
    required this.colors,
    required this.notes,
  });
}

class Technique {
  final String name;
  final String description;
  final String setupTips;
  final String bestConditions;
  final List<String> pros;
  final List<String> cons;
  final String proTips;

  const Technique({
    required this.name,
    required this.description,
    required this.setupTips,
    required this.bestConditions,
    required this.pros,
    required this.cons,
    required this.proTips,
  });
}

class BaitLure {
  final String type;
  final String ranking;
  final String topSizes;
  final List<String> bestColors;
  final String riggingMethods;

  const BaitLure({
    required this.type,
    required this.ranking,
    required this.topSizes,
    required this.bestColors,
    required this.riggingMethods,
  });
}
