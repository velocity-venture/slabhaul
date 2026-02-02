import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../map/providers/map_providers.dart';
import '../../map/providers/hotspot_providers.dart';
import '../widgets/hotspot_list_card.dart';
import '../widgets/conditions_summary_bar.dart';

/// Screen showing ranked list of best fishing areas for current conditions.
class BestAreasScreen extends ConsumerWidget {
  const BestAreasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rankedAsync = ref.watch(rankedHotspotsProvider);
    final lakesAsync = ref.watch(lakesProvider);
    final selectedLake = ref.watch(selectedLakeProvider);
    final conditions = ref.watch(currentConditionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Best Areas',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Lake filter
          lakesAsync.when(
            data: (lakes) => PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
              tooltip: 'Filter by lake',
              onSelected: (value) {
                ref.read(selectedLakeProvider.notifier).state = value;
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: null,
                  child: Text('All Lakes'),
                ),
                const PopupMenuDivider(),
                ...lakes.where((l) => l.attractorCount > 0 || true).map(
                      (lake) => PopupMenuItem(
                        value: lake.id,
                        child: Text(lake.displayName),
                      ),
                    ),
              ],
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Current conditions summary
          ConditionsSummaryBar(conditions: conditions),

          // Lake filter indicator
          if (selectedLake != null)
            lakesAsync.when(
              data: (lakes) {
                final lake =
                    lakes.where((l) => l.id == selectedLake).firstOrNull;
                if (lake == null) return const SizedBox.shrink();
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.water,
                        size: 16,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        lake.displayName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          ref.read(selectedLakeProvider.notifier).state = null;
                        },
                        child: const Row(
                          children: [
                            Text(
                              'Clear',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.teal,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(Icons.close, size: 14, color: AppColors.teal),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // Ranked hotspots list
          Expanded(
            child: rankedAsync.when(
              data: (ratings) {
                if (ratings.isEmpty) {
                  return _EmptyState(selectedLake: selectedLake);
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ratings.length,
                  itemBuilder: (context, index) {
                    final rating = ratings[index];
                    return HotspotListCard(
                      rating: rating,
                      rank: index + 1,
                      onTap: () {
                        // Navigate to map centered on this hotspot
                        ref.read(selectedHotspotProvider.notifier).state =
                            rating;
                        // Set lake filter to match
                        ref.read(selectedLakeProvider.notifier).state =
                            rating.hotspot.lakeId;
                        context.go('/map');
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load hotspots',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(rankedHotspotsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String? selectedLake;

  const _EmptyState({this.selectedLake});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            selectedLake != null
                ? 'No hotspots for this lake yet'
                : 'No hotspots available',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedLake != null
                ? 'Try selecting a different lake\nor check back later'
                : 'Hotspot data is coming soon',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
