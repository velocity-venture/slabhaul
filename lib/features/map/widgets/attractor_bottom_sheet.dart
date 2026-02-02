import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:slabhaul/core/models/attractor.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/shared/widgets/info_chip.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// A draggable bottom sheet that displays details for the currently selected
/// attractor. Dismiss by dragging down or tapping outside the sheet.
class AttractorBottomSheet extends ConsumerWidget {
  const AttractorBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attractor = ref.watch(selectedAttractorProvider);
    if (attractor == null) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.38,
      minChildSize: 0.15,
      maxChildSize: 0.60,
      snap: true,
      snapSizes: const [0.15, 0.38, 0.60],
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 8),
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Name and type badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      attractor.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  InfoChip(
                    label: attractor.typeLabel,
                    color: attractorColor(attractor.type),
                    icon: _iconForType(attractor.type),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Lake name
              Row(
                children: [
                  const Icon(Icons.water, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    attractor.lakeName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.cardBorder, height: 1),
              const SizedBox(height: 16),
              // GPS coordinates (copyable)
              _DetailRow(
                icon: Icons.gps_fixed,
                label: 'Coordinates',
                value: attractor.coordinateString,
                trailing: IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.teal),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: attractor.coordinateString),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coordinates copied'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.card,
                      ),
                    );
                  },
                  tooltip: 'Copy coordinates',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
              // Depth
              if (attractor.depth != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.straighten,
                  label: 'Depth',
                  value: '${attractor.depth!.toStringAsFixed(1)} ft',
                ),
              ],
              // Year placed
              if (attractor.yearPlaced != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Year Placed',
                  value: attractor.yearPlaced.toString(),
                ),
              ],
              // Source
              if (attractor.source != null) ...[
                const SizedBox(height: 12),
                _DetailRow(
                  icon: Icons.source,
                  label: 'Source',
                  value: attractor.source!,
                ),
              ],
              const SizedBox(height: 24),
              // Navigate button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchNavigation(attractor),
                  icon: const Icon(Icons.navigation, size: 18),
                  label: const Text('Navigate'),
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
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'brush_pile':
        return Icons.water_drop;
      case 'pvc_tree':
        return Icons.park;
      case 'stake_bed':
        return Icons.grid_on;
      case 'pallet':
        return Icons.dashboard;
      default:
        return Icons.place;
    }
  }

  Future<void> _launchNavigation(Attractor attractor) async {
    final uri = Uri.parse(
      'geo:${attractor.latitude},${attractor.longitude}'
      '?q=${attractor.latitude},${attractor.longitude}'
      '(${Uri.encodeComponent(attractor.name)})',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

/// A single row inside the bottom sheet showing icon, label, and value.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
