import 'package:flutter/material.dart';
import 'package:slabhaul/core/models/water_clarity.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// A small circular marker displayed on the map for each attractor.
///
/// The circle's fill color is determined by [attractorColor] and the centre
/// icon indicates the attractor type. When [clarityLevel] is provided the
/// marker adjusts its glow intensity so markers stand out more in
/// low-visibility conditions.
class AttractorMarker extends StatelessWidget {
  final String type;
  final ClarityLevel? clarityLevel;

  const AttractorMarker({super.key, required this.type, this.clarityLevel});

  IconData _iconForType(String type) {
    switch (type) {
      case 'brush_pile':
        return Icons.water_drop;
      case 'pvc_tree':
        return Icons.park;
      case 'stake_bed':
        return Icons.grid_on;
      case 'pallet':
        return Icons.dashboard;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = attractorColor(type);

    // Adjust glow based on clarity
    final double fillOpacity;
    final double blurRadius;
    final double spreadRadius;
    final Color shadowColor;

    switch (clarityLevel) {
      case ClarityLevel.muddy:
        fillOpacity = 0.75;
        blurRadius = 14;
        spreadRadius = 3;
        shadowColor = Colors.white.withValues(alpha: 0.35);
      case ClarityLevel.stained:
        fillOpacity = 0.80;
        blurRadius = 10;
        spreadRadius = 2;
        shadowColor = color.withValues(alpha: 0.55);
      case ClarityLevel.crystal:
      case ClarityLevel.clear:
      case ClarityLevel.lightStain:
      case null:
        fillOpacity = 0.85;
        blurRadius = 6;
        spreadRadius = 1;
        shadowColor = color.withValues(alpha: 0.4);
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: fillOpacity),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: Icon(
        _iconForType(type),
        color: Colors.white,
        size: 18,
      ),
    );
  }
}
