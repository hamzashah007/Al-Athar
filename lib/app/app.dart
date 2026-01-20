import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'routes.dart';
import 'theme.dart';

class AlAtharApp extends StatefulWidget {
  const AlAtharApp({Key? key}) : super(key: key);

  @override
  State<AlAtharApp> createState() => _AlAtharAppState();
}

class _AlAtharAppState extends State<AlAtharApp> {
  // Create router in state so it's recreated on hot restart
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Al-Athar',
      theme: appTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.system,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
