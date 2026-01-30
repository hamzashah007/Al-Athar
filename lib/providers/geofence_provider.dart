import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../services/geofence_service.dart';
import 'places_provider.dart';
import 'auth_provider.dart';

/// Provider for NotificationService
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider for GeofenceService
final geofenceServiceProvider = Provider<GeofenceService>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  
  // Get places stream directly from Firestore service
  final firestoreService = ref.watch(firestoreServiceProvider);
  final placesStream = firestoreService.getPlaces();

  return GeofenceService(
    notificationService: notificationService,
    placesStream: placesStream,
  );
});

/// Provider to track if geofencing is active
final geofenceActiveProvider = StateProvider<bool>((ref) => false);

/// Provider to initialize and manage geofencing lifecycle
final geofenceManagerProvider = Provider<GeofenceManager>((ref) {
  return GeofenceManager(ref);
});

class GeofenceManager {
  final Ref ref;

  GeofenceManager(this.ref);

  /// Initialize notification service and start geofencing
  Future<void> initialize({
    required Function(String placeId) onNotificationTapped,
  }) async {
    try {
      // Initialize notification service
      final notificationService = ref.read(notificationServiceProvider);
      notificationService.onNotificationTapped = onNotificationTapped;
      await notificationService.initialize();

      // Request notification permission
      final permissionGranted = await notificationService.requestPermission();
      if (!permissionGranted) {
        debugPrint('⚠️ Notification permission not granted');
      }

      // Check if user is authenticated
      final authState = ref.read(authStateProvider);
      await authState.when(
        data: (user) async {
          if (user != null) {
            // Start geofencing for authenticated users
            await startGeofencing();
          }
        },
        loading: () async {},
        error: (e, stack) async {},
      );
    } catch (e) {
      debugPrint('❌ Failed to initialize geofence manager: $e');
    }
  }

  /// Start geofence monitoring
  Future<void> startGeofencing() async {
    debugPrint('GeofenceManager: startGeofencing called');
    try {
      final geofenceService = ref.read(geofenceServiceProvider);
      await geofenceService.startMonitoring();
      ref.read(geofenceActiveProvider.notifier).state = true;
      debugPrint('✅ Geofencing started');
    } catch (e) {
      debugPrint('❌ Failed to start geofencing: $e');
    }
  }

  /// Stop geofence monitoring
  Future<void> stopGeofencing() async {
    try {
      final geofenceService = ref.read(geofenceServiceProvider);
      await geofenceService.stopMonitoring();
      ref.read(geofenceActiveProvider.notifier).state = false;
      debugPrint('🛑 Geofencing stopped');
    } catch (e) {
      debugPrint('❌ Failed to stop geofencing: $e');
    }
  }
}
