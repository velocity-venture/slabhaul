import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slabhaul/core/utils/constants.dart';
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

class WeatherDashboardScreen extends ConsumerWidget {
  const WeatherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherDataProvider);
    final lakeAsync = ref.watch(lakeConditionsProvider);
    final isTournamentMode = ref.watch(tournamentModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.teal,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(weatherDataProvider);
          ref.invalidate(lakeConditionsProvider);
          // Wait for the refresh to complete before dismissing indicator.
          await ref.read(weatherDataProvider.future);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: AppColors.surface,
              title: const Text(
                'Weather Dashboard',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppColors.teal),
                  onPressed: () {
                    ref.invalidate(weatherDataProvider);
                    ref.invalidate(lakeConditionsProvider);
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Location header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.teal, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          ref.watch(selectedWeatherLakeProvider).name,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Current Conditions
                  weatherAsync.when(
                    data: (weather) =>
                        CurrentConditionsCard(weather: weather.current),
                    loading: () => const _WeatherSkeleton(),
                    error: (err, _) => _ErrorSection(
                      message: 'Could not load current conditions',
                      onRetry: () => ref.invalidate(weatherDataProvider),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Barometric Trend
                  weatherAsync.when(
                    data: (weather) =>
                        BarometricTrendCard(hourly: weather.hourly),
                    loading: () => const _WeatherSkeleton(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),

                  // Sun & Moon
                  weatherAsync.when(
                    data: (weather) {
                      if (weather.daily.isEmpty) return const SizedBox.shrink();
                      return SunMoonCard(today: weather.daily.first);
                    },
                    loading: () => const _WeatherSkeleton(height: 100),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),

                  // Solunar Fishing Activity
                  SolunarCard(forecast: ref.watch(solunarForecastProvider)),
                  const SizedBox(height: 12),

                  // Hourly Forecast Strip
                  weatherAsync.when(
                    data: (weather) =>
                        HourlyForecastStrip(hourly: weather.hourly),
                    loading: () => const _HourlyStripSkeleton(),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),

                  // Seven Day Forecast
                  weatherAsync.when(
                    data: (weather) =>
                        SevenDayForecast(daily: weather.daily),
                    loading: () => const _WeatherSkeleton(height: 300),
                    error: (err, _) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 12),

                  // Quick Access Cards
                  _QuickAccessSection(ref: ref),
                  const SizedBox(height: 12),

                  // Lake Conditions (tappable to detailed view)
                  lakeAsync.when(
                    data: (conditions) => GestureDetector(
                      onTap: () => context.push('/lake-level'),
                      child: Stack(
                        children: [
                          LakeConditionsCard(conditions: conditions),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
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
                                      size: 14, color: AppColors.teal),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const _WeatherSkeleton(height: 260),
                    error: (err, _) => _ErrorSection(
                      message: 'Could not load lake conditions',
                      onRetry: () => ref.invalidate(lakeConditionsProvider),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dam Generation Status (for TVA lakes) - tappable for details
                  if (ref.watch(hasGenerationTrackingProvider))
                    ref.watch(lakeGenerationProvider).when(
                      data: (genData) => genData != null
                          ? GestureDetector(
                              onTap: () => context.push('/generation'),
                              child: Stack(
                                children: [
                                  GenerationStatusCard(data: genData),
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.teal.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
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
                                              size: 14, color: AppColors.teal),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                      loading: () => const _WeatherSkeleton(height: 280),
                      error: (err, _) => _ErrorSection(
                        message: 'Could not load generation data',
                        onRetry: () => ref.invalidate(lakeGenerationProvider),
                      ),
                    ),
                  if (ref.watch(hasGenerationTrackingProvider))
                    const SizedBox(height: 12),

                  // Tide Conditions (for tidal/coastal waters) - tappable for details
                  ref.watch(selectedLakeTideDataProvider).when(
                    data: (tideData) => tideData != null
                        ? GestureDetector(
                            onTap: () => context.push('/tides'),
                            child: Stack(
                              children: [
                                TideCard(
                                  conditions: tideData.conditions,
                                  fishingWindows: tideData.fishingWindows,
                                  hourlyPredictions: tideData.hourlyPredictions,
                                ),
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.teal.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
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
                                            size: 14, color: AppColors.teal),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(), // Don't show skeleton for non-tidal lakes
                    error: (err, _) => const SizedBox.shrink(), // Silently fail for non-tidal
                  ),
                  // Only add spacing if tidal data is present
                  Builder(
                    builder: (context) {
                      final tideData = ref.watch(selectedLakeTideDataProvider);
                      return tideData.maybeWhen(
                        data: (data) => data != null 
                            ? const SizedBox(height: 12) 
                            : const SizedBox.shrink(),
                        orElse: () => const SizedBox.shrink(),
                      );
                    },
                  ),

                  // Thermocline Predictor (hidden in tournament mode)
                  if (!isTournamentMode)
                    ref.watch(thermoclineDataProvider).when(
                      data: (thermocline) => ThermoclineCard(
                        data: thermocline,
                        maxDepthFt: ref.watch(selectedWeatherLakeProvider).maxDepthFt ?? 35,
                      ),
                      loading: () => const _WeatherSkeleton(height: 340),
                      error: (err, _) => _ErrorSection(
                        message: 'Could not load thermocline prediction',
                        onRetry: () => ref.invalidate(thermoclineDataProvider),
                      ),
                    )
                  else
                    const _TournamentModeNotice(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
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
                icon: const Icon(Icons.refresh, size: 16, color: AppColors.teal),
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
// Tournament Mode Notice (shown when AI features are hidden)
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
// Quick Access Section - Cards for navigating to detailed features
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
