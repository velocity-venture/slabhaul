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
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
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

/// Loads the full bait catalog for the picker modal.
final baitCatalogProvider = FutureProvider<List<Bait>>((ref) async {
  return BaitService.getBaits();
});

/// Resolves the selected bait by ID so we can display its name and details.
final selectedBaitInfoProvider = FutureProvider.family<Bait?, String?>((ref, baitId) async {
  if (baitId == null) return null;
  return BaitService.getBaitById(baitId);
});

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
    final selectedBait = ref.watch(selectedBaitInfoProvider(formState.selectedBaitId));

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
                  children: [
                    Expanded(
                      child: selectedBait.when(
                        data: (bait) {
                          if (bait == null) return const Text('Unknown bait');
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (bait.brand != null)
                                Text(
                                  bait.brand!.name,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              Text(
                                bait.name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                bait.category.displayName,
                                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                              ),
                            ],
                          );
                        },
                        loading: () => const Text('Loading...'),
                        error: (_, __) => const Text('Unknown bait'),
                      ),
                    ),
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
    const defaultColors = ['White', 'Chartreuse', 'Yellow', 'Pink', 'Black', 'Orange', 'Red', 'Blue', 'Green'];
    const defaultSizes = ['1/32 oz', '1/16 oz', '1/8 oz', '1.5"', '2"', '2.5"', '3"'];

    final selectedBait = ref.watch(selectedBaitInfoProvider(formState.selectedBaitId));
    final baitColors = selectedBait.valueOrNull?.availableColors;
    final baitSizes = selectedBait.valueOrNull?.availableSizes;

    final colors = (baitColors != null && baitColors.isNotEmpty) ? baitColors : defaultColors;
    final sizes = (baitSizes != null && baitSizes.isNotEmpty) ? baitSizes : defaultSizes;

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
                Row(
                  children: [
                    const Text('Color *', style: TextStyle(fontWeight: FontWeight.w500)),
                    if (baitColors != null && baitColors.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          '(from ${selectedBait.valueOrNull?.name ?? 'bait'})',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors.map((color) => FilterChip(
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
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: sizes.map((size) => FilterChip(
                    label: Text(size),
                    selected: formState.sizeUsed == size,
                    onSelected: (_) => formNotifier.updateSizeUsed(size),
                  )).toList(),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _BaitPickerContent(
          scrollController: scrollController,
          onBaitSelected: (bait) {
            formNotifier.updateSelectedBait(bait.id);
            // Clear color/size when switching baits so stale selections don't persist
            formNotifier.updateColorUsed('');
            formNotifier.updateSizeUsed('');
            Navigator.of(context).pop();
          },
        ),
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

// ============================================================================
// BAIT PICKER BOTTOM SHEET
// ============================================================================

class _BaitPickerContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final ValueChanged<Bait> onBaitSelected;

  const _BaitPickerContent({
    required this.scrollController,
    required this.onBaitSelected,
  });

  @override
  ConsumerState<_BaitPickerContent> createState() => _BaitPickerContentState();
}

class _BaitPickerContentState extends ConsumerState<_BaitPickerContent> {
  String _searchQuery = '';
  BaitCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(baitCatalogProvider);

    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            'Select Bait',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search baits...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
          ),
        ),

        // Category filter chips
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (_) => setState(() => _selectedCategory = null),
                ),
              ),
              ...BaitCategory.values.map((cat) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text('${cat.icon} ${cat.displayName}'),
                  selected: _selectedCategory == cat,
                  onSelected: (_) => setState(() {
                    _selectedCategory = _selectedCategory == cat ? null : cat;
                  }),
                ),
              )),
            ],
          ),
        ),

        const Divider(height: 1),

        // Bait list
        Expanded(
          child: catalogAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error loading baits: $error')),
            data: (baits) {
              var filtered = baits;

              if (_selectedCategory != null) {
                filtered = filtered.where((b) => b.category == _selectedCategory).toList();
              }

              if (_searchQuery.isNotEmpty) {
                filtered = filtered.where((b) =>
                  b.name.toLowerCase().contains(_searchQuery) ||
                  (b.brand?.name.toLowerCase().contains(_searchQuery) ?? false) ||
                  b.category.displayName.toLowerCase().contains(_searchQuery)
                ).toList();
              }

              if (filtered.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      const Text('No baits found'),
                      const SizedBox(height: 4),
                      Text(
                        'Try a different search or category',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: widget.scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final bait = filtered[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        bait.category.icon,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    title: Text(
                      bait.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      [
                        if (bait.brand != null) bait.brand!.name,
                        bait.category.displayName,
                        if (bait.availableColors.isNotEmpty)
                          '${bait.availableColors.length} colors',
                      ].join(' · '),
                    ),
                    trailing: bait.isCrappieSpecific
                        ? Icon(Icons.star, size: 18, color: Theme.of(context).primaryColor)
                        : null,
                    onTap: () => widget.onBaitSelected(bait),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}