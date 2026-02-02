import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/utils/constants.dart';

class SkeletonCard extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonCard({super.key, this.height = 120, this.width});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardBorder,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({super.key, this.width = double.infinity, this.height = 14});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.cardBorder,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class WeatherCardSkeleton extends StatelessWidget {
  const WeatherCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLine(width: 120, height: 16),
            SizedBox(height: 12),
            SkeletonLine(width: 80, height: 32),
            SizedBox(height: 12),
            SkeletonLine(width: 200),
            SizedBox(height: 8),
            SkeletonLine(width: 160),
          ],
        ),
      ),
    );
  }
}
