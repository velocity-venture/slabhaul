import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/hatch_recommendation.dart';
import '../../../core/utils/constants.dart';
import '../providers/match_the_hatch_providers.dart';
import '../widgets/auto_conditions_panel.dart';
import '../widgets/clarity_visual_picker.dart';
import '../widgets/water_temp_input.dart';
import '../widgets/hatch_hero_card.dart';
import '../widgets/forage_context_card.dart';
import '../widgets/alternative_pick_card.dart';
import '../widgets/pro_tip_card.dart';
import '../widgets/product_suggestions_list.dart';

class MatchTheHatchScreen extends ConsumerStatefulWidget {
  const MatchTheHatchScreen({super.key});

  @override
  ConsumerState<MatchTheHatchScreen> createState() => _MatchTheHatchScreenState();
}

class _MatchTheHatchScreenState extends ConsumerState<MatchTheHatchScreen> {
  bool _showResults = false;

  void _generate() {
    setState(() => _showResults = true);
  }

  void _reset() {
    ref.read(hatchUserInputProvider.notifier).reset();
    setState(() => _showResults = false);
  }

  @override
  Widget build(BuildContext context) {
    final userInput = ref.watch(hatchUserInputProvider);
    final recommendation = ref.watch(hatchRecommendationProvider);
    final canGenerate = userInput.isComplete;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/slabhaul_icon.png', width: 24, height: 24),
            const SizedBox(width: 8),
            const Text('Match the Hatch'),
          ],
        ),
        elevation: 0,
        actions: [
          if (_showResults)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auto conditions
            const AutoConditionsPanel(),
            const SizedBox(height: 20),

            // User inputs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Conditions',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Clarity picker
                  ClarityVisualPicker(
                    selected: userInput.clarity,
                    onChanged: (c) =>
                        ref.read(hatchUserInputProvider.notifier).setClarity(c),
                  ),
                  const SizedBox(height: 16),

                  // Water temp
                  WaterTempInput(
                    value: userInput.waterTempF,
                    onChanged: (t) =>
                        ref.read(hatchUserInputProvider.notifier).setWaterTemp(t),
                  ),
                  const SizedBox(height: 16),

                  // Fishing pressure (optional)
                  const Text(
                    'Fishing Pressure (optional)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: FishingPressure.values.map((fp) {
                      final isSelected = userInput.fishingPressure == fp;
                      return GestureDetector(
                        onTap: () => ref
                            .read(hatchUserInputProvider.notifier)
                            .setFishingPressure(isSelected ? null : fp),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.teal.withValues(alpha: 0.15)
                                : AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AppColors.teal : AppColors.cardBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Text(
                            fp.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.teal : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CTA button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: canGenerate
                      ? const LinearGradient(
                          colors: [AppColors.brandIndigo, Color(0xFF3B5998)],
                        )
                      : null,
                  color: canGenerate ? null : AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: canGenerate ? _generate : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    disabledBackgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    'Match the Hatch',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canGenerate ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Results
            if (_showResults && recommendation != null) ...[
              _buildResults(recommendation),
            ] else if (_showResults && recommendation == null) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Enter water clarity and temperature to get recommendations.',
                    style: TextStyle(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResults(HatchRecommendation rec) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Column(
        key: ValueKey(rec.generatedAt),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Primary pick
          HatchHeroCard(pick: rec.primary),
          const SizedBox(height: 14),

          // Forage context
          ForageContextCard(forage: rec.forage),
          const SizedBox(height: 14),

          // Alternatives
          if (rec.alternatives.isNotEmpty) ...[
            const Text(
              'Alternatives',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            ...rec.alternatives.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AlternativePickCard(pick: e.value, index: e.key),
                  ),
                ),
            const SizedBox(height: 8),
          ],

          // Pro tip
          ProTipCard(tip: rec.proTip),
          const SizedBox(height: 14),

          // Products
          ProductSuggestionsList(products: rec.products),
          const SizedBox(height: 14),

          // Reasoning
          Container(
            width: double.infinity,
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
                    Icon(Icons.psychology, size: 16, color: AppColors.teal),
                    SizedBox(width: 6),
                    Text(
                      'Reasoning',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rec.reasoning,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
