// Bait Database Service
// Professional-grade bait management and effectiveness tracking

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bait.dart';
import '../utils/app_logger.dart';
import 'supabase_service.dart';

class BaitService {
  static SupabaseClient? get _client => SupabaseService.client;
  static const String _logContext = 'BaitService';

  // ============================================================================
  // BAIT BRANDS
  // ============================================================================

  /// Fetch all bait brands
  static Future<List<BaitBrand>> getBrands() async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, using local brands');
        return [_bps, _sjh, _crl, _stk, _sfs];
      }

      final response = await client
          .from('bait_brands')
          .select()
          .order('name');

      return (response as List)
          .map((json) => BaitBrand.fromJson(json))
          .toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getBrands', e, st);
      return [];
    }
  }

  /// Create a new bait brand
  static Future<BaitBrand?> createBrand(String name, {String? description, String? logoUrl, String? website}) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available for brand creation');
        return null;
      }

      final response = await client
          .from('bait_brands')
          .insert({
            'name': name,
            'description': description,
            'logo_url': logoUrl,
            'website': website,
          })
          .select()
          .single();

      return BaitBrand.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_logContext, 'createBrand', e, st);
      return null;
    }
  }

  // ============================================================================
  // BAIT CATALOG
  // ============================================================================

  /// Fetch baits with optional filtering
  static Future<List<Bait>> getBaits({
    BaitCategory? category,
    String? brandId,
    bool? isCrappieSpecific,
    String? searchQuery,
    int limit = 50,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, using local bait catalog');
        return _getLocalBaits(
          category: category,
          searchQuery: searchQuery,
          limit: limit,
        );
      }

      var query = client
          .from('baits')
          .select('''
            *,
            brand:bait_brands(*)
          ''');

      // Apply filters
      if (category != null) {
        query = query.eq('category', category.name);
      }

      if (brandId != null) {
        query = query.eq('brand_id', brandId);
      }

      if (isCrappieSpecific != null) {
        query = query.eq('is_crappie_specific', isCrappieSpecific);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('name.ilike.%$searchQuery%,product_description.ilike.%$searchQuery%');
      }

      final response = await query
          .order('name')
          .limit(limit);

      return (response as List).map((json) {
        // Handle nested brand data
        final brandData = json['brand'] as Map<String, dynamic>?;
        final baitData = Map<String, dynamic>.from(json);
        if (brandData != null) {
          baitData['brand'] = BaitBrand.fromJson(brandData);
        }
        baitData.remove('brand'); // Remove the raw nested data
        
        return Bait.fromJson(baitData);
      }).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getBaits', e, st);
      return [];
    }
  }

  /// Get a specific bait by ID
  static Future<Bait?> getBaitById(String baitId) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available');
        return null;
      }

      final response = await client
          .from('baits')
          .select('''
            *,
            brand:bait_brands(*)
          ''')
          .eq('id', baitId)
          .single();

      // Handle nested brand data
      final brandData = response['brand'] as Map<String, dynamic>?;
      final baitData = Map<String, dynamic>.from(response);
      if (brandData != null) {
        baitData['brand'] = BaitBrand.fromJson(brandData);
      }
      baitData.remove('brand');

      return Bait.fromJson(baitData);
    } catch (e, st) {
      AppLogger.error(_logContext, 'getBaitById', e, st);
      return null;
    }
  }

  /// Create a new bait
  static Future<Bait?> createBait({
    String? brandId,
    required String name,
    String? modelNumber,
    required BaitCategory category,
    String? subcategory,
    List<String> availableColors = const [],
    List<String> availableSizes = const [],
    double? weightRangeMin,
    double? weightRangeMax,
    String? primaryImageUrl,
    List<String> additionalImages = const [],
    String? productDescription,
    String? manufacturerNotes,
    bool isCrappieSpecific = true,
    double? retailPriceUsd,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available for bait creation');
        return null;
      }

      final response = await client
          .from('baits')
          .insert({
            'brand_id': brandId,
            'name': name,
            'model_number': modelNumber,
            'category': category.name,
            'subcategory': subcategory,
            'available_colors': availableColors,
            'available_sizes': availableSizes,
            'weight_range_min': weightRangeMin,
            'weight_range_max': weightRangeMax,
            'primary_image_url': primaryImageUrl,
            'additional_images': additionalImages,
            'product_description': productDescription,
            'manufacturer_notes': manufacturerNotes,
            'is_crappie_specific': isCrappieSpecific,
            'retail_price_usd': retailPriceUsd,
          })
          .select()
          .single();

      return Bait.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_logContext, 'createBait', e, st);
      return null;
    }
  }

  // ============================================================================
  // BAIT REPORTS
  // ============================================================================

  /// Submit a bait report
  static Future<BaitReport?> submitBaitReport({
    required String baitId,
    String? lakeId,
    String? attractorId,
    required double latitude,
    required double longitude,
    required String colorUsed,
    required String sizeUsed,
    double? weightUsed,
    int fishCaught = 0,
    String fishSpecies = 'crappie',
    double? largestFishLength,
    double? largestFishWeight,
    double? waterTemp,
    WaterClarity? waterClarity,
    String? weatherConditions,
    FishingTimeOfDay? timeOfDay,
    Season? season,
    String? techniqueUsed,
    double? depthFished,
    bool isVerifiedCatch = false,
    DateTime? reportDate,
    int confidenceScore = 3,
    String? notes,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available for bait report submission');
        return null;
      }

      final userId = client.auth.currentUser?.id;

      final response = await client
          .from('bait_reports')
          .insert({
            'bait_id': baitId,
            'lake_id': lakeId,
            'attractor_id': attractorId,
            'latitude': latitude,
            'longitude': longitude,
            'color_used': colorUsed,
            'size_used': sizeUsed,
            'weight_used': weightUsed,
            'fish_caught': fishCaught,
            'fish_species': fishSpecies,
            'largest_fish_length': largestFishLength,
            'largest_fish_weight': largestFishWeight,
            'water_temp': waterTemp,
            'water_clarity': waterClarity?.name,
            'weather_conditions': weatherConditions,
            'time_of_day': timeOfDay?.name,
            'season': season?.name,
            'technique_used': techniqueUsed,
            'depth_fished': depthFished,
            'user_id': userId,
            'is_verified_catch': isVerifiedCatch,
            'report_date': (reportDate ?? DateTime.now()).toIso8601String().split('T')[0],
            'confidence_score': confidenceScore,
            'notes': notes,
          })
          .select()
          .single();

      return BaitReport.fromJson(response);
    } catch (e, st) {
      AppLogger.error(_logContext, 'submitBaitReport', e, st);
      return null;
    }
  }

  /// Get bait reports with optional filtering
  static Future<List<BaitReport>> getBaitReports({
    String? baitId,
    String? lakeId,
    double? latitude,
    double? longitude,
    double? radiusMiles,
    Season? season,
    bool successfulOnly = false,
    int limit = 100,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, returning empty reports list');
        return [];
      }

      var query = client
          .from('bait_reports')
          .select('''
            *,
            bait:baits(
              *,
              brand:bait_brands(*)
            )
          ''');

      // Apply filters
      if (baitId != null) {
        query = query.eq('bait_id', baitId);
      }

      if (lakeId != null) {
        query = query.eq('lake_id', lakeId);
      }

      if (season != null) {
        query = query.eq('season', season.name);
      }

      if (successfulOnly) {
        query = query.gt('fish_caught', 0);
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) {
        // Handle nested bait and brand data
        final baitData = json['bait'] as Map<String, dynamic>?;
        final reportData = Map<String, dynamic>.from(json);
        
        if (baitData != null) {
          final brandData = baitData['brand'] as Map<String, dynamic>?;
          if (brandData != null) {
            baitData['brand'] = BaitBrand.fromJson(brandData);
          }
          reportData['bait'] = Bait.fromJson(baitData);
        }
        reportData.remove('bait'); // Remove raw nested data
        
        return BaitReport.fromJson(reportData);
      }).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getBaitReports', e, st);
      return [];
    }
  }

  // ============================================================================
  // BAIT EFFECTIVENESS & RECOMMENDATIONS
  // ============================================================================

  /// Get bait effectiveness summary
  static Future<List<BaitEffectiveness>> getBaitEffectiveness({
    BaitCategory? category,
    String? colorUsed,
    int limit = 50,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, returning empty effectiveness list');
        return [];
      }

      var query = client
          .from('bait_effectiveness')
          .select();

      if (category != null) {
        query = query.eq('category', category.name);
      }

      if (colorUsed != null) {
        query = query.eq('color_used', colorUsed);
      }

      final response = await query
          .order('avg_fish_per_trip', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => BaitEffectiveness.fromJson(json))
          .toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getBaitEffectiveness', e, st);
      return [];
    }
  }

  /// Get location-based bait recommendations
  static Future<List<LocationBaitRecommendation>> getLocationRecommendations({
    required double latitude,
    required double longitude,
    double radiusMiles = 5.0,
    int limit = 10,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, returning empty recommendations');
        return [];
      }

      // Use the database function for location-based recommendations
      final response = await client
          .rpc('get_location_bait_recommendations', params: {
            'search_lat': latitude,
            'search_lon': longitude,
            'search_radius_miles': radiusMiles,
            'limit_results': limit,
          });

      return (response as List).map((json) {
        return LocationBaitRecommendation.fromJson({
          'latitude': latitude,
          'longitude': longitude,
          'bait_id': '', // Function doesn't return this
          'bait_name': json['bait_name'],
          'brand_name': json['brand_name'],
          'color_used': json['color'],
          'size_used': json['size'],
          'avg_effectiveness': json['effectiveness_score'],
          'report_count': json['total_reports'],
          'most_recent_report': DateTime.now().toIso8601String(), // Placeholder
          'distance_miles': json['distance_miles'],
        });
      }).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getLocationRecommendations', e, st);
      return [];
    }
  }

  /// Get seasonal bait recommendations
  static Future<List<BaitEffectiveness>> getSeasonalRecommendations({
    required Season season,
    int limit = 15,
  }) async {
    try {
      final client = _client;
      if (client == null) {
        AppLogger.warn(_logContext, 'Supabase not available, returning empty seasonal recommendations');
        return [];
      }

      // Use the database function for seasonal recommendations
      final response = await client
          .rpc('get_seasonal_bait_recommendations', params: {
            'target_season': season.name,
            'limit_results': limit,
          });

      return (response as List).map((json) {
        return BaitEffectiveness.fromJson({
          'bait_id': '', // Function doesn't return this
          'bait_name': json['bait_name'],
          'brand_name': json['brand_name'],
          'category': 'jig', // Default category
          'color_used': json['color'],
          'size_used': '', // Not returned by function
          'total_reports': 0, // Not returned by function
          'total_fish': 0, // Not returned by function
          'avg_fish_per_trip': json['avg_effectiveness'],
          'biggest_fish_length': null,
          'biggest_fish_weight': null,
          'avg_confidence': 5.0, // Default
          'lakes_reported': 0, // Not returned by function
        });
      }).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getSeasonalRecommendations', e, st);
      return [];
    }
  }

  // ============================================================================
  // UTILITY FUNCTIONS
  // ============================================================================

  /// Get popular colors for a specific bait category
  static Future<List<String>> getPopularColors({BaitCategory? category}) async {
    try {
      final client = _client;
      if (client == null) {
        return _getDefaultColors();
      }

      var query = client
          .from('bait_reports')
          .select('color_used');

      if (category != null) {
        // Join with baits table to filter by category
        query = client
            .from('bait_reports')
            .select('color_used, baits!inner(category)')
            .eq('baits.category', category.name);
      }

      final response = await query.limit(1000);

      // Count color occurrences
      final colorCounts = <String, int>{};
      for (final report in response as List) {
        final color = report['color_used'] as String?;
        if (color != null) {
          colorCounts[color] = (colorCounts[color] ?? 0) + 1;
        }
      }

      // Sort by popularity and return top colors
      final sortedColors = colorCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedColors.map((entry) => entry.key).take(20).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getPopularColors', e, st);
      return _getDefaultColors();
    }
  }

  /// Get popular sizes for a specific bait category
  static Future<List<String>> getPopularSizes({BaitCategory? category}) async {
    try {
      final client = _client;
      if (client == null) {
        return _getDefaultSizes();
      }

      var query = client
          .from('bait_reports')
          .select('size_used');

      if (category != null) {
        query = client
            .from('bait_reports')
            .select('size_used, baits!inner(category)')
            .eq('baits.category', category.name);
      }

      final response = await query.limit(1000);

      // Count size occurrences
      final sizeCounts = <String, int>{};
      for (final report in response as List) {
        final size = report['size_used'] as String?;
        if (size != null) {
          sizeCounts[size] = (sizeCounts[size] ?? 0) + 1;
        }
      }

      // Sort by popularity and return top sizes
      final sortedSizes = sizeCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      return sortedSizes.map((entry) => entry.key).take(15).toList();
    } catch (e, st) {
      AppLogger.error(_logContext, 'getPopularSizes', e, st);
      return _getDefaultSizes();
    }
  }

  static List<String> _getDefaultColors() {
    return [
      'White',
      'Chartreuse',
      'Yellow',
      'Pink',
      'Black',
      'Orange',
      'Red',
      'Blue',
      'Green',
      'Purple',
      'Silver',
      'Gold',
      'Clear',
      'Smoke',
      'Pearl',
    ];
  }

  static List<String> _getDefaultSizes() {
    return [
      '1/32 oz',
      '1/16 oz',
      '1/8 oz',
      '1/4 oz',
      '3/8 oz',
      '1/2 oz',
      '1"',
      '1.5"',
      '2"',
      '2.5"',
      '3"',
      '3.5"',
      '4"',
    ];
  }

  // ============================================================================
  // LOCAL FALLBACK BAIT DATA
  // ============================================================================

  static List<Bait> _getLocalBaits({
    BaitCategory? category,
    String? searchQuery,
    int limit = 50,
  }) {
    var baits = _localBaitCatalog;
    if (category != null) {
      baits = baits.where((b) => b.category == category).toList();
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      baits = baits
          .where((b) =>
              b.name.toLowerCase().contains(q) ||
              (b.productDescription?.toLowerCase().contains(q) ?? false) ||
              (b.brand?.name.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return baits.take(limit).toList();
  }

  static final _sfs = BaitBrand(
    id: 'local-sfs',
    name: 'Southern Fishing Supply',
    description: 'Premium crappie fishing tackle',
  );
  static final _bps = BaitBrand(
    id: 'local-bps',
    name: "Bobby Garland",
    description: 'Legendary crappie baits',
  );
  static final _sjh = BaitBrand(
    id: 'local-sjh',
    name: "Southern Pro",
    description: 'Tournament-proven crappie lures',
  );
  static final _crl = BaitBrand(
    id: 'local-crl',
    name: "Crappie Magnet",
    description: 'Catch more crappie',
  );
  static final _stk = BaitBrand(
    id: 'local-stk',
    name: "Strike King",
    description: 'Strike King Lure Company',
  );

  static final List<Bait> _localBaitCatalog = [
    Bait(
      id: 'local-1',
      name: 'Baby Shad',
      category: BaitCategory.softPlastic,
      brand: _bps,
      brandId: 'local-bps',
      availableColors: ['Pearl White', 'Chartreuse', 'Blue Ice', 'Monkey Milk', 'Pink/Pearl'],
      availableSizes: ['2"'],
      isCrappieSpecific: true,
      productDescription: 'The #1 crappie bait in the country. Split-tail design creates lifelike swimming action.',
      retailPriceUsd: 3.99,
    ),
    Bait(
      id: 'local-2',
      name: 'Stroll\'r',
      category: BaitCategory.softPlastic,
      brand: _bps,
      brandId: 'local-bps',
      availableColors: ['Bluegrass', 'Glacier', 'Threadfin Shad', 'Electric Chicken'],
      availableSizes: ['2"', '2.5"'],
      isCrappieSpecific: true,
      productDescription: 'Spider-leg design for slow-falling action perfect for vertical jigging.',
      retailPriceUsd: 3.99,
    ),
    Bait(
      id: 'local-3',
      name: 'Lit\'l Hustler',
      category: BaitCategory.softPlastic,
      brand: _sjh,
      brandId: 'local-sjh',
      availableColors: ['Hot Chartreuse', 'Pearl', 'Blue/Chartreuse', 'Junebug'],
      availableSizes: ['1.5"', '2"'],
      isCrappieSpecific: true,
      productDescription: 'Classic tube-style bait with multiple tentacles for maximum water displacement.',
      retailPriceUsd: 2.99,
    ),
    Bait(
      id: 'local-4',
      name: 'Crappie Magnet',
      category: BaitCategory.softPlastic,
      brand: _crl,
      brandId: 'local-crl',
      availableColors: ['Chartreuse/White', 'Pink/White', 'Black/Chartreuse', 'Electric Chicken'],
      availableSizes: ['1.5"'],
      isCrappieSpecific: true,
      productDescription: 'Small profile body with a split-tail that produces a subtle swimming action crappie can\'t resist.',
      retailPriceUsd: 3.49,
    ),
    Bait(
      id: 'local-5',
      name: 'Mr. Crappie Slab Daddy',
      category: BaitCategory.softPlastic,
      brand: _stk,
      brandId: 'local-stk',
      availableColors: ['Tuxedo Black', 'Refrigerator White', 'Hot Chicken', 'Grassy Point'],
      availableSizes: ['2.5"', '3"'],
      isCrappieSpecific: true,
      productDescription: 'Wally Marshall signature series. Paddle-tail design for aggressive swimming action.',
      retailPriceUsd: 3.29,
    ),
    Bait(
      id: 'local-6',
      name: 'Mr. Crappie Slab Slanger',
      category: BaitCategory.jig,
      brand: _stk,
      brandId: 'local-stk',
      availableColors: ['Pearl/Chartreuse', 'Black/Chartreuse', 'Blue Moon', 'Tuxedo Black/Chartreuse'],
      availableSizes: ['1/16 oz', '1/32 oz'],
      weightRangeMin: 0.03125,
      weightRangeMax: 0.0625,
      isCrappieSpecific: true,
      productDescription: 'Round jig head with Tru-Life finish and sharp hook. Perfect for tipping with soft plastics.',
      retailPriceUsd: 4.49,
    ),
    Bait(
      id: 'local-7',
      name: 'Road Runner Marabou Jig',
      category: BaitCategory.jig,
      brand: _sfs,
      brandId: 'local-sfs',
      availableColors: ['White', 'Chartreuse', 'Pink', 'Black'],
      availableSizes: ['1/16 oz', '1/8 oz'],
      weightRangeMin: 0.0625,
      weightRangeMax: 0.125,
      isCrappieSpecific: true,
      productDescription: 'Spinner jig with rotating blade and marabou dressing. Vibration attracts crappie from distance.',
      retailPriceUsd: 3.99,
    ),
    Bait(
      id: 'local-8',
      name: 'Betts Bee',
      category: BaitCategory.jig,
      brand: _sfs,
      brandId: 'local-sfs',
      availableColors: ['Black/Chartreuse', 'White', 'Yellow', 'Red/White'],
      availableSizes: ['1/32 oz', '1/16 oz'],
      weightRangeMin: 0.03125,
      weightRangeMax: 0.0625,
      isCrappieSpecific: true,
      productDescription: 'Hair jig with chenille body and hackle collar. A classic crappie catcher for decades.',
      retailPriceUsd: 1.99,
    ),
    Bait(
      id: 'local-9',
      name: 'Bandit 100 Series',
      category: BaitCategory.crankbait,
      brand: _sfs,
      brandId: 'local-sfs',
      availableColors: ['Chartreuse/Black Back', 'Shad', 'Crawfish', 'Firetiger'],
      availableSizes: ['1.5"'],
      isCrappieSpecific: false,
      productDescription: 'Small crankbait that dives 2-5 feet. Excellent for trolling brush piles.',
      retailPriceUsd: 5.99,
    ),
    Bait(
      id: 'local-10',
      name: 'Slab Slasher Spoon',
      category: BaitCategory.spoon,
      brand: _sfs,
      brandId: 'local-sfs',
      availableColors: ['Silver', 'Gold', 'Chartreuse', 'White'],
      availableSizes: ['1/16 oz', '1/8 oz'],
      weightRangeMin: 0.0625,
      weightRangeMax: 0.125,
      isCrappieSpecific: true,
      productDescription: 'Lightweight flutter spoon that mimics dying shad. Deadly for vertical jigging deep brush.',
      retailPriceUsd: 2.49,
    ),
    Bait(
      id: 'local-11',
      name: 'Beetle Spin',
      category: BaitCategory.spinner,
      brand: _sfs,
      brandId: 'local-sfs',
      availableColors: ['White', 'Chartreuse', 'Black', 'Yellow'],
      availableSizes: ['1/16 oz', '1/8 oz'],
      weightRangeMin: 0.0625,
      weightRangeMax: 0.125,
      isCrappieSpecific: false,
      productDescription: 'Classic underspin jig with Colorado blade. Cast and retrieve near brush piles.',
      retailPriceUsd: 2.99,
    ),
    Bait(
      id: 'local-12',
      name: 'Live Minnow (Fathead)',
      category: BaitCategory.liveBait,
      availableColors: ['Natural'],
      availableSizes: ['1"', '1.5"', '2"'],
      isCrappieSpecific: true,
      productDescription: 'The original crappie bait. Hook through the lips or back and fish under a bobber or tight-line.',
      retailPriceUsd: 4.99,
    ),
  ];
}