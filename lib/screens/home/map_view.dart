import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import '../../services/location_service.dart';

class MapView extends StatefulWidget {
  const MapView({Key? key}) : super(key: key);

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> with AutomaticKeepAliveClientMixin {
  GoogleMapController? _controller;
  bool _mapReady = false;
  bool _locationPermissionGranted = false;

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
      setState(() {
        _locationPermissionGranted = granted;
      });
    }
  }

  Future<void> _setMapStyle(bool isDark) async {
    if (_controller == null) return;

    try {
      final String style = await rootBundle.loadString(
        isDark
            ? 'assets/map_styles/dark_map_style.json'
            : 'assets/map_styles/light_map_style.json',
      );
      await _controller!.setMapStyle(style);
    } catch (e) {
      debugPrint('Error loading map style: $e');
    }
  }

  Future<void> _moveToCurrentLocation() async {
    if (_controller == null) return;

    final position = await LocationService.getCurrentLocation();
    if (position != null && mounted) {
      _controller!.animateCamera(
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            myLocationEnabled: _locationPermissionGranted,
            myLocationButtonEnabled: false, // We'll use custom button
            zoomControlsEnabled: false,
            liteModeEnabled: false,
            buildingsEnabled: false,
            onMapCreated: (controller) {
              _controller = controller;
              _setMapStyle(isDark);
              if (mounted) {
                setState(() => _mapReady = true);
              }
            },
          ),
          // Loading overlay
          if (!_mapReady)
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: const Center(child: CircularProgressIndicator()),
            ),
          // Custom location button
          if (_mapReady && _locationPermissionGranted)
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
    _controller?.dispose();
    super.dispose();
  }
}
