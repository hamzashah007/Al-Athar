import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'routes.dart';
import 'theme.dart';
import '../services/notification_service.dart';

final _router = createAppRouter();

class AlAtharApp extends ConsumerStatefulWidget {
  const AlAtharApp({Key? key}) : super(key: key);

  @override
  ConsumerState<AlAtharApp> createState() => _AlAtharAppState();
}

class _AlAtharAppState extends ConsumerState<AlAtharApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notificationService = NotificationService();
      await notificationService.requestPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.isDarkMode));
    return MaterialApp.router(
      title: 'Al Athar',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
