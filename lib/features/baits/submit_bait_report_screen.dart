// Submit Bait Report Screen
// GPS-tagged effectiveness reporting for baits

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/models/bait.dart';
import '../../core/services/bait_service.dart';
import '../../core/utils/app_logger.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

class BaitReportFormState {
  final String? selectedBaitId;
  final String? selectedLakeId;
  final Position? currentPosition;
  final String colorUsed;
  final String sizeUsed;
  final double? weightUsed;
  final int fishCaught;
  final double? largestFishLength;
  final double? largestFishWeight;
  final double? waterTemp;
  final WaterClarity? waterClarity;
  final String? weatherConditions;
  final FishingTimeOfDay? timeOfDay;
  final Season? season;
  final String? techniqueUsed;
  final double? depthFished;
  final int confidenceScore;
  final String? notes;
  final bool isSubmitting;

  const BaitReportFormState({
    this.selectedBaitId,
    this.selectedLakeId,
    this.currentPosition,
    this.colorUsed = '',
    this.sizeUsed = '',
    this.weightUsed,
    this.fishCaught = 0,
    this.largestFishLength,
    this.largestFishWeight,
    this.waterTemp,
    this.waterClarity,
    this.weatherConditions,
    this.timeOfDay,
    this.season,
    this.techniqueUsed,
    this.depthFished,
    this.confidenceScore = 3,
    this.notes,
    this.isSubmitting = false,
  });

  BaitReportFormState copyWith({
    String? selectedBaitId,
    String? selectedLakeId,
    Position? currentPosition,
    String? colorUsed,
    String? sizeUsed,
    double? weightUsed,
    int? fishCaught,
    double? largestFishLength,
    double? largestFishWeight,
    double? waterTemp,
    WaterClarity? waterClarity,
    String? weatherConditions,
    FishingTimeOfDay? timeOfDay,
    Season? season,
    String? techniqueUsed,
    double? depthFished,
    int? confidenceScore,
    String? notes,
    bool? isSubmitting,
  }) {
    return BaitReportFormState(
      selectedBaitId: selectedBaitId ?? this.selectedBaitId,
      selectedLakeId: selectedLakeId ?? this.selectedLakeId,
      currentPosition: currentPosition ?? this.currentPosition,
      colorUsed: colorUsed ?? this.colorUsed,
      sizeUsed: sizeUsed ?? this.sizeUsed,
      weightUsed: weightUsed ?? this.weightUsed,
      fishCaught: fishCaught ?? this.fishCaught,
      largestFishLength: largestFishLength ?? this.largestFishLength,
      largestFishWeight: largestFishWeight ?? this.largestFishWeight,
      waterTemp: waterTemp ?? this.waterTemp,
      waterClarity: waterClarity ?? this.waterClarity,
      weatherConditions: weatherConditions ?? this.weatherConditions,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      season: season ?? this.season,
      techniqueUsed: techniqueUsed ?? this.techniqueUsed,
      depthFished: depthFished ?? this.depthFished,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      notes: notes ?? this.notes,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }

  bool get canSubmit =>
      selectedBaitId != null &&
      currentPosition != null &&
      colorUsed.isNotEmpty &&
      sizeUsed.isNotEmpty &&
      !isSubmitting;
}

class BaitReportFormNotifier extends StateNotifier<BaitReportFormState> {
  BaitReportFormNotifier([String? preselectedBaitId]) : super(BaitReportFormState(selectedBaitId: preselectedBaitId)) {
    _getCurrentLocation();
    _detectCurrentSeason();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      state = state.copyWith(currentPosition: position);
      AppLogger.info('BaitReportForm', 'Got current position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      AppLogger.error('BaitReportForm', '_getCurrentLocation', e, StackTrace.current);
    }
  }

  void _detectCurrentSeason() {
    final now = DateTime.now();
    Season season;
    
    // Simple season detection based on month (Northern Hemisphere)
    switch (now.month) {
      case 3:
      case 4:
      case 5:
        season = Season.spring;
        break;
      case 6:
      case 7:
      case 8:
        season = Season.summer;
        break;
      case 9:
      case 10:
      case 11:
        season = Season.fall;
        break;
      default:
        season = Season.winter;
        break;
    }
    
    state = state.copyWith(season: season);
  }

