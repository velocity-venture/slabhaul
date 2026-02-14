// Bait Detail Screen
// Detailed view of a specific bait with effectiveness data

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/models/bait.dart';
import '../../core/services/bait_service.dart';
import 'submit_bait_report_screen.dart';

// ============================================================================
// STATE PROVIDERS
// ============================================================================

final baitDetailProvider = FutureProvider.family<Bait?, String>((ref, baitId) async {
  return BaitService.getBaitById(baitId);
});

final baitReportsProvider = FutureProvider.family<List<BaitReport>, String>((ref, baitId) async {
  return BaitService.getBaitReports(baitId: baitId, limit: 20);
});

// ============================================================================
// BAIT DETAIL SCREEN
// ============================================================================

class BaitDetailScreen extends ConsumerWidget {
  final String baitId;

  const BaitDetailScreen({
    super.key,
    required this.baitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final baitAsync = ref.watch(baitDetailProvider(baitId));
    final reportsAsync = ref.watch(baitReportsProvider(baitId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bait Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement sharing
            },
          ),
        ],
      ),
      body: baitAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Error loading bait: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(baitDetailProvider(baitId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (bait) {
          if (bait == null) {
            return const Center(
              child: Text('Bait not found'),
            );
          }
          return _buildBaitDetail(context, ref, bait, reportsAsync);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubmitBaitReportScreen(preselectedBaitId: baitId),
            ),
          );
        },
        icon: const Icon(Icons.report),
        label: const Text('Report Results'),
      ),
    );
  }

  Widget _buildBaitDetail(BuildContext context, WidgetRef ref, Bait bait, AsyncValue<List<BaitReport>> reportsAsync) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main bait info
          _buildBaitHeader(context, bait),
          const SizedBox(height: 24),
          
          // Specifications
          _buildSpecifications(context, bait),
          const SizedBox(height: 24),
          
          // Recent reports
          _buildReportsSection(context, reportsAsync),
        ],
      ),
    );
  }

  Widget _buildBaitHeader(BuildContext context, Bait bait) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[100],
                  ),
                  child: bait.hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: bait.primaryImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => _buildPlaceholderImage(bait.category),
                          ),
                        )
                      : _buildPlaceholderImage(bait.category),
                ),
                const SizedBox(width: 16),
                
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bait.brand != null) ...[
                        Text(
                          bait.brand!.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      
                      Text(
                        bait.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Text(bait.category.icon, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text(bait.category.displayName),
                          if (bait.subcategory != null) ...[
                            const Text(' • '),
                            Text(bait.subcategory!),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      if (bait.retailPriceUsd != null)
                        Text(
                          bait.priceDisplay,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      
                      if (bait.isCrappieSpecific)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Crappie Specific',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (bait.productDescription != null) ...[
              const SizedBox(height: 16),
              Text(
                bait.productDescription!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSpecifications(BuildContext context, Bait bait) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specifications',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (bait.availableColors.isNotEmpty) ...[
              _buildSpecRow(context, 'Available Colors', bait.availableColors.join(', ')),
              const SizedBox(height: 12),
            ],
            
            if (bait.availableSizes.isNotEmpty) ...[
              _buildSpecRow(context, 'Available Sizes', bait.availableSizes.join(', ')),
              const SizedBox(height: 12),
            ],
            
            if (bait.weightRangeMin != null || bait.weightRangeMax != null) ...[
              _buildSpecRow(context, 'Weight Range', bait.weightRangeDisplay),
              const SizedBox(height: 12),
            ],
            
            if (bait.modelNumber != null)
              _buildSpecRow(context, 'Model Number', bait.modelNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildReportsSection(BuildContext context, AsyncValue<List<BaitReport>> reportsAsync) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Reports',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            reportsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading reports: $error'),
              data: (reports) {
                if (reports.isEmpty) {
                  return const Center(
                    child: Column(
                      children: [
                        Icon(Icons.report_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('No reports yet'),
                        SizedBox(height: 4),
                        Text(
                          'Be the first to report results with this bait!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                
                return Column(
                  children: reports.take(5).map((report) => _buildReportTile(context, report)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(BuildContext context, BaitReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${report.colorUsed} ${report.sizeUsed}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                report.resultsDescription,
                style: TextStyle(
                  color: report.wasSuccessful ? Colors.green : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            report.conditionsDescription,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (report.notes != null && report.notes!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              report.notes!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BaitCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 4),
          Text(
            'No Image',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}