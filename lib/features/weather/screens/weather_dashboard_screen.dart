import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class WeatherDashboardScreen extends ConsumerWidget {
  const WeatherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherDataProvider);
    final lakeAsync = ref.watch(lakeConditionsProvider);

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

                  // Lake Conditions
                  lakeAsync.when(
                    data: (conditions) =>
                        LakeConditionsCard(conditions: conditions),
                    loading: () => const _WeatherSkeleton(height: 260),
                    error: (err, _) => _ErrorSection(
                      message: 'Could not load lake conditions',
                      onRetry: () => ref.invalidate(lakeConditionsProvider),
                    ),
                  ),
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
