import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/core/utils/solunar_calculator.dart';
import 'package:slabhaul/core/utils/time_ago.dart';
import 'package:slabhaul/core/utils/weather_utils.dart';
import 'package:slabhaul/shared/widgets/glass_container.dart';
import 'package:slabhaul/shared/widgets/skeleton_loader.dart';
import 'package:slabhaul/features/weather/providers/weather_providers.dart';
import 'package:slabhaul/features/weather/providers/lake_conditions_providers.dart';
import 'package:slabhaul/features/weather/widgets/current_conditions_card.dart';
import 'package:slabhaul/features/weather/widgets/barometric_trend_card.dart';
import 'package:slabhaul/features/weather/widgets/sun_moon_card.dart';
import 'package:slabhaul/features/weather/widgets/hourly_forecast_strip.dart';
import 'package:slabhaul/features/weather/widgets/seven_day_forecast.dart';
import 'package:slabhaul/features/weather/widgets/lake_conditions_card.dart';
import 'package:slabhaul/features/weather/widgets/thermocline_card.dart';
import 'package:slabhaul/features/weather/providers/thermocline_providers.dart';
import 'package:slabhaul/features/weather/widgets/solunar_card.dart';
import 'package:slabhaul/features/weather/providers/solunar_providers.dart';
import 'package:slabhaul/features/settings/providers/tournament_mode_provider.dart';
import 'package:slabhaul/features/generation/providers/generation_lake_provider.dart';
import 'package:slabhaul/features/generation/widgets/generation_status_card.dart';
import 'package:slabhaul/features/tides/providers/tides_providers.dart';
import 'package:slabhaul/features/tides/widgets/tide_card.dart';

class WeatherDashboardScreen extends ConsumerStatefulWidget {
  const WeatherDashboardScreen({super.key});

  @override
  ConsumerState<WeatherDashboardScreen> createState() =>
      _WeatherDashboardScreenState();
}

