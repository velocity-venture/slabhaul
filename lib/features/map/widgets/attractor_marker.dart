import 'package:flutter/material.dart';
import 'package:slabhaul/core/utils/constants.dart';

/// A small circular marker displayed on the map for each attractor.
///
/// The circle's fill color is determined by [attractorColor] and the centre
/// icon indicates the attractor type.
class AttractorMarker extends StatelessWidget {
  final String type;

  const AttractorMarker({super.key, required this.type});

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

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
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