  void updateSelectedBait(String? baitId) {
    state = state.copyWith(selectedBaitId: baitId);
  }

  void updateSelectedLake(String? lakeId) {
    state = state.copyWith(selectedLakeId: lakeId);
  }

  void updateColorUsed(String color) {
    state = state.copyWith(colorUsed: color);
  }

  void updateSizeUsed(String size) {
    state = state.copyWith(sizeUsed: size);
  }

  void updateWeightUsed(double? weight) {
    state = state.copyWith(weightUsed: weight);
  }

  void updateFishCaught(int count) {
    state = state.copyWith(fishCaught: count);
  }

  void updateLargestFishLength(double? length) {
    state = state.copyWith(largestFishLength: length);
  }

  void updateLargestFishWeight(double? weight) {
    state = state.copyWith(largestFishWeight: weight);
  }

  void updateWaterTemp(double? temp) {
    state = state.copyWith(waterTemp: temp);
  }

  void updateWaterClarity(WaterClarity? clarity) {
    state = state.copyWith(waterClarity: clarity);
  }

  void updateWeatherConditions(String? weather) {
    state = state.copyWith(weatherConditions: weather);
  }

  void updateTimeOfDay(FishingTimeOfDay? timeOfDay) {
    state = state.copyWith(timeOfDay: timeOfDay);
  }

  void updateSeason(Season? season) {
    state = state.copyWith(season: season);
  }

  void updateTechniqueUsed(String? technique) {
    state = state.copyWith(techniqueUsed: technique);
  }

  void updateDepthFished(double? depth) {
    state = state.copyWith(depthFished: depth);
  }

  void updateConfidenceScore(int score) {
    state = state.copyWith(confidenceScore: score);
  }

  void updateNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  Future<bool> submitReport() async {
    if (!state.canSubmit) return false;

    state = state.copyWith(isSubmitting: true);

    try {
      final report = await BaitService.submitBaitReport(
        baitId: state.selectedBaitId!,
        lakeId: state.selectedLakeId,
        latitude: state.currentPosition!.latitude,
        longitude: state.currentPosition!.longitude,
        colorUsed: state.colorUsed,
        sizeUsed: state.sizeUsed,
        weightUsed: state.weightUsed,
        fishCaught: state.fishCaught,
        largestFishLength: state.largestFishLength,
        largestFishWeight: state.largestFishWeight,
        waterTemp: state.waterTemp,
        waterClarity: state.waterClarity,
        weatherConditions: state.weatherConditions,
        timeOfDay: state.timeOfDay,
        season: state.season,
        techniqueUsed: state.techniqueUsed,
        depthFished: state.depthFished,
        confidenceScore: state.confidenceScore,
        notes: state.notes,
      );

      state = state.copyWith(isSubmitting: false);
      return report != null;
    } catch (e) {
      AppLogger.error('BaitReportForm', 'submitReport', e, StackTrace.current);
      state = state.copyWith(isSubmitting: false);
      return false;
    }
  }
}

final baitReportFormProvider = StateNotifierProvider.family<BaitReportFormNotifier, BaitReportFormState, String?>(
  (ref, preselectedBaitId) => BaitReportFormNotifier(preselectedBaitId),
);

// ============================================================================
// SUBMIT BAIT REPORT SCREEN
// ============================================================================

class SubmitBaitReportScreen extends ConsumerWidget {
  final String? preselectedBaitId;

