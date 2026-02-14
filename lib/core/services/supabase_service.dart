import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_logger.dart';

class SupabaseService {
  static bool _initialized = false;
  static bool get isAvailable => _initialized;

  static SupabaseClient? get client =>
      _initialized ? Supabase.instance.client : null;

  static Future<void> initialize() async {
    const urlFromDefine = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const anonKeyFromDefine =
        String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    final url = urlFromDefine.isNotEmpty ? urlFromDefine : (dotenv.env['SUPABASE_URL'] ?? '');
    final anonKey =
        anonKeyFromDefine.isNotEmpty ? anonKeyFromDefine : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');

    if (url.isEmpty || anonKey.isEmpty) {
      AppLogger.warn('SupabaseService', 'Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
      _initialized = false;
      return;
    }

    try {
      await Supabase.initialize(url: url, anonKey: anonKey);
      _initialized = true;
      AppLogger.info('SupabaseService', 'Initialized successfully');
    } catch (e, st) {
      AppLogger.error('SupabaseService', 'initialize', e, st);
      _initialized = false;
    }
  }
}
