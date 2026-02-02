import 'package:flutter/material.dart';
import '../../../core/utils/constants.dart';

class StartTripDialog extends StatefulWidget {
  const StartTripDialog({super.key});

  @override
  State<StartTripDialog> createState() => _StartTripDialogState();
}

class _StartTripDialogState extends State<StartTripDialog> {
  final _lakeNameController = TextEditingController();

  // Common Tennessee lakes for quick selection
  static const _commonLakes = [
    'Kentucky Lake',
    'Pickwick Lake',
    'Wheeler Lake',
    'Guntersville Lake',
    'Chickamauga Lake',
    'Reelfoot Lake',
    'Watts Bar Lake',
  ];

  @override
  void dispose() {
    _lakeNameController.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.pop(context, (
      lakeId: null as String?,
      lakeName: _lakeNameController.text.isNotEmpty
          ? _lakeNameController.text
          : null,
    ));
  }

  void _selectLake(String lakeName) {
    _lakeNameController.text = lakeName;
    _submit();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Icon(Icons.directions_boat, color: AppColors.teal),
                SizedBox(width: 8),
                Text(
                  'Start Trip',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lake name input
            const Text(
              'Where are you fishing?',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _lakeNameController,
              autofocus: true,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter lake name',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),

            const SizedBox(height: 16),

            // Quick select common lakes
            const Text(
              'Quick select',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _commonLakes.map((lake) {
                return ActionChip(
                  label: Text(
                    lake,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  backgroundColor: AppColors.card,
                  onPressed: () => _selectLake(lake),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

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
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
