import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class PermissionDeniedDialog extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final bool canOpenSettings;

  const PermissionDeniedDialog({
    Key? key,
    required this.title,
    required this.message,
    this.icon = Icons.location_off,
    this.canOpenSettings = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: Icon(
        icon,
        size: 48,
        color: theme.colorScheme.error,
      ),
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Not Now'),
        ),
        if (canOpenSettings)
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
      ],
    );
  }

  /// Show location permission denied dialog
  static Future<void> showLocationDenied(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PermissionDeniedDialog(
        title: 'Location Access Needed',
        message:
            'Al-Athar needs your location to show nearby historical places and send notifications when you\'re close to them.',
        icon: Icons.location_off,
      ),
    );
  }

  /// Show notification permission denied dialog
  static Future<void> showNotificationDenied(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PermissionDeniedDialog(
        title: 'Notification Permission',
        message:
            'Enable notifications to receive alerts when you\'re near historical places.',
        icon: Icons.notifications_off,
        canOpenSettings: false,
      ),
    );
  }

  /// Show location services disabled dialog
  static Future<void> showLocationServicesDisabled(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const PermissionDeniedDialog(
        title: 'Location Services Disabled',
        message:
            'Please enable location services in your device settings to use this feature.',
        icon: Icons.location_disabled,
      ),
    );
  }
}
