import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';
import 'package:slabhaul/features/map/providers/wind_providers.dart';
import 'package:slabhaul/features/map/providers/hotspot_providers.dart';
import 'package:slabhaul/features/map/widgets/attractor_bottom_sheet.dart';
import 'package:slabhaul/features/map/widgets/attractor_filter_bar.dart';
import 'package:slabhaul/features/map/widgets/attractor_marker.dart';
import 'package:slabhaul/features/map/widgets/hotspot_marker.dart';
import 'package:slabhaul/features/map/widgets/hotspot_bottom_sheet.dart';
import 'package:slabhaul/features/map/widgets/lake_selector.dart';
import 'package:slabhaul/features/map/widgets/wind_overlay.dart';
import 'package:slabhaul/features/map/widgets/wind_effects_layer.dart';
import 'package:slabhaul/features/map/widgets/wind_forecast_slider.dart';

/// Full-screen map showing fish attractor locations with clustering, filtering,
/// wind effects visualization, and forecast slider.
class AttractorMapScreen extends ConsumerStatefulWidget {
  const AttractorMapScreen({super.key});

  @override
  ConsumerState<AttractorMapScreen> createState() =>
      _AttractorMapScreenState();
}

class _AttractorMapScreenState extends ConsumerState<AttractorMapScreen>
    with TickerProviderStateMixin {
  late final MapController _mapController;
  bool _showWindPanel = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Smoothly animate the map to a new centre / zoom using a simple tween
  /// driven by [AnimationController].
  void _animatedMove(LatLng dest, double zoom) {
    final camera = _mapController.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: dest.latitude);
    final lngTween =
        Tween<double>(begin: camera.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: zoom);

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final animation =
        CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredAttractorsProvider);
    final selectedAttractor = ref.watch(selectedAttractorProvider);
    final lakesAsync = ref.watch(lakesProvider);
    final windEnabled = ref.watch(windEnabledProvider);
    final effectsEnabled = ref.watch(windEffectsLayerEnabledProvider);
    final hotspotsEnabled = ref.watch(hotspotsEnabledProvider);
    final rankedHotspotsAsync = ref.watch(rankedHotspotsProvider);
    final selectedHotspot = ref.watch(selectedHotspotProvider);

    // When the selected lake changes, animate the map to the lake centre.
    ref.listen<String?>(selectedLakeProvider, (previous, next) {
      if (next == null) {
        _animatedMove(
          LatLng(MapDefaults.defaultLat, MapDefaults.defaultLon),
          MapDefaults.defaultZoom,
        );
        return;
      }

      final lakesValue = lakesAsync.valueOrNull;
      if (lakesValue == null) return;

      final lake = lakesValue.where((l) => l.id == next).firstOrNull;
      if (lake != null) {
        _animatedMove(
          LatLng(lake.centerLat, lake.centerLon),
          lake.zoomLevel,
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // ----- Map layer -----
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  LatLng(MapDefaults.defaultLat, MapDefaults.defaultLon),
              initialZoom: MapDefaults.defaultZoom,
              maxZoom: 18.0,
              minZoom: 5.0,
              onTap: (_, __) {
                // Dismiss the bottom sheets on map tap.
                ref.read(selectedAttractorProvider.notifier).state = null;
                ref.read(selectedHotspotProvider.notifier).state = null;
                setState(() {
                  _showWindPanel = false;
                });
              },
            ),
            children: [
              // Base tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.slabhaul.app',
                maxZoom: 18,
                tileBuilder: _darkTileBuilder,
              ),

              // Wind effects layer (bank colors, arrows, calm pockets)
              // Rendered BEFORE markers so markers appear on top
              const WindEffectsLayer(),

              // Attractor markers with clustering
              filteredAsync.when(
                data: (attractors) {
                  final markers = attractors.map((attractor) {
                    return Marker(
                      point:
                          LatLng(attractor.latitude, attractor.longitude),
                      width: 36,
                      height: 36,
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedHotspotProvider.notifier).state = null;
                          ref.read(selectedAttractorProvider.notifier).state =
                              attractor;
                        },
                        child: AttractorMarker(type: attractor.type),
                      ),
                    );
                  }).toList();

                  return MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      maxClusterRadius: 80,
                      size: const Size(44, 44),
                      markers: markers,
                      builder: (context, clusterMarkers) {
                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.85),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.teal.withOpacity(0.4),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            clusterMarkers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const MarkerLayer(markers: []),
                error: (_, __) => const MarkerLayer(markers: []),
              ),

              // Hotspot markers (shown when enabled)
              if (hotspotsEnabled)
                rankedHotspotsAsync.when(
                  data: (ratings) {
                    final markers = ratings.asMap().entries.map((entry) {
                      final index = entry.key;
                      final rating = entry.value;
                      return Marker(
                        point: LatLng(
                          rating.hotspot.latitude,
                          rating.hotspot.longitude,
                        ),
                        width: index < 3 ? 48 : 36,
                        height: index < 3 ? 48 : 36,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(selectedAttractorProvider.notifier).state = null;
                            ref.read(selectedHotspotProvider.notifier).state = rating;
                          },
                          child: HotspotMarker(
                            rating: rating,
                            rank: index + 1,
                          ),
                        ),
                      );
                    }).toList();

                    return MarkerLayer(markers: markers);
                  },
                  loading: () => const MarkerLayer(markers: []),
                  error: (_, __) => const MarkerLayer(markers: []),
                ),
            ],
          ),

          // ----- Overlays on top of the map -----

          // Lake selector + filter bar
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const LakeSelector(),
                const SizedBox(height: 6),
                const AttractorFilterBar(),
              ],
            ),
          ),

          // Wind overlay card (conditionally shown)
          GestureDetector(
            onTap: () {
              if (windEnabled) {
                setState(() {
                  _showWindPanel = !_showWindPanel;
                });
              }
            },
            child: const WindOverlay(),
          ),

          // Wind forecast slider (shown when wind is enabled)
          if (windEnabled)
            Positioned(
              bottom: selectedAttractor != null ? 220 : 90,
              left: 0,
              right: 70, // Leave room for the wind overlay
              child: const WindForecastSlider(),
            ),

          // Wind effects legend (shown when effects layer is enabled)
          if (windEnabled && effectsEnabled)
            Positioned(
              top: MediaQuery.of(context).padding.top + 170,
              right: 12,
              child: const WindEffectsLegend(),
            ),

          // Extended wind analysis panel (shown on tap)
          if (_showWindPanel && windEnabled)
            Positioned(
              bottom: 100,
              left: 12,
              right: 12,
              child: const WindAnalysisPanel(),
            ),

          // Count badges
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Attractor count
                filteredAsync.when(
                  data: (attractors) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      '${attractors.length} attractors',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // Hotspot count (when enabled)
                if (hotspotsEnabled)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: rankedHotspotsAsync.when(
                      data: (ratings) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.warning.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              size: 14,
                              color: AppColors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${ratings.length} hotspots',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                  ),
              ],
            ),
          ),

          // Loading indicator while attractors load
          if (filteredAsync.isLoading)
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ),

          // Error indicator
          if (filteredAsync.hasError)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Failed to load attractors',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(attractorsProvider),
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: AppColors.teal),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Attractor bottom sheet
          if (selectedAttractor != null) const AttractorBottomSheet(),

          // Hotspot bottom sheet
          if (selectedHotspot != null) const HotspotBottomSheet(),
        ],
      ),

      // FAB stack for map controls
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Best Areas button - navigate to ranked list
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton.small(
              heroTag: 'best_areas',
              backgroundColor: AppColors.success,
              onPressed: () => context.push('/best-areas'),
              tooltip: 'Best Areas',
              child: const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          // Hotspots toggle
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: FloatingActionButton(
              mini: true,
              heroTag: 'hotspots_toggle',
              backgroundColor:
                  hotspotsEnabled ? AppColors.warning : AppColors.card,
              onPressed: () {
                ref.read(hotspotsEnabledProvider.notifier).state = !hotspotsEnabled;
              },
              tooltip: hotspotsEnabled ? 'Hide hotspots' : 'Show hotspots',
              child: Icon(
                Icons.local_fire_department,
                color: hotspotsEnabled ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          // Wind effects toggle (only shown when wind is enabled)
          if (windEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton(
                mini: true,
                heroTag: 'wind_effects',
                backgroundColor:
                    effectsEnabled ? AppColors.tealDark : AppColors.card,
                onPressed: () {
                  ref.read(windEffectsLayerEnabledProvider.notifier).state = 
                      !effectsEnabled;
                },
                tooltip: effectsEnabled 
                    ? 'Hide bank effects' 
                    : 'Show bank effects',
                child: Icon(
                  Icons.layers,
                  color: effectsEnabled ? Colors.white : AppColors.textSecondary,
                  size: 20,
                ),
              ),
            ),
          
          // Main wind toggle
          FloatingActionButton(
            mini: true,
            heroTag: 'wind_toggle',
            backgroundColor:
                windEnabled ? AppColors.teal : AppColors.card,
            onPressed: () {
              ref.read(windEnabledProvider.notifier).state = !windEnabled;
              if (!windEnabled) {
                // Reset time selection when enabling
                ref.read(selectedWindTimeProvider.notifier).state = null;
              }
            },
            tooltip: windEnabled ? 'Hide wind overlay' : 'Show wind overlay',
            child: Icon(
              Icons.air,
              color: windEnabled ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  /// Applies a dark colour filter to the OSM tiles so they blend with the
  /// app's dark theme.
  Widget _darkTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.40, 0, 0, 0, 0, //
        0, 0.40, 0, 0, 0, //
        0, 0, 0.50, 0, 0, //
        0, 0, 0, 1, 0, //
      ]),
      child: tileWidget,
    );
  }
}
