import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// Clean card container replacing the old glassmorphism style.
/// Keeps the same constructor API so callers don't break.
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

  /// Hero card — white card with brand indigo left-border accent + shadow
  factory GlassContainer.hero({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 16,
  }) {
    return GlassContainer(
      key: key,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      tintColor: AppColors.surface,
      borderGradient: AppGradients.glassBorder,
      glow: [
        BoxShadow(
          color: AppColors.brandIndigo.withValues(alpha: 0.10),
          blurRadius: 16,
          spreadRadius: 1,
        ),
      ],
      child: child,
    );
  }

  /// Standard card — white card with border + light shadow
  factory GlassContainer.standard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double borderRadius = 14,
  }) {
    return GlassContainer(
      key: key,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      child: child,
    );
  }

  /// Compact card — white card, minimal border
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
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      backgroundGradient: backgroundGradient,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: tintColor ?? AppColors.surface,
        gradient: backgroundGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderGradient == null
            ? Border.all(
                color: borderColor ?? AppColors.cardBorder,
              )
            : null,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
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
