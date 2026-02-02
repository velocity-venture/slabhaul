import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/clarity/widgets/clarity_info_card.dart';
import 'package:slabhaul/features/map/providers/clarity_providers.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Dedicated screen showing detailed water clarity information.
class WaterClarityScreen extends ConsumerWidget {
  const WaterClarityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lakesAsync = ref.watch(lakesProvider);
    final selectedLakeId = ref.watch(selectedLakeProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Water Clarity'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'How clarity is estimated',
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: lakesAsync.when(
        data: (lakes) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lake selector
                _LakeSelector(
                  lakes: lakes,
                  selectedId: selectedLakeId,
                  onSelected: (id) {
                    ref.read(selectedLakeProvider.notifier).state = id;
                  },
                ),
                const SizedBox(height: 16),
                
                // Main clarity card
                const ClarityInfoCard(),
                const SizedBox(height: 16),
                
                // Zone breakdown (if available)
                const _ZoneBreakdownSection(),
                const SizedBox(height: 16),
                
                // Clarity legend
                _ClarityLegendExpanded(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('Unable to load lakes', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('How Clarity is Estimated'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SlabHaul estimates water clarity using real weather data and science-based algorithms:',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              SizedBox(height: 16),
              _InfoSection(
                icon: Icons.water_drop,
                title: 'Recent Rain',
                description: 'Rain stirs up sediment and increases turbidity. Heavy rain in the last 24-72 hours significantly reduces visibility.',
              ),
              SizedBox(height: 12),
              _InfoSection(
                icon: Icons.air,
                title: 'Wind',
                description: 'Strong winds mix the water column, especially in shallow areas, reducing clarity through suspension of particles.',
              ),
              SizedBox(height: 12),
              _InfoSection(
                icon: Icons.calendar_today,
                title: 'Days Since Rain',
                description: 'Sediment settles over time. After 3-5 days without significant rain, water typically clears noticeably.',
              ),
              SizedBox(height: 12),
              _InfoSection(
                icon: Icons.wb_sunny,
                title: 'Season',
                description: 'Spring runoff brings increased turbidity. Summer typically offers the clearest water conditions.',
              ),
              SizedBox(height: 12),
              _InfoSection(
                icon: Icons.location_on,
                title: 'Lake Zones',
                description: 'Different areas of a lake have different baseline clarity. Creek arms are more affected by runoff than main channels.',
              ),
              SizedBox(height: 16),
              Text(
                'Note: These are estimates based on weather patterns. Actual clarity may vary.',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Lake selector dropdown
class _LakeSelector extends StatelessWidget {
  final List<dynamic> lakes;
  final String? selectedId;
  final ValueChanged<String?> onSelected;

  const _LakeSelector({
    required this.lakes,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          isExpanded: true,
          hint: const Text('Select a lake'),
          dropdownColor: AppColors.surface,
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('All Lakes'),
            ),
            ...lakes.map((lake) => DropdownMenuItem<String?>(
              value: lake.id,
              child: Text(lake.name),
            )),
          ],
          onChanged: onSelected,
        ),
      ),
    );
  }
}

/// Section showing clarity breakdown by zone
class _ZoneBreakdownSection extends ConsumerWidget {
  const _ZoneBreakdownSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zonesAsync = ref.watch(clarityZonesProvider);

    return zonesAsync.when(
      data: (zones) {
        if (zones.isEmpty) return const SizedBox.shrink();
        
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Clarity by Zone',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1, color: AppColors.cardBorder),
              ...zones.map((zone) => _ZoneRow(zone: zone)),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

/// Single zone row showing clarity
class _ZoneRow extends StatelessWidget {
  final ClarityZone zone;

  const _ZoneRow({required this.zone});

  @override
  Widget build(BuildContext context) {
    final clarity = zone.currentClarity;
    final level = clarity?.level ?? ClarityLevel.lightStain;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Zone type indicator
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(level.mapColor).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(level.icon, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          
          // Zone info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  zone.type.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Clarity value
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                level.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(level.mapColor),
                ),
              ),
              Text(
                '~${clarity?.visibilityFt.toStringAsFixed(1) ?? "?"} ft',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Expanded legend showing all clarity levels
class _ClarityLegendExpanded extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Clarity Legend',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          ...ClarityLevel.values.map((level) => _LegendRow(level: level)),
        ],
      ),
    );
  }
}

/// Single legend row
class _LegendRow extends StatelessWidget {
  final ClarityLevel level;

  const _LegendRow({required this.level});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 24,
            decoration: BoxDecoration(
              color: Color(level.mapColor).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Color(level.mapColor)),
            ),
          ),
          const SizedBox(width: 12),
          Text(level.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  level.visibilityRange,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
