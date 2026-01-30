import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/place_model.dart';

/// Provider for bottom navigation index (shared)
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Provider to trigger map camera movement when city chip is tapped
final mapCameraTargetProvider = StateProvider<CameraPosition?>((ref) => null);

/// Helper function to move map to a specific place
void moveMapToPlace(WidgetRef ref, PlaceModel place, {double? zoom}) {
  final cameraPosition = CameraPosition(
    target: LatLng(place.latitude, place.longitude),
    zoom: zoom ?? 15.0, // Default zoom level for places
  );
  ref.read(mapCameraTargetProvider.notifier).state = cameraPosition;
}

/// Helper function to move map to coordinates
void moveMapToCoordinates(WidgetRef ref, double lat, double lng, {double? zoom}) {
  final cameraPosition = CameraPosition(
    target: LatLng(lat, lng),
    zoom: zoom ?? 12.0,
  );
  ref.read(mapCameraTargetProvider.notifier).state = cameraPosition;
}
