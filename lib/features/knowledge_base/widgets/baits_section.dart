import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/info_chip.dart';
import '../data/knowledge_data.dart';
import 'knowledge_search_bar.dart';

class BaitsSection extends ConsumerWidget {
  const BaitsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(knowledgeSearchProvider).toLowerCase();

    final filtered = kBaitsAndLures.where((b) {
      if (query.isEmpty) return true;
      return b.type.toLowerCase().contains(query) ||
          b.ranking.toLowerCase().contains(query) ||
          b.topSizes.toLowerCase().contains(query) ||
          b.riggingMethods.toLowerCase().contains(query) ||
          b.bestColors.any((c) => c.toLowerCase().contains(query));
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No baits match "$query"',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final bait = filtered[index];
        return _BaitCard(bait: bait, index: index);
      },
    );
  }
}

class _BaitCard extends StatelessWidget {
  final dynamic bait;
  final int index;

  const _BaitCard({required this.bait, required this.index});

  static const _baitIcons = [
    Icons.waves, // Tube Jigs
    Icons.set_meal, // Soft Plastic Minnows
    Icons.tsunami, // Curly Tail Grubs
    Icons.blur_on, // Hair Jigs
  ];

  @override
  Widget build(BuildContext context) {
    final iconData =
        index < _baitIcons.length ? _baitIcons[index] : Icons.phishing;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(iconData, color: AppColors.teal, size: 24),
          ),
          title: Text(
            bait.type,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  bait.ranking,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ),
            ],
          ),
          iconColor: AppColors.textSecondary,
          collapsedIconColor: AppColors.textSecondary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 8),

                  // Top Sizes
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.straighten,
                          size: 14, color: Color(0xFF60A5FA)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Top Sizes',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF60A5FA),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              bait.topSizes,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Best Colors
                  const Text(
                    'Best Colors',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (bait.bestColors as List<String>)
                        .map<Widget>(
                          (c) => InfoChip(label: c, color: AppColors.teal),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),

                  // Rigging Methods
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.teal.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.construction,
                            color: AppColors.teal, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rigging Methods',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bait.riggingMethods,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
