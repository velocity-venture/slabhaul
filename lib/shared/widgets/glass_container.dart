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
  final Color? tintColor;
  final Gradient? backgroundGradient;
  final List<BoxShadow>? glow;
  final Gradient? borderGradient;

  const GlassContainer({
    super.key,
    required this.child,
    this.blurSigma = 16,
    this.opacity = 0.22,
    this.borderRadius = 16,
    this.borderColor,
    this.padding,
    this.margin,
    this.tintColor,
    this.backgroundGradient,
    this.glow,
    this.borderGradient,
  });

  /// Hero card — highest visual emphasis with teal tint, gradient border, glow
  factory GlassContainer.hero({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 16,
  }) {
    return GlassContainer(
      key: key,
      blurSigma: 20,
      opacity: 0.28,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      tintColor: AppColors.glassTint,
      borderGradient: AppGradients.glassBorder,
      glow: [
        BoxShadow(
          color: AppColors.teal.withValues(alpha: 0.15),
          blurRadius: 24,
          spreadRadius: 2,
        ),
      ],
      child: child,
    );
  }

  /// Standard card — balanced glass effect
  factory GlassContainer.standard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 14,
  }) {
    return GlassContainer(
      key: key,
      blurSigma: 16,
      opacity: 0.22,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Compact card — minimal glass for small elements
  factory GlassContainer.compact({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 12,
    Gradient? backgroundGradient,
  }) {
    return GlassContainer(
      key: key,
      blurSigma: 10,
      opacity: 0.18,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      backgroundGradient: backgroundGradient,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fillColor = tintColor ?? AppColors.surface;

    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor.withValues(alpha: opacity),
            gradient: backgroundGradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: borderGradient == null
                ? Border.all(
                    color: borderColor ??
                        AppColors.cardBorder.withValues(alpha: 0.4),
                  )
                : null,
          ),
          child: child,
        ),
      ),
    );

    // Wrap with gradient border if specified
    if (borderGradient != null) {
      content = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: borderGradient,
        ),
        padding: const EdgeInsets.all(1.5),
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: glow != null
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: glow,
            )
          : null,
      child: content,
    );
  }
}
