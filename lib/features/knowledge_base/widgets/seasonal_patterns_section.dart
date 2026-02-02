import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/constants.dart';
import '../../../shared/widgets/info_chip.dart';
import '../data/knowledge_data.dart';
import 'knowledge_search_bar.dart';

class SeasonalPatternsSection extends ConsumerWidget {
  const SeasonalPatternsSection({super.key});

  static const _seasonIcons = {
    'Winter': Icons.ac_unit,
    'Pre-Spawn': Icons.trending_up,
    'Spawn': Icons.water_drop,
    'Post-Spawn / Summer': Icons.wb_sunny,
    'Fall': Icons.park,
  };

  static const _seasonColors = {
    'Winter': Color(0xFF60A5FA),
    'Pre-Spawn': Color(0xFF34D399),
    'Spawn': Color(0xFFFBBF24),
    'Post-Spawn / Summer': Color(0xFFF97316),
    'Fall': Color(0xFFF87171),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(knowledgeSearchProvider).toLowerCase();

    final filtered = kSeasonalPatterns.where((p) {
      if (query.isEmpty) return true;
      return p.season.toLowerCase().contains(query) ||
          p.notes.toLowerCase().contains(query) ||
          p.baits.toLowerCase().contains(query) ||
          p.locations.any((l) => l.toLowerCase().contains(query)) ||
          p.techniques.any((t) => t.toLowerCase().contains(query)) ||
          p.colors.any((c) => c.toLowerCase().contains(query));
    }).toList();

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No seasonal patterns match "$query"',
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
        final pattern = filtered[index];
        final color = _seasonColors[pattern.season] ?? AppColors.teal;
        final icon = _seasonIcons[pattern.season] ?? Icons.calendar_month;

        return _SeasonCard(pattern: pattern, color: color, icon: icon);
      },
    );
  }
}

class _SeasonCard extends StatelessWidget {
  final dynamic pattern;
  final Color color;
  final IconData icon;

  const _SeasonCard({
    required this.pattern,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            pattern.season,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          subtitle: Row(
            children: [
              InfoChip(label: pattern.tempRange, color: color),
              const SizedBox(width: 6),
              InfoChip(label: pattern.depthRange, color: color),
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

                  // Locations
                  _SubSection(
                    title: 'Where to Fish',
                    icon: Icons.location_on,
                    color: color,
                    items: (pattern.locations as List<String>),
                  ),
                  const SizedBox(height: 12),

                  // Techniques
                  _SubSection(
                    title: 'Techniques',
                    icon: Icons.phishing,
                    color: color,
                    items: (pattern.techniques as List<String>),
                  ),
                  const SizedBox(height: 12),

                  // Baits
                  const Text(
                    'Baits & Presentation',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pattern.baits,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Top Colors
                  const Text(
                    'Top Colors',
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
                    children: (pattern.colors as List<String>)
                        .map<Widget>(
                          (c) => InfoChip(label: c, color: color),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 12),

                  // Notes
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: color, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pattern.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
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

class _SubSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;

  const _SubSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('  \u2022  ',
                    style: TextStyle(color: color, fontSize: 13)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
