// Bait Database Models
// Professional-grade bait catalog with effectiveness tracking

import 'package:freezed_annotation/freezed_annotation.dart';

part 'bait.freezed.dart';
part 'bait.g.dart';

// ============================================================================
// BAIT BRAND MODEL
// ============================================================================

@freezed
class BaitBrand with _$BaitBrand {
  const factory BaitBrand({
    required String id,
    required String name,
    String? logoUrl,
    String? website,
    String? description,
    DateTime? createdAt,
  }) = _BaitBrand;

  factory BaitBrand.fromJson(Map<String, dynamic> json) => _$BaitBrandFromJson(json);
}

// ============================================================================
// BAIT MODEL
// ============================================================================

enum BaitCategory {
  jig,
  crankbait,
  @JsonValue('soft_plastic')
  softPlastic,
  spoon,
  spinner,
  @JsonValue('live_bait')
  liveBait,
  other,
}

enum AvailabilityStatus {
  available,
  discontinued,
  seasonal,
}

extension BaitCategoryX on BaitCategory {
  String get displayName {
    switch (this) {
      case BaitCategory.jig:
        return 'Jig';
      case BaitCategory.crankbait:
        return 'Crankbait';
      case BaitCategory.softPlastic:
        return 'Soft Plastic';
      case BaitCategory.spoon:
        return 'Spoon';
      case BaitCategory.spinner:
        return 'Spinner';
      case BaitCategory.liveBait:
        return 'Live Bait';
      case BaitCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case BaitCategory.jig:
        return '🎣';
      case BaitCategory.crankbait:
        return '🐟';
      case BaitCategory.softPlastic:
        return '🪱';
      case BaitCategory.spoon:
        return '🥄';
      case BaitCategory.spinner:
        return '🌀';
      case BaitCategory.liveBait:
        return '🐛';
      case BaitCategory.other:
        return '🎯';
    }
  }
}

@freezed
class Bait with _$Bait {
  const factory Bait({
    required String id,
    String? brandId,
    required String name,
    String? modelNumber,
    required BaitCategory category,
    String? subcategory,
    @Default([]) List<String> availableColors,
    @Default([]) List<String> availableSizes,
    double? weightRangeMin,
    double? weightRangeMax,
    String? primaryImageUrl,
    @Default([]) List<String> additionalImages,
    String? productDescription,
    String? manufacturerNotes,
    @Default(true) bool isCrappieSpecific,
    @Default(false) bool isVerified,
    double? retailPriceUsd,
    @Default(AvailabilityStatus.available) AvailabilityStatus availabilityStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Populated from joins
    BaitBrand? brand,
  }) = _Bait;

  factory Bait.fromJson(Map<String, dynamic> json) => _$BaitFromJson(json);
}

extension BaitX on Bait {
  String get displayName {
    if (brand != null) {
      return '${brand!.name} $name';
    }
    return name;
  }

  String get priceDisplay {
    if (retailPriceUsd != null) {
      return '\$${retailPriceUsd!.toStringAsFixed(2)}';
    }
    return 'Price varies';
  }

  String get weightRangeDisplay {
    if (weightRangeMin != null && weightRangeMax != null) {
      if (weightRangeMin == weightRangeMax) {
        return '${_formatWeight(weightRangeMin!)}';
      }
      return '${_formatWeight(weightRangeMin!)} - ${_formatWeight(weightRangeMax!)}';
    } else if (weightRangeMin != null) {
      return '${_formatWeight(weightRangeMin!)}+';
    } else if (weightRangeMax != null) {
      return 'Up to ${_formatWeight(weightRangeMax!)}';
    }
    return 'Weight varies';
  }

  String _formatWeight(double oz) {
    // Convert decimal ounces to fractions for common weights
    if (oz == 0.03125) return '1/32 oz';
    if (oz == 0.0625) return '1/16 oz';
    if (oz == 0.125) return '1/8 oz';
    if (oz == 0.25) return '1/4 oz';
    if (oz == 0.375) return '3/8 oz';
    if (oz == 0.5) return '1/2 oz';
    if (oz == 0.75) return '3/4 oz';
    if (oz == 1.0) return '1 oz';
    
    return '${oz.toStringAsFixed(3)} oz';
  }

