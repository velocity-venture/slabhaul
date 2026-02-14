// Bait Browser Screen
// Professional bait catalog with filtering and effectiveness data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/bait.dart';
import '../../core/services/bait_service.dart';
import 'bait_detail_screen.dart';
import 'submit_bait_report_screen.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

final baitBrandsProvider = FutureProvider<List<BaitBrand>>((ref) async {
  return BaitService.getBrands();
});

final baitCatalogProvider = FutureProvider.family<List<Bait>, BaitSearchParams>((ref, params) async {
  return BaitService.getBaits(
    category: params.category,
    brandId: params.brandId,
    isCrappieSpecific: params.isCrappieSpecific,
    searchQuery: params.searchQuery,
    limit: params.limit,
  );
});

final popularColorsProvider = FutureProvider.family<List<String>, BaitCategory?>((ref, category) async {
  return BaitService.getPopularColors(category: category);
});

class BaitSearchParams {
  final BaitCategory? category;
  final String? brandId;
  final bool? isCrappieSpecific;
  final String? searchQuery;
  final int limit;

  const BaitSearchParams({
    this.category,
    this.brandId,
    this.isCrappieSpecific,
    this.searchQuery,
    this.limit = 50,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaitSearchParams &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          brandId == other.brandId &&
          isCrappieSpecific == other.isCrappieSpecific &&
          searchQuery == other.searchQuery &&
          limit == other.limit;

  @override
  int get hashCode =>
      category.hashCode ^
      brandId.hashCode ^
      isCrappieSpecific.hashCode ^
      searchQuery.hashCode ^
      limit.hashCode;

  BaitSearchParams copyWith({
    BaitCategory? category,
    String? brandId,
    bool? isCrappieSpecific,
    String? searchQuery,
    int? limit,
  }) {
    return BaitSearchParams(
      category: category ?? this.category,
      brandId: brandId ?? this.brandId,
      isCrappieSpecific: isCrappieSpecific ?? this.isCrappieSpecific,
      searchQuery: searchQuery ?? this.searchQuery,
      limit: limit ?? this.limit,
    );
  }
}

// ============================================================================
// SEARCH STATE NOTIFIER
// ============================================================================

class BaitSearchNotifier extends StateNotifier<BaitSearchParams> {
  BaitSearchNotifier() : super(const BaitSearchParams(isCrappieSpecific: true));

  void updateCategory(BaitCategory? category) {
    state = state.copyWith(category: category);
  }

  void updateBrand(String? brandId) {
    state = state.copyWith(brandId: brandId);
  }

  void updateCrappieFilter(bool? isCrappieSpecific) {
    state = state.copyWith(isCrappieSpecific: isCrappieSpecific);
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query?.isEmpty == true ? null : query);
  }

  void clearFilters() {
    state = const BaitSearchParams(isCrappieSpecific: true);
  }
}

final baitSearchProvider = StateNotifierProvider<BaitSearchNotifier, BaitSearchParams>((ref) {
  return BaitSearchNotifier();
});

// ============================================================================
// MAIN BAIT BROWSER SCREEN
// ============================================================================

class BaitBrowserScreen extends ConsumerWidget {
  const BaitBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchParams = ref.watch(baitSearchProvider);
    final baitsAsync = ref.watch(baitCatalogProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bait Catalog'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                ref.read(baitSearchProvider.notifier).updateSearchQuery(value);
              },
              decoration: InputDecoration(
                hintText: 'Search baits...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Active filters
          _buildActiveFilters(context, ref, searchParams),
          
          // Bait list
          Expanded(
            child: baitsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64),
                    const SizedBox(height: 16),
                    Text('Error loading baits: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.refresh(baitCatalogProvider(searchParams)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (baits) {
                if (baits.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return _buildBaitGrid(context, ref, baits);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const SubmitBaitReportScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_location),
        label: const Text('Report Bait'),
      ),
    );
  }

  Widget _buildActiveFilters(BuildContext context, WidgetRef ref, BaitSearchParams params) {
    final hasFilters = params.category != null || 
                      params.brandId != null || 
                      params.searchQuery != null;

    if (!hasFilters) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      child: Row(
        children: [
          const Text('Filters: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (params.category != null)
                  _buildFilterChip(
                    context,
                    params.category!.displayName,
                    () => ref.read(baitSearchProvider.notifier).updateCategory(null),
                  ),
                if (params.brandId != null)
                  _buildFilterChip(
                    context,
                    'Brand Filter',
                    () => ref.read(baitSearchProvider.notifier).updateBrand(null),
                  ),
                if (params.searchQuery != null)
                  _buildFilterChip(
                    context,
                    '"${params.searchQuery}"',
                    () => ref.read(baitSearchProvider.notifier).updateSearchQuery(null),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => ref.read(baitSearchProvider.notifier).clearFilters(),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
      ),
    );
  }

  Widget _buildBaitGrid(BuildContext context, WidgetRef ref, List<Bait> baits) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: baits.length,
      itemBuilder: (context, index) => _buildBaitCard(context, baits[index]),
    );
  }

  Widget _buildBaitCard(BuildContext context, Bait bait) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BaitDetailScreen(baitId: bait.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: bait.hasImage
                    ? CachedNetworkImage(
                        imageUrl: bait.primaryImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => _buildPlaceholderImage(bait.category),
                      )
                    : _buildPlaceholderImage(bait.category),
              ),
            ),
            
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand and name
                    if (bait.brand != null) ...[
                      Text(
                        bait.brand!.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                    
                    Text(
                      bait.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const Spacer(),
                    
                    // Category and price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              bait.category.icon,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              bait.category.displayName,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (bait.retailPriceUsd != null)
                          Text(
                            bait.priceDisplay,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(BaitCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No baits found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters or search terms',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.read(baitSearchProvider.notifier).clearFilters(),
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _BaitFilterSheet(),
    );
  }
}

// ============================================================================
// FILTER BOTTOM SHEET
// ============================================================================

class _BaitFilterSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(baitBrandsProvider);
    final searchParams = ref.watch(baitSearchProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Baits',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Category filter
          Text(
            'Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: searchParams.category == null,
                onSelected: (_) {
                  ref.read(baitSearchProvider.notifier).updateCategory(null);
                },
              ),
              ...BaitCategory.values.map((category) {
                return FilterChip(
                  label: Text(category.displayName),
                  selected: searchParams.category == category,
                  onSelected: (_) {
                    ref.read(baitSearchProvider.notifier).updateCategory(category);
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 16),
          
          // Brand filter
          Text(
            'Brand',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          brandsAsync.when(
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Error loading brands'),
            data: (brands) => Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All Brands'),
                  selected: searchParams.brandId == null,
                  onSelected: (_) {
                    ref.read(baitSearchProvider.notifier).updateBrand(null);
                  },
                ),
                ...brands.map((brand) {
                  return FilterChip(
                    label: Text(brand.name),
                    selected: searchParams.brandId == brand.id,
                    onSelected: (_) {
                      ref.read(baitSearchProvider.notifier).updateBrand(brand.id);
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Crappie-specific toggle
          CheckboxListTile(
            title: const Text('Crappie-Specific Only'),
            value: searchParams.isCrappieSpecific ?? false,
            onChanged: (value) {
              ref.read(baitSearchProvider.notifier).updateCrappieFilter(value);
            },
          ),
          
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}