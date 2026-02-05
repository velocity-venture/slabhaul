import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/bait_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../providers/bait_recommendation_providers.dart';
import '../widgets/bait_recommendation_card.dart';
import '../widgets/conditions_input_form.dart';

/// Main screen for bait recommendations
/// Allows users to input conditions and see ranked bait recommendations
class BaitRecommendationsScreen extends ConsumerStatefulWidget {
  const BaitRecommendationsScreen({super.key});

  @override
  ConsumerState<BaitRecommendationsScreen> createState() =>
      _BaitRecommendationsScreenState();
}

class _BaitRecommendationsScreenState
    extends ConsumerState<BaitRecommendationsScreen> {
  bool _showConditionsForm = true;

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(baitRecommendationsProvider);
    final conditions = ref.watch(fishingConditionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Bait Recommendations',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Toggle conditions form visibility
          IconButton(
            icon: Icon(
              _showConditionsForm ? Icons.tune : Icons.tune_outlined,
              color: _showConditionsForm ? AppColors.teal : AppColors.textMuted,
            ),
            onPressed: () {
              setState(() {
                _showConditionsForm = !_showConditionsForm;
              });
            },
            tooltip: 'Toggle Conditions',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conditions Input Form (collapsible)
            if (_showConditionsForm) ...[
              const ConditionsInputForm(),
              const SizedBox(height: 16),
            ],

            // Current Conditions Summary (when form hidden)
            if (!_showConditionsForm && conditions.canGenerateRecommendations)
              _ConditionsSummaryBar(
                conditions: conditions,
                onEdit: () {
                  setState(() {
                    _showConditionsForm = true;
                  });
                },
              ),

            // Results Section
            if (result != null && conditions.canGenerateRecommendations) ...[
              const SizedBox(height: 8),
              
              // Summary Card
              _SummaryCard(summary: result.summary),
              const SizedBox(height: 16),

              // General Tips
              if (result.generalTips.isNotEmpty) ...[
                _GeneralTipsCard(tips: result.generalTips),
                const SizedBox(height: 16),
              ],

              // Section Header
              Row(
                children: [
                  const Icon(Icons.format_list_numbered,
                      color: AppColors.teal, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Ranked Recommendations',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${result.recommendations.length} options',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Recommendation Cards
              ...result.recommendations.map(
                (rec) => BaitRecommendationCard(recommendation: rec),
              ),
              
              const SizedBox(height: 24),
              
              // Footer disclaimer
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recommendations based on water temperature, clarity, depth, '
                        'structure, weather, and seasonal patterns. Adjust conditions '
                        'as needed for your specific situation.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Empty State
              const SizedBox(height: 40),
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.phishing,
                      size: 64,
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set Your Conditions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter water temperature and conditions\nabove to get personalized bait recommendations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ConditionsSummaryBar extends StatelessWidget {
  final FishingConditionsState conditions;
  final VoidCallback onEdit;

  const _ConditionsSummaryBar({
    required this.conditions,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            const Icon(Icons.thermostat, size: 14, color: AppColors.teal),
            const SizedBox(width: 4),
            Text(
              '${conditions.waterTempF?.round() ?? "--"}°F',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.water, size: 14, color: AppColors.teal),
            const SizedBox(width: 4),
            Text(
              '${conditions.targetDepthFt.round()} ft',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.visibility, size: 14, color: AppColors.teal),
            const SizedBox(width: 4),
            Text(
              conditions.clarity.displayName.split(' ').first,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            const Text(
              'Edit',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit, size: 12, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.teal.withValues(alpha: 0.15),
            AppColors.teal.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              summary,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralTipsCard extends StatelessWidget {
  final List<String> tips;

  const _GeneralTipsCard({required this.tips});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.warning, size: 18),
              SizedBox(width: 8),
              Text(
                'Pro Tips',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                tip,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
