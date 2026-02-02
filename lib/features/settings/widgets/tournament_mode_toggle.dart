import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../providers/tournament_mode_provider.dart';

/// A toggle switch for enabling/disabling Tournament Mode.
/// 
/// When Tournament Mode is enabled, AI-assisted features are hidden
/// to comply with tournament rules that may ban real-time AI assistance.
class TournamentModeToggle extends ConsumerWidget {
  const TournamentModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(tournamentModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: isEnabled
            ? AppColors.warning.withOpacity(0.1)
            : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? AppColors.warning.withOpacity(0.4) : AppColors.cardBorder,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isEnabled
                ? AppColors.warning.withOpacity(0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.emoji_events,
            color: isEnabled ? AppColors.warning : AppColors.teal,
            size: 22,
          ),
        ),
        title: const Text(
          'Tournament Mode',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          isEnabled
              ? 'AI features hidden for fair play'
              : 'Disables AI assistance for tournaments',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Switch(
          value: isEnabled,
          onChanged: (_) {
            ref.read(tournamentModeProvider.notifier).toggle();
          },
          activeColor: AppColors.warning,
          activeTrackColor: AppColors.warning.withOpacity(0.4),
        ),
        onTap: () {
          ref.read(tournamentModeProvider.notifier).toggle();
        },
      ),
    );
  }
}

/// Compact badge that shows when Tournament Mode is active.
/// 
/// Use this in the app bar or status area to indicate tournament mode status.
class TournamentModeBadge extends ConsumerWidget {
  final bool compact;
  
  const TournamentModeBadge({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(tournamentModeProvider);

    if (!isEnabled) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(compact ? 6 : 8),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events,
            color: AppColors.warning,
            size: compact ? 12 : 14,
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            const Text(
              'TOURNAMENT',
              style: TextStyle(
                color: AppColors.warning,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info card explaining what Tournament Mode does.
class TournamentModeInfoCard extends StatelessWidget {
  const TournamentModeInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              const Text(
                'About Tournament Mode',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Tournament leagues like Crappie Masters may prohibit '
            'real-time AI assistance during competition. '
            'Enabling Tournament Mode hides:',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          _buildFeatureItem('Thermocline Predictor'),
          _buildFeatureItem('AI spot recommendations'),
          _buildFeatureItem('Predictive depth analysis'),
          const SizedBox(height: 10),
          const Text(
            'Basic weather, maps, and tools remain available.',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.remove, color: AppColors.warning, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
