import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';

/// Current auth user (null if guest / Supabase unavailable).
final authUserProvider = StreamProvider<User?>((ref) {
  final client = SupabaseService.client;
  if (client == null) return Stream.value(null);
  return client.auth.onAuthStateChange.map((event) => event.session?.user);
});

/// Whether the user is logged in.
final isLoggedInProvider = Provider<bool>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  return user != null;
});

/// Display name for the current user.
final displayNameProvider = Provider<String>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return 'Guest Angler';
  return user.userMetadata?['full_name'] as String? ??
      user.email?.split('@').first ??
      'Angler';
});

/// Auth actions notifier.
class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier() : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    final client = SupabaseService.client;
    if (client == null) {
      state = AsyncValue.error(
        'Supabase not configured. Running in guest mode.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await client.auth.signInWithPassword(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUpWithEmail(String email, String password) async {
    final client = SupabaseService.client;
    if (client == null) {
      state = AsyncValue.error(
        'Supabase not configured. Running in guest mode.',
        StackTrace.current,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      await client.auth.signUp(email: email, password: password);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signInWithOAuth(OAuthProvider provider) async {
    final client = SupabaseService.client;
    if (client == null) return;

    state = const AsyncValue.loading();
    try {
      await client.auth.signInWithOAuth(provider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    final client = SupabaseService.client;
    if (client == null) return;

    state = const AsyncValue.loading();
    try {
      await client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
  (ref) => AuthNotifier(),
);