  bool get hasImage => primaryImageUrl != null && primaryImageUrl!.isNotEmpty;
  
  int get totalImages => (hasImage ? 1 : 0) + additionalImages.length;
}

// ============================================================================
// BAIT REPORT MODEL
// ============================================================================

enum WaterClarity {
  clear,
  stained,
  muddy,
}

enum FishingTimeOfDay {
  dawn,
  morning,
  midday,
  afternoon,
  dusk,
  night,
}

enum Season {
  spring,
  summer,
  fall,
  winter,
}

extension WaterClarityX on WaterClarity {
  String get displayName {
    switch (this) {
      case WaterClarity.clear:
        return 'Clear';
      case WaterClarity.stained:
        return 'Stained';
      case WaterClarity.muddy:
        return 'Muddy';
    }
  }
}

extension FishingTimeOfDayX on FishingTimeOfDay {
  String get displayName {
    switch (this) {
      case FishingTimeOfDay.dawn:
        return 'Dawn';
      case FishingTimeOfDay.morning:
        return 'Morning';
      case FishingTimeOfDay.midday:
        return 'Midday';
      case FishingTimeOfDay.afternoon:
        return 'Afternoon';
      case FishingTimeOfDay.dusk:
        return 'Dusk';
      case FishingTimeOfDay.night:
        return 'Night';
    }
  }
}

extension SeasonX on Season {
  String get displayName {
    switch (this) {
      case Season.spring:
        return 'Spring';
      case Season.summer:
        return 'Summer';
      case Season.fall:
        return 'Fall';
      case Season.winter:
        return 'Winter';
    }
  }

  String get icon {
    switch (this) {
      case Season.spring:
        return '🌸';
      case Season.summer:
        return '☀️';
      case Season.fall:
        return '🍂';
      case Season.winter:
        return '❄️';
    }
  }
}

@freezed
class BaitReport with _$BaitReport {
  const factory BaitReport({
    required String id,
    required String baitId,
    String? lakeId,
    String? attractorId,
    required double latitude,
    required double longitude,
    required String colorUsed,
    required String sizeUsed,
    double? weightUsed,
    @Default(0) int fishCaught,
    @Default('crappie') String fishSpecies,
    double? largestFishLength,
    double? largestFishWeight,
    double? waterTemp,
    WaterClarity? waterClarity,
    String? weatherConditions,
    FishingTimeOfDay? timeOfDay,
    Season? season,
    String? techniqueUsed,
    double? depthFished,
    String? userId,
    @Default(false) bool isVerifiedCatch,
    required DateTime reportDate,
    @Default(3) int confidenceScore,
    String? notes,
    DateTime? createdAt,
    // Populated from joins
    Bait? bait,
  }) = _BaitReport;

  factory BaitReport.fromJson(Map<String, dynamic> json) => _$BaitReportFromJson(json);
}

extension BaitReportX on BaitReport {
  String get baitDescription {
    if (bait != null) {
      return '${bait!.displayName} - $colorUsed $sizeUsed';
    }
    return '$colorUsed $sizeUsed';
  }

  String get resultsDescription {
    if (fishCaught == 0) {
      return 'No fish caught';
    } else if (fishCaught == 1) {
      return '1 fish caught';
    } else {
      return '$fishCaught fish caught';
    }
  }

