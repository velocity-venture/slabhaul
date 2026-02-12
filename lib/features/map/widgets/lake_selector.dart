import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:slabhaul/core/models/lake.dart';
import 'package:slabhaul/core/utils/constants.dart';
import 'package:slabhaul/features/map/providers/map_providers.dart';

/// Compact lake selector button that opens a searchable bottom sheet.
///
/// Replaces the old horizontal chip row which overflowed on small screens.
class LakeSelector extends ConsumerWidget {
  const LakeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lakesAsync = ref.watch(lakesProvider);
    final selectedLake = ref.watch(selectedLakeProvider);

    return lakesAsync.when(
      data: (lakes) {
        final currentLabel = selectedLake == null
            ? 'All Lakes'
            : lakes
                .where((l) => l.id == selectedLake)
                .map((l) => l.name)
                .firstOrNull ?? 'All Lakes';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GestureDetector(
            onTap: () => _openLakePicker(context, ref, lakes, selectedLake),
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on,
                      color: AppColors.teal, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentLabel,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textMuted, size: 20),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 44,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.teal,
            ),
          ),
        ),
      ),
      error: (e, _) => const SizedBox(
        height: 44,
        child: Center(
          child: Text(
            'Failed to load lakes',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  void _openLakePicker(
    BuildContext context,
    WidgetRef ref,
    List<Lake> lakes,
    String? selectedLake,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _LakePickerSheet(
        lakes: lakes,
        selectedLakeId: selectedLake,
        onSelected: (lakeId) {
          ref.read(selectedLakeProvider.notifier).state = lakeId;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// The bottom-sheet content: search bar + scrollable lake list.
class _LakePickerSheet extends StatefulWidget {
  final List<Lake> lakes;
  final String? selectedLakeId;
  final ValueChanged<String?> onSelected;

  const _LakePickerSheet({
    required this.lakes,
    required this.selectedLakeId,
    required this.onSelected,
  });

  @override
  State<_LakePickerSheet> createState() => _LakePickerSheetState();
}

class _LakePickerSheetState extends State<_LakePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Lake> get _filteredLakes {
    if (_query.isEmpty) return widget.lakes;
    final q = _query.toLowerCase();
    return widget.lakes
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.state.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLakes;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.65,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Lake',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search by lake or state...',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      color: AppColors.textMuted, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.card,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),

            const SizedBox(height: 4),

            // Lake list
            Flexible(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: filtered.length + 1, // +1 for "All Lakes"
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // Only show "All Lakes" when not filtering
                    if (_query.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    final isSelected = widget.selectedLakeId == null;
                    return _LakeListTile(
                      name: 'All Lakes',
                      subtitle: 'Show all attractor locations',
                      isSelected: isSelected,
                      onTap: () => widget.onSelected(null),
                    );
                  }

                  final lake = filtered[index - 1];
                  final isSelected = widget.selectedLakeId == lake.id;

                  return _LakeListTile(
                    name: lake.name,
                    subtitle:
                        '${lake.state} \u2022 ${lake.attractorCount} attractors',
                    isSelected: isSelected,
                    onTap: () => widget.onSelected(lake.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LakeListTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LakeListTile({
    required this.name,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: isSelected ? AppColors.teal : AppColors.textMuted,
        size: 20,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? AppColors.teal : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
      ),
      onTap: onTap,
    );
  }
}
