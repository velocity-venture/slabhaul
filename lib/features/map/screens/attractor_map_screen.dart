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
import 'package:slabhaul/features/map/providers/streamflow_providers.dart';
import 'package:slabhaul/features/map/widgets/attractor_bottom_sheet.dart';
import 'package:slabhaul/features/map/widgets/attractor_filter_bar.dart';
import 'package:slabhaul/features/map/widgets/attractor_marker.dart';
import 'package:slabhaul/features/map/widgets/hotspot_marker.dart';
import 'package:slabhaul/features/map/widgets/hotspot_bottom_sheet.dart';
import 'package:slabhaul/features/map/widgets/lake_selector.dart';
import 'package:slabhaul/features/map/widgets/wind_overlay.dart';
import 'package:slabhaul/features/map/widgets/wind_effects_layer.dart';
import 'package:slabhaul/features/map/widgets/wind_forecast_slider.dart';
import 'package:slabhaul/features/map/widgets/clarity_override_bar.dart';
import 'package:slabhaul/features/map/widgets/inflow_layer.dart';
import 'package:slabhaul/features/map/widgets/streamflow_bottom_sheet.dart';
import 'package:slabhaul/features/map/providers/clarity_override_provider.dart';

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
    final streamflowEnabled = ref.watch(streamflowEnabledProvider);
    final selectedInflow = ref.watch(selectedInflowProvider);
    final effectiveClarity = ref.watch(effectiveClarityProvider).valueOrNull;

    // When the selected lake changes, animate the map to the lake centre.
    ref.listen<String?>(selectedLakeProvider, (previous, next) {
      if (next == null) {
        _animatedMove(
          const LatLng(MapDefaults.defaultLat, MapDefaults.defaultLon),
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
                  const LatLng(MapDefaults.defaultLat, MapDefaults.defaultLon),
              initialZoom: MapDefaults.defaultZoom,
              maxZoom: 18.0,
              minZoom: 5.0,
              onTap: (_, __) {
                // Dismiss the bottom sheets on map tap.
                ref.read(selectedAttractorProvider.notifier).state = null;
                ref.read(selectedHotspotProvider.notifier).state = null;
                ref.read(selectedInflowProvider.notifier).state = null;
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
              ),

              // Wind effects layer (bank colors, arrows, calm pockets)
              // Rendered BEFORE markers so markers appear on top
              const WindEffectsLayer(),

              // Inflow/Streamflow layer (flow markers, direction lines)
              const InflowLayer(),

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
                        child: AttractorMarker(
                          type: attractor.type,
                          clarityLevel: effectiveClarity,
                        ),
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
                            color: AppColors.teal.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.teal.withValues(alpha: 0.4),
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

          // Lake selector + filter bar with white scrim
          SafeArea(
            bottom: false,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xE6FFFFFF), // white 90%
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, bottom: 6),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/slabhaul_icon.png',
                          width: 28,
                          height: 28,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'SlabHaul',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LakeSelector(),
                  SizedBox(height: 6),
                  AttractorFilterBar(),
                  SizedBox(height: 8),
                  ClarityOverrideBar(),
                  SizedBox(height: 8),
                ],
              ),
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
              top: MediaQuery.of(context).padding.top + 200,
              right: 12,
              child: const WindEffectsLegend(),
            ),

          // Extended wind analysis panel (shown on tap)
          if (_showWindPanel && windEnabled)
            const Positioned(
              bottom: 100,
              left: 12,
              right: 12,
              child: WindAnalysisPanel(),
            ),

          // Count badges
          Positioned(
            top: MediaQuery.of(context).padding.top + 160,
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
                      color: const Color(0xE6FFFFFF),
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
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.4),
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
                  color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.4),
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

          // Streamflow bottom sheet
          if (selectedInflow != null) const StreamflowBottomSheet(),

          // Streamflow overlay (compact info display)
          if (streamflowEnabled) const StreamflowOverlay(),

          // Streamflow legend (when enabled)
          if (streamflowEnabled)
            Positioned(
              top: MediaQuery.of(context).padding.top + (windEnabled && effectsEnabled ? 310 : 200),
              right: 12,
              child: const InflowLayerLegend(),
            ),
        ],
      ),

      // Compact map layer controls — a single menu FAB
      floatingActionButton: _MapLayerMenu(
        windEnabled: windEnabled,
        effectsEnabled: effectsEnabled,
        hotspotsEnabled: hotspotsEnabled,
        streamflowEnabled: streamflowEnabled,
        onToggleWind: () {
          ref.read(windEnabledProvider.notifier).state = !windEnabled;
          if (!windEnabled) {
            ref.read(selectedWindTimeProvider.notifier).state = null;
          }
        },
        onToggleEffects: () {
          ref.read(windEffectsLayerEnabledProvider.notifier).state = !effectsEnabled;
        },
        onToggleHotspots: () {
          ref.read(hotspotsEnabledProvider.notifier).state = !hotspotsEnabled;
        },
        onToggleStreamflow: () {
          ref.read(streamflowEnabledProvider.notifier).state = !streamflowEnabled;
        },
        onBestAreas: () => context.push('/best-areas'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

}

/// Collapsible layer control menu — a single FAB that expands into toggle chips.
class _MapLayerMenu extends StatefulWidget {
  final bool windEnabled;
  final bool effectsEnabled;
  final bool hotspotsEnabled;
  final bool streamflowEnabled;
  final VoidCallback onToggleWind;
  final VoidCallback onToggleEffects;
  final VoidCallback onToggleHotspots;
  final VoidCallback onToggleStreamflow;
  final VoidCallback onBestAreas;

  const _MapLayerMenu({
    required this.windEnabled,
    required this.effectsEnabled,
    required this.hotspotsEnabled,
    required this.streamflowEnabled,
    required this.onToggleWind,
    required this.onToggleEffects,
    required this.onToggleHotspots,
    required this.onToggleStreamflow,
    required this.onBestAreas,
  });

  @override
  State<_MapLayerMenu> createState() => _MapLayerMenuState();
}

class _MapLayerMenuState extends State<_MapLayerMenu> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (!_expanded) {
      // Collapsed: just the menu button
      return FloatingActionButton.small(
        heroTag: 'layer_menu',
        backgroundColor: AppColors.surface,
        onPressed: () => setState(() => _expanded = true),
        tooltip: 'Map Layers',
        child: const Icon(Icons.layers, color: AppColors.teal, size: 22),
      );
    }

    // Expanded: show layer toggles in a compact card
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => setState(() => _expanded = false),
              child: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 4),
          _LayerToggle(
            icon: Icons.air,
            label: 'Wind',
            active: widget.windEnabled,
            onTap: widget.onToggleWind,
          ),
          if (widget.windEnabled)
            _LayerToggle(
              icon: Icons.layers,
              label: 'Bank Effects',
              active: widget.effectsEnabled,
              onTap: widget.onToggleEffects,
            ),
          _LayerToggle(
            icon: Icons.local_fire_department,
            label: 'Hotspots',
            active: widget.hotspotsEnabled,
            activeColor: AppColors.warning,
            onTap: widget.onToggleHotspots,
          ),
          _LayerToggle(
            icon: Icons.water,
            label: 'Streamflow',
            active: widget.streamflowEnabled,
            activeColor: AppColors.info,
            onTap: widget.onToggleStreamflow,
          ),
          const Divider(height: 12, color: AppColors.cardBorder),
          GestureDetector(
            onTap: widget.onBestAreas,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_fire_department, size: 16, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Best Areas',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? activeColor;
  final VoidCallback onTap;

  const _LayerToggle({
    required this.icon,
    required this.label,
    required this.active,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? (activeColor ?? AppColors.teal) : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: active ? color : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              active ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
