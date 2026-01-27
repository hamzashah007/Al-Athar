import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import '../../services/location_service.dart';
import '../../providers/places_provider.dart';
import '../../providers/home_provider.dart';
import '../../models/place_model.dart';
import 'place_bottom_sheet.dart';

// State providers for map
final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);
final mapReadyProvider = StateProvider<bool>((ref) => false);
final locationPermissionProvider = StateProvider<bool>((ref) => false);
final mapErrorProvider = StateProvider<String?>((ref) => null);

class MapView extends ConsumerStatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView>
    with AutomaticKeepAliveClientMixin {
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(21.3891, 39.8579), // Centered on Makkah
    zoom: 6.5,
  );

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    final granted = await LocationService.checkAndRequestPermission();
    if (mounted) {
      ref.read(locationPermissionProvider.notifier).state = granted;
    }
  }

  Set<Marker> _buildMarkers(List<PlaceModel> places) {
    return places.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.latitude, place.longitude),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: place.city,
        ),
        onTap: () => _onMarkerTapped(place),
      );
    }).toSet();
  }

  void _onMarkerTapped(PlaceModel place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlaceBottomSheet(place: place),
    );
  }

  Future<void> _setMapStyle(bool isDark) async {
    final controller = ref.read(mapControllerProvider);
    if (controller == null) return;
    try {
      final String style = await rootBundle.loadString(
        isDark
            ? 'assets/map_styles/dark_map_style.json'
            : 'assets/map_styles/light_map_style.json',
      );
      await controller.setMapStyle(style);
    } catch (e) {
      debugPrint('Error loading map style: $e');
      if (mounted) {
        ref.read(mapErrorProvider.notifier).state = 'Map style failed to load.';
      }
    }
  }

  Future<void> _moveToCurrentLocation() async {
    final controller = ref.read(mapControllerProvider);
    if (controller == null) return;

    final position = await LocationService.getCurrentLocation();
    if (position != null && mounted) {
      controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mapError = ref.watch(mapErrorProvider);
    final mapReady = ref.watch(mapReadyProvider);
    final locationGranted = ref.watch(locationPermissionProvider);
    final placesAsync = ref.watch(filteredPlacesProvider);

    // Listen for map camera target changes (when city chip is tapped)
    ref.listen<CameraPosition?>(mapCameraTargetProvider, (previous, next) {
      if (next != null && mounted) {
        final controller = ref.read(mapControllerProvider);
        controller?.animateCamera(CameraUpdate.newCameraPosition(next));
        // Reset the target after animation starts
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(mapCameraTargetProvider.notifier).state = null;
          }
        });
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          if (mapError != null)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 8),
                    Text(mapError, style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            )
          else
            placesAsync.when(
              data: (places) => Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _initialPosition,
                    myLocationEnabled: locationGranted,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    liteModeEnabled: false,
                    buildingsEnabled: false,
                    markers: _buildMarkers(places),
                    onMapCreated: (controller) {
                      try {
                        ref.read(mapControllerProvider.notifier).state = controller;
                        _setMapStyle(isDark);
                        if (mounted) {
                          ref.read(mapReadyProvider.notifier).state = true;
                        }
                      } catch (e) {
                        debugPrint('Map init error: $e');
                        if (mounted) {
                          ref.read(mapErrorProvider.notifier).state =
                              'Map failed to load.';
                        }
                      }
                    },
                  ),
                  // Show hint when no places found
                  if (places.isEmpty)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No places found. Try searching or selecting a different city.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              loading: () => Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text('Failed to load places',
                          style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ),
            ),
          // Loading overlay
          if (!mapReady && mapError == null)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
          // Custom location button
          if (mapReady && locationGranted && mapError == null)
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: _moveToCurrentLocation,
                child: const Icon(Icons.my_location, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    ref.read(mapControllerProvider)?.dispose();
    super.dispose();
  }
}
