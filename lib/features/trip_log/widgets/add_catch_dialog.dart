import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/trip_log.dart';
import '../../../core/utils/constants.dart';
import '../providers/trip_log_providers.dart';

/// Result from the AddCatchDialog
class CatchDialogResult {
  final FishSpecies species;
  final double? lengthInches;
  final double? weightLbs;
  final double? depthFt;
  final BaitUsed? bait;
  final String? notes;
  final bool released;

  const CatchDialogResult({
    required this.species,
    this.lengthInches,
    this.weightLbs,
    this.depthFt,
    this.bait,
    this.notes,
    this.released = true,
  });
}

class AddCatchDialog extends ConsumerStatefulWidget {
  const AddCatchDialog({super.key});

  @override
  ConsumerState<AddCatchDialog> createState() => _AddCatchDialogState();
}

class _AddCatchDialogState extends ConsumerState<AddCatchDialog> {
  FishSpecies _selectedSpecies = FishSpecies.whiteCrappie;
  final _lengthController = TextEditingController();
  final _weightController = TextEditingController();
  double _depthFt = 10.0;
  final _baitNameController = TextEditingController();
  final _baitColorController = TextEditingController();
  final _notesController = TextEditingController();
  bool _released = true;
  bool _weightIsEstimated = false;
  bool _userEditedWeight = false;

  @override
  void initState() {
    super.initState();
    _lengthController.addListener(_onLengthChanged);
    _weightController.addListener(_onWeightManualEdit);
  }

