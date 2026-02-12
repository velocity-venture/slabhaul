import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_shell.dart';
import '../features/map/screens/attractor_map_screen.dart';
import '../features/weather/screens/weather_dashboard_screen.dart';
import '../features/calculator/screens/calculator_screen.dart';
import '../features/knowledge_base/screens/knowledge_base_screen.dart';
import '../features/bait_recommendations/screens/bait_recommendations_screen.dart';
import '../features/hotspots/screens/best_areas_screen.dart';
import '../features/lake_level/screens/lake_level_screen.dart';
import '../features/clarity/screens/water_clarity_screen.dart';
import '../features/generation/screens/generation_detail_screen.dart';
import '../features/tides/screens/tides_screen.dart';
import '../features/auth/screens/profile_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/trip_log/screens/trip_list_screen.dart';
import '../features/trip_log/screens/active_trip_screen.dart';
import '../features/trip_log/screens/trip_detail_screen.dart';
import '../features/trip_log/screens/trip_insights_screen.dart';
import '../features/trip_planner/screens/smart_trip_planner_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/map',
  routes: [
    GoRoute(
      path: '/login',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LoginScreen(),
    ),
    // Bait Recommendations - accessible from any screen
    GoRoute(
      path: '/bait-recommendations',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BaitRecommendationsScreen(),
    ),
    // Best Areas / Hotspots - accessible from any screen
    GoRoute(
      path: '/best-areas',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BestAreasScreen(),
    ),
    // Lake Level - detailed water level view
    GoRoute(
      path: '/lake-level',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const LakeLevelScreen(),
    ),
    // Water Clarity - clarity estimation and zones
    GoRoute(
      path: '/water-clarity',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WaterClarityScreen(),
    ),
    // Dam Generation - detailed generation view with history
    GoRoute(
      path: '/generation',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const GenerationDetailScreen(),
    ),
    // Tides - detailed tide conditions for coastal waters
    GoRoute(
      path: '/tides',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TidesScreen(),
    ),
    // Smart Trip Planner - AI fishing recommendations
    GoRoute(
      path: '/trip-planner',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final lakeName = state.uri.queryParameters['lake'];
        return SmartTripPlannerScreen(lakeName: lakeName);
      },
    ),
    // Trip Log - catch tracking
    GoRoute(
      path: '/trips',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TripListScreen(),
    ),
    GoRoute(
      path: '/trip/active',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ActiveTripScreen(),
    ),
    GoRoute(
      path: '/trip/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final tripId = state.pathParameters['id']!;
        return TripDetailScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/insights',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TripInsightsScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/map',
              builder: (context, state) => const AttractorMapScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/weather',
              builder: (context, state) => const WeatherDashboardScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/calculator',
              builder: (context, state) => const CalculatorScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/learn',
              builder: (context, state) => const KnowledgeBaseScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
