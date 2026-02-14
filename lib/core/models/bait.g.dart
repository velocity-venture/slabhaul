// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bait.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BaitBrandImpl _$$BaitBrandImplFromJson(Map<String, dynamic> json) =>
    _$BaitBrandImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      website: json['website'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$BaitBrandImplToJson(_$BaitBrandImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logoUrl': instance.logoUrl,
      'website': instance.website,
      'description': instance.description,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

_$BaitImpl _$$BaitImplFromJson(Map<String, dynamic> json) => _$BaitImpl(
      id: json['id'] as String,
      brandId: json['brandId'] as String?,
      name: json['name'] as String,
      modelNumber: json['modelNumber'] as String?,
      category: $enumDecode(_$BaitCategoryEnumMap, json['category']),
      subcategory: json['subcategory'] as String?,
      availableColors: (json['availableColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      availableSizes: (json['availableSizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      weightRangeMin: (json['weightRangeMin'] as num?)?.toDouble(),
      weightRangeMax: (json['weightRangeMax'] as num?)?.toDouble(),
      primaryImageUrl: json['primaryImageUrl'] as String?,
      additionalImages: (json['additionalImages'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      productDescription: json['productDescription'] as String?,
      manufacturerNotes: json['manufacturerNotes'] as String?,
      isCrappieSpecific: json['isCrappieSpecific'] as bool? ?? true,
      isVerified: json['isVerified'] as bool? ?? false,
      retailPriceUsd: (json['retailPriceUsd'] as num?)?.toDouble(),
      availabilityStatus: $enumDecodeNullable(
              _$AvailabilityStatusEnumMap, json['availabilityStatus']) ??
          AvailabilityStatus.available,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      brand: json['brand'] == null
          ? null
          : BaitBrand.fromJson(json['brand'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BaitImplToJson(_$BaitImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brandId': instance.brandId,
      'name': instance.name,
      'modelNumber': instance.modelNumber,
      'category': _$BaitCategoryEnumMap[instance.category]!,
      'subcategory': instance.subcategory,
      'availableColors': instance.availableColors,
      'availableSizes': instance.availableSizes,
      'weightRangeMin': instance.weightRangeMin,
      'weightRangeMax': instance.weightRangeMax,
      'primaryImageUrl': instance.primaryImageUrl,
      'additionalImages': instance.additionalImages,
      'productDescription': instance.productDescription,
      'manufacturerNotes': instance.manufacturerNotes,
      'isCrappieSpecific': instance.isCrappieSpecific,
      'isVerified': instance.isVerified,
      'retailPriceUsd': instance.retailPriceUsd,
      'availabilityStatus':
          _$AvailabilityStatusEnumMap[instance.availabilityStatus]!,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'brand': instance.brand,
    };

const _$BaitCategoryEnumMap = {
  BaitCategory.jig: 'jig',
  BaitCategory.crankbait: 'crankbait',
  BaitCategory.softPlastic: 'soft_plastic',
  BaitCategory.spoon: 'spoon',
  BaitCategory.spinner: 'spinner',
  BaitCategory.liveBait: 'live_bait',
  BaitCategory.other: 'other',
};

const _$AvailabilityStatusEnumMap = {
  AvailabilityStatus.available: 'available',
  AvailabilityStatus.discontinued: 'discontinued',
  AvailabilityStatus.seasonal: 'seasonal',
};

_$BaitReportImpl _$$BaitReportImplFromJson(Map<String, dynamic> json) =>
    _$BaitReportImpl(
      id: json['id'] as String,
      baitId: json['baitId'] as String,
      lakeId: json['lakeId'] as String?,
      attractorId: json['attractorId'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      colorUsed: json['colorUsed'] as String,
      sizeUsed: json['sizeUsed'] as String,
      weightUsed: (json['weightUsed'] as num?)?.toDouble(),
      fishCaught: (json['fishCaught'] as num?)?.toInt() ?? 0,
      fishSpecies: json['fishSpecies'] as String? ?? 'crappie',
      largestFishLength: (json['largestFishLength'] as num?)?.toDouble(),
      largestFishWeight: (json['largestFishWeight'] as num?)?.toDouble(),
      waterTemp: (json['waterTemp'] as num?)?.toDouble(),
      waterClarity:
          $enumDecodeNullable(_$WaterClarityEnumMap, json['waterClarity']),
      weatherConditions: json['weatherConditions'] as String?,
      timeOfDay:
          $enumDecodeNullable(_$FishingTimeOfDayEnumMap, json['timeOfDay']),
      season: $enumDecodeNullable(_$SeasonEnumMap, json['season']),
      techniqueUsed: json['techniqueUsed'] as String?,
      depthFished: (json['depthFished'] as num?)?.toDouble(),
      userId: json['userId'] as String?,
      isVerifiedCatch: json['isVerifiedCatch'] as bool? ?? false,
      reportDate: DateTime.parse(json['reportDate'] as String),
      confidenceScore: (json['confidenceScore'] as num?)?.toInt() ?? 3,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      bait: json['bait'] == null
          ? null
          : Bait.fromJson(json['bait'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$BaitReportImplToJson(_$BaitReportImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'baitId': instance.baitId,
      'lakeId': instance.lakeId,
      'attractorId': instance.attractorId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'colorUsed': instance.colorUsed,
      'sizeUsed': instance.sizeUsed,
      'weightUsed': instance.weightUsed,
      'fishCaught': instance.fishCaught,
      'fishSpecies': instance.fishSpecies,
      'largestFishLength': instance.largestFishLength,
      'largestFishWeight': instance.largestFishWeight,
      'waterTemp': instance.waterTemp,
      'waterClarity': _$WaterClarityEnumMap[instance.waterClarity],
      'weatherConditions': instance.weatherConditions,
      'timeOfDay': _$FishingTimeOfDayEnumMap[instance.timeOfDay],
      'season': _$SeasonEnumMap[instance.season],
      'techniqueUsed': instance.techniqueUsed,
      'depthFished': instance.depthFished,
      'userId': instance.userId,
      'isVerifiedCatch': instance.isVerifiedCatch,
      'reportDate': instance.reportDate.toIso8601String(),
      'confidenceScore': instance.confidenceScore,
      'notes': instance.notes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'bait': instance.bait,
    };

const _$WaterClarityEnumMap = {
  WaterClarity.clear: 'clear',
  WaterClarity.stained: 'stained',
  WaterClarity.muddy: 'muddy',
};

const _$FishingTimeOfDayEnumMap = {
  FishingTimeOfDay.dawn: 'dawn',
  FishingTimeOfDay.morning: 'morning',
  FishingTimeOfDay.midday: 'midday',
  FishingTimeOfDay.afternoon: 'afternoon',
  FishingTimeOfDay.dusk: 'dusk',
  FishingTimeOfDay.night: 'night',
};

const _$SeasonEnumMap = {
  Season.spring: 'spring',
  Season.summer: 'summer',
  Season.fall: 'fall',
  Season.winter: 'winter',
};

_$BaitEffectivenessImpl _$$BaitEffectivenessImplFromJson(
        Map<String, dynamic> json) =>
    _$BaitEffectivenessImpl(
      baitId: json['baitId'] as String,
      baitName: json['baitName'] as String,
      brandName: json['brandName'] as String?,
      category: $enumDecode(_$BaitCategoryEnumMap, json['category']),
      colorUsed: json['colorUsed'] as String,
      sizeUsed: json['sizeUsed'] as String,
      totalReports: (json['totalReports'] as num).toInt(),
      totalFish: (json['totalFish'] as num).toInt(),
      avgFishPerTrip: (json['avgFishPerTrip'] as num).toDouble(),
      biggestFishLength: (json['biggestFishLength'] as num?)?.toDouble(),
      biggestFishWeight: (json['biggestFishWeight'] as num?)?.toDouble(),
      avgConfidence: (json['avgConfidence'] as num).toDouble(),
      lakesReported: (json['lakesReported'] as num).toInt(),
    );

Map<String, dynamic> _$$BaitEffectivenessImplToJson(
        _$BaitEffectivenessImpl instance) =>
    <String, dynamic>{
      'baitId': instance.baitId,
      'baitName': instance.baitName,
      'brandName': instance.brandName,
      'category': _$BaitCategoryEnumMap[instance.category]!,
      'colorUsed': instance.colorUsed,
      'sizeUsed': instance.sizeUsed,
      'totalReports': instance.totalReports,
      'totalFish': instance.totalFish,
      'avgFishPerTrip': instance.avgFishPerTrip,
      'biggestFishLength': instance.biggestFishLength,
      'biggestFishWeight': instance.biggestFishWeight,
      'avgConfidence': instance.avgConfidence,
      'lakesReported': instance.lakesReported,
    };

_$LocationBaitRecommendationImpl _$$LocationBaitRecommendationImplFromJson(
        Map<String, dynamic> json) =>
    _$LocationBaitRecommendationImpl(
      lakeId: json['lakeId'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      baitId: json['baitId'] as String,
      baitName: json['baitName'] as String,
      brandName: json['brandName'] as String?,
      colorUsed: json['colorUsed'] as String,
      sizeUsed: json['sizeUsed'] as String,
      avgEffectiveness: (json['avgEffectiveness'] as num).toDouble(),
      reportCount: (json['reportCount'] as num).toInt(),
      mostRecentReport: DateTime.parse(json['mostRecentReport'] as String),
      distanceMiles: (json['distanceMiles'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$LocationBaitRecommendationImplToJson(
        _$LocationBaitRecommendationImpl instance) =>
    <String, dynamic>{
      'lakeId': instance.lakeId,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'baitId': instance.baitId,
      'baitName': instance.baitName,
      'brandName': instance.brandName,
      'colorUsed': instance.colorUsed,
      'sizeUsed': instance.sizeUsed,
      'avgEffectiveness': instance.avgEffectiveness,
      'reportCount': instance.reportCount,
      'mostRecentReport': instance.mostRecentReport.toIso8601String(),
      'distanceMiles': instance.distanceMiles,
    };
