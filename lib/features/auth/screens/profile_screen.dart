import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/constants.dart';
import '../../../core/services/supabase_service.dart';
import '../providers/auth_providers.dart';
import '../../settings/widgets/tournament_mode_toggle.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final displayName = ref.watch(displayNameProvider);
    final userAsync = ref.watch(authUserProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Avatar
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.teal, width: 2),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.card,
                  child: Icon(
                    isLoggedIn ? Icons.person : Icons.person_outline,
                    size: 40,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isLoggedIn
                    ? (userAsync.valueOrNull?.email ?? '')
                    : 'Guest Mode',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Status card
              _StatusCard(isLoggedIn: isLoggedIn),
              const SizedBox(height: 16),

              // Tournament Mode toggle
              const TournamentModeToggle(),
              const SizedBox(height: 12),
              const TournamentModeInfoCard(),
              const SizedBox(height: 16),

              // Settings section
              _SectionCard(
                title: 'App Settings',
                children: [
                  _SettingsTile(
                    icon: Icons.map_outlined,
                    title: 'Default Lake',
                    subtitle: 'Horseshoe Lake, AR',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.straighten,
                    title: 'Units',
                    subtitle: 'Imperial (ft, mph, \u00B0F)',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Weather alerts, fishing reports',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // About section
              _SectionCard(
                title: 'About',
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: 'Version',
                    subtitle: '1.0.0 (MVP)',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.code,
                    title: 'Data Sources',
                    subtitle: 'AGFC, TWRA, KDFWR, USGS, Open-Meteo',
                    onTap: () {},
                  ),
                  _SettingsTile(
                    icon: Icons.favorite_outline,
                    title: 'Built for slab hunters',
                    subtitle: 'SlabHaul \u00A9 2025',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Auth action
              if (isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(authNotifierProvider.notifier).signOut();
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF87171),
                      side: const BorderSide(color: Color(0xFFF87171)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('Sign In to Unlock All Features'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final bool isLoggedIn;
  const _StatusCard({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatItem(
                label: 'Mode',
                value: isLoggedIn ? 'Full' : 'Guest',
                icon: isLoggedIn ? Icons.verified : Icons.explore,
                color: isLoggedIn ? AppColors.teal : AppColors.textSecondary,
              ),
              Container(width: 1, height: 36, color: AppColors.cardBorder),
              _StatItem(
                label: 'Supabase',
                value: SupabaseService.isAvailable ? 'Online' : 'Offline',
                icon: SupabaseService.isAvailable
                    ? Icons.cloud_done
                    : Icons.cloud_off,
                color: SupabaseService.isAvailable
                    ? const Color(0xFF34D399)
                    : AppColors.textMuted,
              ),
              Container(width: 1, height: 36, color: AppColors.cardBorder),
              const _StatItem(
                label: 'Lakes',
                value: '3',
                icon: Icons.water,
                color: Color(0xFF60A5FA),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.teal, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textMuted,
        size: 20,
      ),
      dense: true,
      onTap: onTap,
    );
  }
}
