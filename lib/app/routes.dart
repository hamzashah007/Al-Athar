import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/change_password_screen.dart';
import '../screens/settings/change_username_screen.dart';
import '../screens/notifications/notifications_screen.dart';

// Helper for no transition
CustomTransitionPage<T> noTransitionPage<T>({required Widget child}) =>
    CustomTransitionPage<T>(
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );

// Create a new router instance each time the app starts
GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const SplashScreen()),
      ),
      GoRoute(
        path: '/signin',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const SignInScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const SignUpScreen()),
      ),
      GoRoute(
        path: '/home',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const HomeScreen()),
      ),
      GoRoute(
        path: '/bookmarks',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const BookmarksScreen()),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const ProfileScreen()),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const SettingsScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const NotificationsScreen()),
      ),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const ChangePasswordScreen()),
      ),
      GoRoute(
        path: '/change-username',
        pageBuilder: (context, state) =>
            noTransitionPage(child: const ChangeUsernameScreen()),
      ),
    ],
  );
}