class _WeatherDashboardScreenState
    extends ConsumerState<WeatherDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(weatherDataProvider);
    final lakeAsync = ref.watch(lakeConditionsProvider);
    final isTournamentMode = ref.watch(tournamentModeProvider);
    final lake = ref.watch(selectedWeatherLakeProvider);
    final solunar = ref.watch(solunarForecastProvider);
    final nextPeriod = ref.watch(nextSolunarPeriodProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // --- 1. Map backdrop ---
          Positioned.fill(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lake.lat, lake.lon),
                initialZoom: 11.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.slabhaul.app',
                  maxZoom: 18,
                  tileBuilder: _darkTileBuilder,
                ),
              ],
            ),
          ),

          // --- 2. Gradient overlays for readability ---
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.65),
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.70),
                    ],
                    stops: const [0.0, 0.25, 0.70, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // --- 3. Floating glass header + compact cards ---
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 4),
                  // Glass header bar
                  GlassContainer(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    borderRadius: 14,
                    opacity: 0.20,
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.teal, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lake.name,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              weatherAsync.maybeWhen(
                                data: (weather) => Text(
                                  'Updated ${formatTimeAgo(weather.fetchedAt)}',
                                  style: const TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 11,
                                  ),
                                ),
                                orElse: () => const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.psychology,
                              color: AppColors.warning, size: 22),
                          onPressed: () => context.push('/trip-planner'),
                          tooltip: 'Smart Trip Planner',
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.refresh,
                              color: AppColors.teal, size: 22),
                          onPressed: () {
                            ref.invalidate(weatherDataProvider);
                            ref.invalidate(lakeConditionsProvider);
                          },
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Two compact summary cards side-by-side
                  Row(
                    children: [
                      Expanded(
                        child: _CompactConditionsCard(
                          weatherAsync: weatherAsync,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _CompactSolunarCard(
                          solunar: solunar,
                          nextPeriod: nextPeriod,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- 4. DraggableScrollableSheet ---
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.12,
            maxChildSize: 0.92,
            snap: true,
            snapSizes: const [0.12, 0.45, 0.92],
            builder: (context, scrollController) {
              return GlassContainer(
                borderRadius: 24,
                opacity: 0.25,
                blurSigma: 18,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    // Drag handle pill
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 10, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // -- All existing cards, each glass-wrapped --
                    // Current Conditions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: weatherAsync.when(
                          data: (weather) => CurrentConditionsCard(
                              weather: weather.current),
                          loading: () => const _WeatherSkeleton(),
                          error: (err, _) => _ErrorSection(
                            message: 'Could not load current conditions',
                            onRetry: () =>
                                ref.invalidate(weatherDataProvider),
                          ),
                        ),
                      ),
                    ),

                    // Barometric Trend
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: weatherAsync.when(
                          data: (weather) =>
                              BarometricTrendCard(hourly: weather.hourly),
                          loading: () => const _WeatherSkeleton(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Sun & Moon
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: weatherAsync.when(
                          data: (weather) {
                            if (weather.daily.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            return SunMoonCard(today: weather.daily.first);
                          },
                          loading: () =>
                              const _WeatherSkeleton(height: 100),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Solunar Fishing Activity
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: SolunarCard(
                            forecast: ref.watch(solunarForecastProvider)),
                      ),
                    ),

                    // Hourly Forecast Strip
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: weatherAsync.when(
                          data: (weather) =>
                              HourlyForecastStrip(hourly: weather.hourly),
                          loading: () => const _HourlyStripSkeleton(),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Seven Day Forecast
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: weatherAsync.when(
                          data: (weather) =>
                              SevenDayForecast(daily: weather.daily),
                          loading: () =>
                              const _WeatherSkeleton(height: 300),
                          error: (err, _) => const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Quick Access Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: _QuickAccessSection(ref: ref),
                    ),

                    // Lake Conditions
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GlassContainer(
                        borderRadius: 14,
                        opacity: 0.18,
                        padding: const EdgeInsets.all(4),
                        child: lakeAsync.when(
                          data: (conditions) => GestureDetector(
                            onTap: () => context.push('/lake-level'),
                            child: Stack(
                              children: [
                                LakeConditionsCard(
                                    conditions: conditions),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Details',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.teal,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(Icons.chevron_right,
                                            size: 14,
                                            color: AppColors.teal),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          loading: () =>
                              const _WeatherSkeleton(height: 260),
                          error: (err, _) => _ErrorSection(
                            message: 'Could not load lake conditions',
                            onRetry: () =>
                                ref.invalidate(lakeConditionsProvider),
                          ),
                        ),
                      ),
                    ),

                    // Dam Generation Status
                    if (ref.watch(hasGenerationTrackingProvider))
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: GlassContainer(
                          borderRadius: 14,
                          opacity: 0.18,
                          padding: const EdgeInsets.all(4),
                          child: ref.watch(lakeGenerationProvider).when(
                            data: (genData) => genData != null
                                ? GestureDetector(
                                    onTap: () =>
                                        context.push('/generation'),
                                    child: Stack(
                                      children: [
                                        GenerationStatusCard(
                                            data: genData),
                                        Positioned(
                                          top: 12,
                                          right: 12,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.teal
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Details',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.teal,
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(Icons.chevron_right,
                                                    size: 14,
                                                    color: AppColors.teal),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            loading: () =>
                                const _WeatherSkeleton(height: 280),
                            error: (err, _) => _ErrorSection(
                              message:
                                  'Could not load generation data',
                              onRetry: () => ref
                                  .invalidate(lakeGenerationProvider),
                            ),
                          ),
                        ),
                      ),

                    // Tide Conditions
                    Builder(
                      builder: (context) {
                        return ref
                            .watch(selectedLakeTideDataProvider)
                            .when(
                          data: (tideData) => tideData != null
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: GlassContainer(
                                    borderRadius: 14,
                                    opacity: 0.18,
                                    padding: const EdgeInsets.all(4),
                                    child: GestureDetector(
                                      onTap: () =>
                                          context.push('/tides'),
                                      child: Stack(
                                        children: [
                                          TideCard(
                                            conditions:
                                                tideData.conditions,
                                            fishingWindows:
                                                tideData.fishingWindows,
                                            hourlyPredictions:
                                                tideData
                                                    .hourlyPredictions,
                                          ),
                                          Positioned(
                                            top: 12,
                                            right: 12,
                                            child: Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.teal
                                                    .withValues(
                                                        alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(4),
                                              ),
                                              child: const Row(
                                                mainAxisSize:
                                                    MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Details',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          AppColors.teal,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  SizedBox(width: 4),
                                                  Icon(
                                                      Icons
                                                          .chevron_right,
                                                      size: 14,
                                                      color:
                                                          AppColors.teal),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (err, _) => const SizedBox.shrink(),
                        );
                      },
                    ),

                    // Thermocline Predictor
                    if (!isTournamentMode)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: GlassContainer(
                          borderRadius: 14,
                          opacity: 0.18,
                          padding: const EdgeInsets.all(4),
                          child: ref.watch(thermoclineDataProvider).when(
                            data: (thermocline) => ThermoclineCard(
                              data: thermocline,
                              maxDepthFt: ref
                                      .watch(selectedWeatherLakeProvider)
                                      .maxDepthFt ??
                                  35,
                            ),
                            loading: () =>
                                const _WeatherSkeleton(height: 340),
                            error: (err, _) => _ErrorSection(
                              message:
                                  'Could not load thermocline prediction',
                              onRetry: () => ref
                                  .invalidate(thermoclineDataProvider),
                            ),
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: _TournamentModeNotice(),
                      ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

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

// ---------------------------------------------------------------------------
// Compact Conditions Card (temp, icon, wind)
// ---------------------------------------------------------------------------

class _CompactConditionsCard extends StatelessWidget {
  final AsyncValue weatherAsync;

  const _CompactConditionsCard({required this.weatherAsync});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 14,
      opacity: 0.22,
      padding: const EdgeInsets.all(12),
      child: weatherAsync.when(
        data: (weather) {
          final current = weather.current;
          return Row(
            children: [
              Icon(
                weatherIcon(current.weatherCode),
                color: AppColors.tealLight,
                size: 28,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${current.temperatureF.round()}°F',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      '${current.windSpeedMph.round()} mph wind',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.teal,
              ),
            ),
          ),
        ),
        error: (_, __) => const SizedBox(
          height: 48,
          child: Center(
            child: Icon(Icons.cloud_off,
                color: AppColors.textMuted, size: 22),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact Solunar Card (moon, rating %, next major window)
// ---------------------------------------------------------------------------

class _CompactSolunarCard extends StatelessWidget {
  final SolunarForecast solunar;
  final SolunarPeriod? nextPeriod;

  const _CompactSolunarCard({
    required this.solunar,
    this.nextPeriod,
  });

  IconData _moonIcon(double phase) {
    if (phase < 0.03 || phase > 0.97) return Icons.dark_mode;
    if (phase < 0.25) return Icons.nightlight_round;
    if (phase < 0.50) return Icons.brightness_2;
    if (phase < 0.53) return Icons.brightness_7;
    return Icons.brightness_3;
  }

  @override
  Widget build(BuildContext context) {
    final ratingPct = (solunar.overallRating * 100).round();
    final nextLabel = nextPeriod != null
        ? '${nextPeriod!.label} ${_formatTime(nextPeriod!.start)}'
        : 'No upcoming';

    return GlassContainer(
      borderRadius: 14,
      opacity: 0.22,
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(
            _moonIcon(solunar.moonPhase),
            color: AppColors.warning,
            size: 26,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$ratingPct% ${solunar.ratingLabel}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  nextLabel,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour < 12 ? 'am' : 'pm';
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min$period';
  }
}

// ---------------------------------------------------------------------------
// Skeleton placeholders
// ---------------------------------------------------------------------------

class _WeatherSkeleton extends StatelessWidget {
  final double height;
  const _WeatherSkeleton({this.height = 140});

  @override
  Widget build(BuildContext context) {
    return SkeletonCard(height: height);
  }
}

class _HourlyStripSkeleton extends StatelessWidget {
  const _HourlyStripSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => const SkeletonCard(height: 120, width: 72),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Inline error section with retry
// ---------------------------------------------------------------------------

class _ErrorSection extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorSection({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: AppColors.error, size: 36),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh,
                    size: 16, color: AppColors.teal),
                label: const Text('Retry',
                    style: TextStyle(color: AppColors.teal)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.teal),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tournament Mode Notice
// ---------------------------------------------------------------------------

class _TournamentModeNotice extends StatelessWidget {
  const _TournamentModeNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tournament Mode Active',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI-assisted features are hidden for fair play. '
                  'Disable in Profile settings.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quick Access Section
// ---------------------------------------------------------------------------

class _QuickAccessSection extends StatelessWidget {
  final WidgetRef ref;

  const _QuickAccessSection({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Access',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.phishing,
                label: 'Bait Tips',
                sublabel: 'What to use',
                color: AppColors.teal,
                onTap: () => context.push('/bait-recommendations'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.local_fire_department,
                label: 'Best Areas',
                sublabel: 'Hot spots',
                color: AppColors.warning,
                onTap: () => context.push('/best-areas'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.water_drop,
                label: 'Lake Level',
                sublabel: 'Trends & tips',
                color: AppColors.info,
                onTap: () => context.push('/lake-level'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAccessCard(
                icon: Icons.map,
                label: 'Map',
                sublabel: 'Attractors',
                color: AppColors.success,
                onTap: () => context.go('/map'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
