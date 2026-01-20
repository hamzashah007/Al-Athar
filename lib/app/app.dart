import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import 'routes.dart';
import 'theme.dart';

final _router = createAppRouter();

class AlAtharApp extends ConsumerWidget {
  const AlAtharApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(settingsProvider.select((s) => s.isDarkMode));
    return MaterialApp.router(
      title: 'Al-Athar',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
