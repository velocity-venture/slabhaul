import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Brand Colors
// ---------------------------------------------------------------------------
class AppColors {
  static const Color teal = Color(0xFF0D9488);
  static const Color tealDark = Color(0xFF0F766E);
  static const Color tealLight = Color(0xFF2DD4BF);

  static const Color background = Color(0xFF0F172A);
  static const Color surface = Color(0xFF1E293B);
  static const Color card = Color(0xFF334155);
  static const Color cardBorder = Color(0xFF475569);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Attractor type colors
  static const Color brushPile = Color(0xFF22C55E);
  static const Color pvcTree = Color(0xFF3B82F6);
  static const Color stakeBed = Color(0xFFF97316);
  static const Color pallet = Color(0xFFEAB308);
  static const Color unknownType = Color(0xFF6B7280);

  // Wind speed colors
  static const Color windCalm = Color(0xFF22C55E);
  static const Color windModerate = Color(0xFFEAB308);
  static const Color windStrong = Color(0xFFF97316);
  static const Color windDangerous = Color(0xFFEF4444);
}

// ---------------------------------------------------------------------------
// API URLs
// ---------------------------------------------------------------------------
class ApiUrls {
  static const String openMeteoBase = 'https://api.open-meteo.com/v1/forecast';
  static const String usgsWaterServices =
      'https://waterservices.usgs.gov/nwis/iv/';
}

// ---------------------------------------------------------------------------
// Default Map Center (West Tennessee)
// ---------------------------------------------------------------------------
class MapDefaults {
  static const double defaultLat = 35.75;
  static const double defaultLon = -89.50;
  static const double defaultZoom = 8.0;
}

// ---------------------------------------------------------------------------
// Sinker Weight Presets
// ---------------------------------------------------------------------------
class SinkerWeights {
  static const List<double> values = [
    0.0625, // 1/16
    0.125, // 1/8
    0.1875, // 3/16
    0.25, // 1/4
    0.375, // 3/8
    0.5, // 1/2
    0.75, // 3/4
    1.0, // 1
    1.5, // 1-1/2
    2.0, // 2
  ];

  static String label(double oz) {
    if (oz == 0.0625) return '1/16 oz';
    if (oz == 0.125) return '1/8 oz';
    if (oz == 0.1875) return '3/16 oz';
    if (oz == 0.25) return '1/4 oz';
    if (oz == 0.375) return '3/8 oz';
    if (oz == 0.5) return '1/2 oz';
    if (oz == 0.75) return '3/4 oz';
    if (oz == 1.0) return '1 oz';
    if (oz == 1.5) return '1-1/2 oz';
    if (oz == 2.0) return '2 oz';
    return '${oz.toStringAsFixed(2)} oz';
  }
}

// ---------------------------------------------------------------------------
// Line Type Drag Factors
// ---------------------------------------------------------------------------
class LineTypes {
  static const Map<String, double> dragFactors = {
    'Mono': 1.0,
    'Fluoro': 0.8,
    'Braid': 0.7,
  };
}

// ---------------------------------------------------------------------------
// Glass Card Decoration
// ---------------------------------------------------------------------------
class GlassDecoration {
  static BoxDecoration card({double opacity = 0.6, double radius = 12}) {
    return BoxDecoration(
      color: AppColors.surface.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.cardBorder.withValues(alpha: 0.3),
      ),
    );
  }

  static BoxDecoration elevated({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.surface.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.teal.withValues(alpha: 0.15),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.teal.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

Color attractorColor(String type) {
  switch (type) {
    case 'brush_pile':
      return AppColors.brushPile;
    case 'pvc_tree':
      return AppColors.pvcTree;
    case 'stake_bed':
      return AppColors.stakeBed;
    case 'pallet':
      return AppColors.pallet;
    default:
      return AppColors.unknownType;
  }
}
