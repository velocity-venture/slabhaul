import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// Reusable glassmorphism container with backdrop blur and semi-transparent fill.
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blurSigma;
  final double opacity;
  final double borderRadius;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 12,
    this.opacity = 0.15,
    this.borderRadius = 16,
    this.borderColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ??
                    AppColors.cardBorder.withValues(alpha: 0.3),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