  const SubmitBaitReportScreen({
    super.key,
    this.preselectedBaitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(baitReportFormProvider(preselectedBaitId));
    final formNotifier = ref.read(baitReportFormProvider(preselectedBaitId).notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Bait Results'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location status
            _buildLocationStatus(context, formState),
            const SizedBox(height: 16),
            
            // Bait selection
            _buildBaitSelection(context, ref, formState, formNotifier),
            const SizedBox(height: 16),
            
            // Bait details used
            _buildBaitDetails(context, ref, formState, formNotifier),
            const SizedBox(height: 16),
            
            // Results
            _buildResults(context, formState, formNotifier),
            const SizedBox(height: 16),
            
            // Conditions
            _buildConditions(context, formState, formNotifier),
            const SizedBox(height: 16),
            
            // Additional notes
            _buildNotes(context, formState, formNotifier),
            const SizedBox(height: 24),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: formState.canSubmit
                    ? () => _submitReport(context, ref, formNotifier)
                    : null,
                child: formState.isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Submit Report'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus(BuildContext context, BaitReportFormState formState) {
    if (formState.currentPosition == null) {
      return Card(
        color: Colors.orange[50],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Getting your location...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('This is needed to tag your report'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location confirmed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${formState.currentPosition!.latitude.toStringAsFixed(6)}, ${formState.currentPosition!.longitude.toStringAsFixed(6)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaitSelection(BuildContext context, WidgetRef ref, BaitReportFormState formState, BaitReportFormNotifier formNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bait Used *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (formState.selectedBaitId == null)
              ElevatedButton(
                onPressed: () => _showBaitPicker(context, ref, formNotifier),
                child: const Text('Select Bait'),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Bait selected'), // TODO: Show actual bait name
                    TextButton(
                      onPressed: () => _showBaitPicker(context, ref, formNotifier),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBaitDetails(BuildContext context, WidgetRef ref, BaitReportFormState formState, BaitReportFormNotifier formNotifier) {
    // TODO: Load popular colors from bait service
    final popularColors = ['White', 'Chartreuse', 'Yellow', 'Pink', 'Black', 'Orange', 'Red', 'Blue', 'Green'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bait Details *',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Color
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Color *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: popularColors.map((color) => FilterChip(
                    label: Text(color),
                    selected: formState.colorUsed == color,
                    onSelected: (_) => formNotifier.updateColorUsed(color),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Size
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Size *', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  onChanged: formNotifier.updateSizeUsed,
                  decoration: const InputDecoration(
                    hintText: 'e.g., 1/16 oz, 2", etc.',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context, BaitReportFormState formState, BaitReportFormNotifier formNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Results',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Fish caught
            Row(
              children: [
                const Text('Fish Caught: ', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final count = int.tryParse(value) ?? 0;
                      formNotifier.updateFishCaught(count);
                    },
                    decoration: const InputDecoration(
                      hintText: '0',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            if (formState.fishCaught > 0) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Largest Fish Length (inches)', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final length = double.tryParse(value);
                            formNotifier.updateLargestFishLength(length);
                          },
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Weight (pounds)', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final weight = double.tryParse(value);
                            formNotifier.updateLargestFishWeight(weight);
                          },
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConditions(BuildContext context, BaitReportFormState formState, BaitReportFormNotifier formNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Conditions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Water clarity
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Water Clarity', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: WaterClarity.values.map((clarity) => FilterChip(
                    label: Text(clarity.displayName),
                    selected: formState.waterClarity == clarity,
                    onSelected: (_) => formNotifier.updateWaterClarity(clarity),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Time of day
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Time of Day', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: FishingTimeOfDay.values.map((time) => FilterChip(
                    label: Text(time.displayName),
                    selected: formState.timeOfDay == time,
                    onSelected: (_) => formNotifier.updateTimeOfDay(time),
                  )).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Season
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Season', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: Season.values.map((season) => FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(season.icon),
                        const SizedBox(width: 4),
                        Text(season.displayName),
                      ],
                    ),
                    selected: formState.season == season,
                    onSelected: (_) => formNotifier.updateSeason(season),
                  )).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotes(BuildContext context, BaitReportFormState formState, BaitReportFormNotifier formNotifier) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              onChanged: formNotifier.updateNotes,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any additional details about your fishing experience...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBaitPicker(BuildContext context, WidgetRef ref, BaitReportFormNotifier formNotifier) {
    // TODO: Implement bait picker modal
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bait Picker'),
        content: const Text('Bait picker coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitReport(BuildContext context, WidgetRef ref, BaitReportFormNotifier formNotifier) async {
    final success = await formNotifier.submitReport();
    
    if (success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit report. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}