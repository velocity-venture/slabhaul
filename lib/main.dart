import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (fail gracefully)
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}

  // Initialize Supabase (falls back to local data if unavailable)
  await SupabaseService.initialize();

  runApp(const ProviderScope(child: SlabHaulApp()));
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
