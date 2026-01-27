import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Provider for bottom navigation index (shared)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider to trigger map camera movement when city chip is tapped
final mapCameraTargetProvider = StateProvider<CameraPosition?>((ref) => null);
