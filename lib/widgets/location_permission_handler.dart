import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionHandler {
  static Future<void> requestLocationPermission(BuildContext context) async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) {
      // Permission already granted, do nothing
      return;
    }
    if (status.isDenied || status.isRestricted) {
      // Request permission if denied or restricted
      status = await Permission.locationWhenInUse.request();
      if (status.isGranted) return; // If granted after request, do nothing
      // If denied again, do nothing (don't show dialog)
      return;
    }
    if (status.isPermanentlyDenied) {
      // Only show dialog if permanently denied
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Location Permission Required'),
          content: const Text('Please enable location permission in app settings.'),
          actions: [
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }
}
