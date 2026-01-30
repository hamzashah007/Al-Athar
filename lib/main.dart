import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/firebase_options.dart';
import 'app/app.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase (use default app for stability with hot reload)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('✅ Firebase initialized successfully!');

  // Initialize and request notification permissions
  final notificationService = NotificationService();
  await notificationService.initialize();
  bool permissionGranted = false;
  try {
    permissionGranted = await notificationService.requestPermission();
  } catch (e) {
    debugPrint('❌ Error requesting notification permission: $e');
  }

  // Catch Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: [31m${details.exception}[0m');
  };

  runApp(ProviderScope(child: AlAtharAppWithPermissionDialog(permissionGranted: permissionGranted)));
}

class AlAtharAppWithPermissionDialog extends StatelessWidget {
  final bool permissionGranted;
  const AlAtharAppWithPermissionDialog({Key? key, required this.permissionGranted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        if (!permissionGranted) {
          // Show a dialog if permission is not granted
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                title: const Text('Notifications Disabled'),
                content: const Text('You have denied notification permission. You will not receive location-based alerts.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }
        return const AlAtharApp();
      },
      home: const SizedBox.shrink(), // Required for builder
      debugShowCheckedModeBanner: false,
    );
  }
}
