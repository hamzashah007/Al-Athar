import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/location_permission_handler.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen: initState called');
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    // Request location permission on splash
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocationPermissionHandler.requestLocationPermission(context);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final guestMode = prefs.getBool('guestMode') ?? false;
        if (guestMode) {
          debugPrint('SplashScreen: Guest mode active, navigating to /home');
          context.go('/home');
        } else {
          _navigateBasedOnAuthState();
        }
      }
    });
  }

  void _navigateBasedOnAuthState() {
    if (_navigating || !mounted) return;

    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        _navigating = true;
        Future.microtask(() {
          if (!mounted) return;
          if (user != null) {
            debugPrint('SplashScreen: User logged in, navigating to /home');
            context.go('/home');
          } else {
            debugPrint('SplashScreen: No user, navigating to /signin');
            context.go('/signin');
          }
        });
      },
      loading: () {
        // Still loading, wait and retry
        debugPrint('SplashScreen: Auth still loading, waiting...');
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _navigateBasedOnAuthState();
        });
      },
      error: (_, __) {
        _navigating = true;
        Future.microtask(() {
          if (!mounted) return;
          debugPrint('SplashScreen: Auth error, navigating to /signin');
          context.go('/signin');
        });
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Full width faded background logo
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(0, 0),
                  child: Opacity(
                    opacity: 0.15,
                    child: SvgPicture.asset(
                      'assets/icon.svg',
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        colorScheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              // Main splash logo, overlapping and centered
              Center(
                child: SvgPicture.asset(
                  'assets/splashscreen.svg',
                  width: 300,
                  height: 120,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
