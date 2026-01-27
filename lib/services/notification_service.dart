import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/place_model.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;
  
  // Callback for navigation (set from provider layer)
  Function(String placeId)? onNotificationTapped;

  NotificationService({
    FlutterLocalNotificationsPlugin? notificationsPlugin,
  }) : _notifications = notificationsPlugin ?? FlutterLocalNotificationsPlugin();

  /// Initialize notification plugin
  Future<void> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      debugPrint('✅ Notification service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize notifications: $e');
    }
  }

  /// Handle notification tap
  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && onNotificationTapped != null) {
      debugPrint('📱 Notification tapped with payload: $payload');
      onNotificationTapped!(payload);
    }
  }

  /// Request notification permission (iOS only, Android auto-grants)
  Future<bool> requestPermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final result = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        debugPrint('✅ iOS notification permission: $result');
        return result ?? false;
      }
      
      // Android 13+ requires runtime permission
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final result = await androidPlugin?.requestNotificationsPermission();
        debugPrint('✅ Android notification permission: $result');
        return result ?? true; // Pre-Android 13 doesn't need permission
      }

      return true;
    } catch (e) {
      debugPrint('❌ Failed to request notification permission: $e');
      return false;
    }
  }

  /// Show notification when user is near a place
  Future<void> showPlaceNearbyNotification(PlaceModel place) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'geofence_channel',
        'Place Nearby',
        channelDescription: 'Notifications when you are near a historical place',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        place.id.hashCode, // Use place ID hash as notification ID
        '📍 ${place.name}',
        place.shortHistory,
        details,
        payload: place.id, // Pass place ID for navigation
      );

      debugPrint('✅ Notification sent for: ${place.name}');
    } catch (e) {
      debugPrint('❌ Failed to show notification: $e');
    }
  }

  /// Cancel all notifications (for cleanup)
  Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
      debugPrint('✅ All notifications cancelled');
    } catch (e) {
      debugPrint('❌ Failed to cancel notifications: $e');
    }
  }
}
