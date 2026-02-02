import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Controls whether the wind overlay is visible on the map.
final windEnabledProvider = StateProvider<bool>((ref) => false);