  @override
  void dispose() {
    _lengthController.removeListener(_onLengthChanged);
    _weightController.removeListener(_onWeightManualEdit);
    _lengthController.dispose();
    _weightController.dispose();
    _baitNameController.dispose();
    _baitColorController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onLengthChanged() {
    if (_userEditedWeight) return;
    final length = double.tryParse(_lengthController.text);
    if (length != null && length > 0) {
      final estimated = _selectedSpecies.estimateWeightLbs(length);
      if (estimated != null) {
        _weightController.removeListener(_onWeightManualEdit);
        _weightController.text = estimated.toStringAsFixed(2);
        _weightController.addListener(_onWeightManualEdit);
        setState(() => _weightIsEstimated = true);
        return;
      }
    }
    if (_weightIsEstimated) {
      _weightController.removeListener(_onWeightManualEdit);
      _weightController.clear();
      _weightController.addListener(_onWeightManualEdit);
      setState(() => _weightIsEstimated = false);
    }
  }

  void _onWeightManualEdit() {
    if (_weightIsEstimated) {
      setState(() {
        _weightIsEstimated = false;
        _userEditedWeight = true;
      });
    }
  }

  void _applyLastCatch(CatchRecord lastCatch) {
    setState(() {
      _selectedSpecies = lastCatch.species;
      if (lastCatch.depthFt != null) {
        _depthFt = lastCatch.depthFt!;
      }
      if (lastCatch.bait != null) {
        _baitNameController.text = lastCatch.bait!.name;
        _baitColorController.text = lastCatch.bait?.color ?? '';
      }
    });
  }

  void _submit() {
    BaitUsed? bait;
    if (_baitNameController.text.isNotEmpty) {
      bait = BaitUsed(
        name: _baitNameController.text,
        color: _baitColorController.text.isNotEmpty
            ? _baitColorController.text
            : null,
      );
    }

    final result = CatchDialogResult(
      species: _selectedSpecies,
      lengthInches: _lengthController.text.isNotEmpty
          ? double.tryParse(_lengthController.text)
          : null,
      weightLbs: _weightController.text.isNotEmpty
          ? double.tryParse(_weightController.text)
          : null,
      depthFt: _depthFt,
      bait: bait,
      notes:
          _notesController.text.isNotEmpty ? _notesController.text : null,
      released: _released,
    );

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final lastCatchAsync = ref.watch(lastCatchProvider);

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.phishing, color: AppColors.teal),
                const SizedBox(width: 8),
                const Text(
                  'Log Catch',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Same as last button
                lastCatchAsync.when(
                  data: (lastCatch) {
                    if (lastCatch == null) return const SizedBox.shrink();
                    return TextButton.icon(
                      onPressed: () => _applyLastCatch(lastCatch),
                      icon: const Icon(Icons.replay, size: 16),
                      label: const Text('Same'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Species selector
            const Text(
              'Species',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            _SpeciesSelector(
              selected: _selectedSpecies,
              onChanged: (species) {
                setState(() {
                  _selectedSpecies = species;
                  _userEditedWeight = false;
                });
                _onLengthChanged();
              },
            ),

            const SizedBox(height: 16),

            // Size inputs
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Length (in)',
                    controller: _lengthController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    hint: '12.5',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: _weightIsEstimated
                        ? 'Weight (lbs) \u2022 Est.'
                        : 'Weight (lbs)',
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    hint: '1.25',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Depth slider
            const Text(
              'Depth',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _depthFt,
                    min: 1,
                    max: 50,
                    divisions: 49,
                    onChanged: (value) => setState(() => _depthFt = value),
                  ),
                ),
                Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text(
                    '${_depthFt.round()} ft',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Bait inputs
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _InputField(
                    label: 'Bait',
                    controller: _baitNameController,
                    hint: 'Tube jig',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Color',
                    controller: _baitColorController,
                    hint: 'Chartreuse',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Notes
            _InputField(
              label: 'Notes',
              controller: _notesController,
              hint: 'Caught near brush pile',
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Released toggle
            Row(
              children: [
                Switch(
                  value: _released,
                  onChanged: (value) => setState(() => _released = value),
                  activeTrackColor: AppColors.teal.withValues(alpha: 0.5),
                  thumbColor: WidgetStateProperty.resolveWith((states) {
                    return states.contains(WidgetState.selected)
                        ? AppColors.teal
                        : AppColors.textMuted;
                  }),
                ),
                const SizedBox(width: 8),
                Text(
                  _released ? 'Released' : 'Kept',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.check),
                  label: const Text('Log Catch'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeciesSelector extends StatelessWidget {
  final FishSpecies selected;
  final ValueChanged<FishSpecies> onChanged;

  const _SpeciesSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Common species first, then others
    final commonSpecies = [
      FishSpecies.whiteCrappie,
      FishSpecies.blackCrappie,
      FishSpecies.largemouthBass,
      FishSpecies.bluegill,
      FishSpecies.catfish,
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...commonSpecies.map((species) => _SpeciesChip(
              species: species,
              isSelected: selected == species,
              onTap: () => onChanged(species),
            )),
        // "Other" dropdown for less common species
        PopupMenuButton<FishSpecies>(
          onSelected: onChanged,
          itemBuilder: (context) => FishSpecies.values
              .where((s) => !commonSpecies.contains(s))
              .map((species) => PopupMenuItem(
                    value: species,
                    child: Text(species.displayName),
                  ))
              .toList(),
          child: Chip(
            label: Text(
              commonSpecies.contains(selected) ? 'Other...' : selected.displayName,
              style: TextStyle(
                fontSize: 12,
                color: !commonSpecies.contains(selected)
                    ? AppColors.teal
                    : AppColors.textSecondary,
              ),
            ),
            backgroundColor: !commonSpecies.contains(selected)
                ? AppColors.teal.withValues(alpha: 0.2)
                : AppColors.card,
          ),
        ),
      ],
    );
  }
}

class _SpeciesChip extends StatelessWidget {
  final FishSpecies species;
  final bool isSelected;
  final VoidCallback onTap;

  const _SpeciesChip({
    required this.species,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          species.displayName,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? AppColors.teal : AppColors.textSecondary,
          ),
        ),
        backgroundColor:
            isSelected ? AppColors.teal.withValues(alpha: 0.2) : AppColors.card,
        side: BorderSide(
          color: isSelected ? AppColors.teal : AppColors.cardBorder,
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLines;

  const _InputField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
          inputFormatters: keyboardType ==
                  const TextInputType.numberWithOptions(decimal: true)
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ]
              : null,
        ),
      ],
    );
  }
}
