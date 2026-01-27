import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';
import 'notification_service.dart';

class GeofenceService {
  final NotificationService _notificationService;
  final Stream<List<PlaceModel>> _placesStream;
  
  // Debounce cache: tracks last notification time per place
  final Map<String, DateTime> _notificationCache = {};
  
  // Geofence radius in meters
  static const double radiusMeters = 100.0;
  
  // Minimum time between notifications for same place (in minutes)
  static const int cooldownMinutes = 30;
  
  StreamSubscription<Position>? _locationSubscription;
  List<PlaceModel> _currentPlaces = [];
  
  GeofenceService({
    required NotificationService notificationService,
    required Stream<List<PlaceModel>> placesStream,
  })  : _notificationService = notificationService,
        _placesStream = placesStream;

  /// Start monitoring user location and checking geofences
  Future<void> startMonitoring() async {
    try {
      // Check location permission
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        debugPrint('❌ Location permission not granted - geofencing disabled');
        return;
      }

      debugPrint('✅ Location permission granted - starting geofence monitoring');

      // Listen to places stream
      _placesStream.listen((places) {
        _currentPlaces = places;
        debugPrint('📍 Updated places list: ${places.length} places');
      });

      // Start listening to location updates
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update every 50 meters
      );

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        _onLocationUpdate,
        onError: (error) {
          debugPrint('❌ Location stream error: $error');
        },
      );

      debugPrint('✅ Geofence monitoring started');
    } catch (e) {
      debugPrint('❌ Failed to start geofence monitoring: $e');
    }
  }

  /// Stop monitoring
  Future<void> stopMonitoring() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    debugPrint('🛑 Geofence monitoring stopped');
  }

  /// Check if location permission is granted
  Future<bool> _checkLocationPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('❌ Location services disabled');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('❌ Location permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('❌ Location permission denied forever');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('❌ Error checking location permission: $e');
      return false;
    }
  }

  /// Handle location updates
  void _onLocationUpdate(Position position) {
    try {
      debugPrint('📍 Location update: ${position.latitude}, ${position.longitude}');

      for (final place in _currentPlaces) {
        final distance = _calculateDistance(
          position.latitude,
          position.longitude,
          place.latitude,
          place.longitude,
        );

        // Check if within geofence radius
        if (distance <= radiusMeters) {
          _handleGeofenceEntered(place, distance);
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing location update: $e');
    }
  }

  /// Handle geofence entry (with debounce)
  void _handleGeofenceEntered(PlaceModel place, double distance) {
    final now = DateTime.now();
    final lastNotified = _notificationCache[place.id];

    // Check if we already notified recently
    if (lastNotified != null) {
      final difference = now.difference(lastNotified);
      if (difference.inMinutes < cooldownMinutes) {
        debugPrint('⏳ Skipping notification for ${place.name} (cooldown active)');
        return;
      }
    }

    // Send notification
    debugPrint('✅ User entered geofence for: ${place.name} (${distance.toStringAsFixed(0)}m away)');
    _notificationService.showPlaceNearbyNotification(place);

    // Update cache
    _notificationCache[place.id] = now;
  }

  /// Calculate distance between two coordinates using Haversine formula
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadius = 6371000; // Earth radius in meters
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }

  /// Clear notification cache (e.g., on app restart)
  void clearCache() {
    _notificationCache.clear();
    debugPrint('🗑️ Notification cache cleared');
  }
}
