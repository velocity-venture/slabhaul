import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Brand Colors (from style guide)
// ---------------------------------------------------------------------------
class AppColors {
  // Brand colors
  static const Color brandNavy = Color(0xFF13152E);
  static const Color brandIndigo = Color(0xFF283474);
  static const Color brandBlue = Color(0xFF89B4E0);

  // Primary interactive (keep "teal" name to avoid 75-file rename)
  static const Color teal = Color(0xFF283474);         // → brand indigo
  static const Color tealDark = Color(0xFF1E2A5E);     // darker indigo
  static const Color tealLight = Color(0xFF89B4E0);    // → brand blue

  // Surface colors (light theme)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFF1F5F9);
  static const Color cardBorder = Color(0xFFE2E8F0);

  // Text colors (dark on light)
  static const Color textPrimary = Color(0xFF13152E);   // brand navy
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF94A3B8);

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

  // Warm accents
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color copper = Color(0xFFE8853D);
  static const Color deepBlue = Color(0xFF1D4ED8);

  // Elevated surfaces
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color glassTint = Color(0xFFEFF6FF);     // light blue tint
  static const Color textBright = Color(0xFF13152E);     // navy (was white)

  // Wind speed colors
  static const Color windCalm = Color(0xFF22C55E);
  static const Color windModerate = Color(0xFFEAB308);
  static const Color windStrong = Color(0xFFF97316);
  static const Color windDangerous = Color(0xFFEF4444);
}

// ---------------------------------------------------------------------------
// Gradient Presets
// ---------------------------------------------------------------------------
class AppGradients {
  /// Indigo-to-blue diagonal for hero / top-pick cards
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF283474), Color(0xFF89B4E0)],
  );

  /// Subtle blue wash for standard cards
  static const LinearGradient tealWash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x18283474), Color(0x1089B4E0)],
  );

  /// Light scrim for map (white-to-transparent)
  static const LinearGradient sunsetOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xCCFFFFFF), // white 80%
      Color(0x40FFFFFF), // white 25%
      Colors.transparent,
      Color(0x80FFFFFF), // white 50%
    ],
    stops: [0.0, 0.15, 0.40, 1.0],
  );

  /// Indigo-to-blue gradient for borders
  static const LinearGradient glassBorder = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF283474), Color(0xFF89B4E0)],
  );

  /// Gold gradient for #1 ranked items
  static const LinearGradient rankGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFD700), Color(0xFFF59E0B)],
  );

  /// Score badge gradient — green
  static const LinearGradient scoreGreen = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  /// Score badge gradient — amber
  static const LinearGradient scoreAmber = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
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
  static BoxDecoration card({double opacity = 1.0, double radius = 12}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.cardBorder,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration elevated({double radius = 16}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: AppColors.cardBorder,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.brandIndigo.withValues(alpha: 0.08),
          blurRadius: 32,
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