  String get locationDescription {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  String get conditionsDescription {
    final parts = <String>[];
    
    if (waterTemp != null) {
      parts.add('${waterTemp!.toStringAsFixed(0)}°F water');
    }
    if (waterClarity != null) {
      parts.add(waterClarity!.displayName.toLowerCase());
    }
    if (timeOfDay != null) {
      parts.add(timeOfDay!.displayName.toLowerCase());
    }
    if (season != null) {
      parts.add(season!.displayName.toLowerCase());
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'No conditions recorded';
  }

  bool get wasSuccessful => fishCaught > 0;
  
  double get successScore => fishCaught * (confidenceScore / 5.0);
}

// ============================================================================
// BAIT EFFECTIVENESS SUMMARY MODEL
// ============================================================================

@freezed
class BaitEffectiveness with _$BaitEffectiveness {
  const factory BaitEffectiveness({
    required String baitId,
    required String baitName,
    String? brandName,
    required BaitCategory category,
    required String colorUsed,
    required String sizeUsed,
    required int totalReports,
    required int totalFish,
    required double avgFishPerTrip,
    double? biggestFishLength,
    double? biggestFishWeight,
    required double avgConfidence,
    required int lakesReported,
  }) = _BaitEffectiveness;

  factory BaitEffectiveness.fromJson(Map<String, dynamic> json) => _$BaitEffectivenessFromJson(json);
}

extension BaitEffectivenessX on BaitEffectiveness {
  String get fullName {
    if (brandName != null) {
      return '$brandName $baitName';
    }
    return baitName;
  }

  String get colorSizeDisplay => '$colorUsed $sizeUsed';

  String get effectivenessRating {
    if (avgFishPerTrip >= 5.0) return 'Excellent';
    if (avgFishPerTrip >= 3.0) return 'Very Good';
    if (avgFishPerTrip >= 2.0) return 'Good';
    if (avgFishPerTrip >= 1.0) return 'Fair';
    return 'Poor';
  }

  double get effectivenessScore => avgFishPerTrip * (avgConfidence / 5.0);

  String get biggestFishDisplay {
    if (biggestFishLength != null && biggestFishWeight != null) {
      return '${biggestFishLength!.toStringAsFixed(1)}" / ${biggestFishWeight!.toStringAsFixed(2)} lbs';
    } else if (biggestFishLength != null) {
      return '${biggestFishLength!.toStringAsFixed(1)}"';
    } else if (biggestFishWeight != null) {
      return '${biggestFishWeight!.toStringAsFixed(2)} lbs';
    }
    return 'No size data';
  }
}

// ============================================================================
// LOCATION BAIT RECOMMENDATION MODEL
// ============================================================================

@freezed
class LocationBaitRecommendation with _$LocationBaitRecommendation {
  const factory LocationBaitRecommendation({
    String? lakeId,
    required double latitude,
    required double longitude,
    required String baitId,
    required String baitName,
    String? brandName,
    required String colorUsed,
    required String sizeUsed,
    required double avgEffectiveness,
    required int reportCount,
    required DateTime mostRecentReport,
    // Additional fields from function calls
    double? distanceMiles,
  }) = _LocationBaitRecommendation;

  factory LocationBaitRecommendation.fromJson(Map<String, dynamic> json) => _$LocationBaitRecommendationFromJson(json);
}

extension LocationBaitRecommendationX on LocationBaitRecommendation {
  String get fullBaitName {
    if (brandName != null) {
      return '$brandName $baitName';
    }
    return baitName;
  }

  String get colorSizeDisplay => '$colorUsed $sizeUsed';

  String get distanceDisplay {
    if (distanceMiles != null) {
      if (distanceMiles! < 1.0) {
        return '${(distanceMiles! * 5280).toStringAsFixed(0)} ft away';
      }
      return '${distanceMiles!.toStringAsFixed(1)} mi away';
    }
    return '';
  }

  String get recentActivityDisplay {
    final now = DateTime.now();
    final difference = now.difference(mostRecentReport);
    
    if (difference.inDays == 0) {
      return 'Reported today';
    } else if (difference.inDays == 1) {
      return 'Reported yesterday';
    } else if (difference.inDays < 7) {
      return 'Reported ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return 'Reported ${(difference.inDays / 7).round()} weeks ago';
    } else {
      return 'Reported ${(difference.inDays / 30).round()} months ago';
    }
  }

  bool get isRecentlyActive => DateTime.now().difference(mostRecentReport).inDays <= 14;
}