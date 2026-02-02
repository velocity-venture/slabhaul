import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/services/supabase_service.dart';
import 'features/settings/providers/tournament_mode_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (fail gracefully)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Initialize Supabase (falls back to local data if unavailable)
  await SupabaseService.initialize();

  // Initialize SharedPreferences for tournament mode and other settings
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Override the tournament mode provider with the initialized SharedPreferences
        tournamentModeProvider.overrideWith(
          (ref) => TournamentModeNotifier(prefs),
        ),
      ],
      child: const SlabHaulApp(),
    ),
  );
}

class SlabHaulApp extends StatelessWidget {
  const SlabHaulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SlabHaul',
      debugShowCheckedModeBanner: false,
      theme: slabHaulDarkTheme,
      routerConfig: goRouter,
    );
  }
}
