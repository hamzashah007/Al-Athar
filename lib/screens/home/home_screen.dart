import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../providers/suggestions_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/geofence_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notifications_provider.dart';
import '../../widgets/permission_denied_dialog.dart';
import '../../widgets/location_permission_handler.dart';
import 'map_view.dart';

/// Provider to control lazy loading of the map
final mapReadyProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Request location permission on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocationPermissionHandler.requestLocationPermission(context);
    });

    // Initialize geofencing after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      debugPrint('HomeScreen: Calling geofenceManager.initialize()');
      // No direct permission check or dialog here; handled by LocationPermissionHandler
      final geofenceManager = ref.read(geofenceManagerProvider);
      geofenceManager.initialize(
        onNotificationTapped: (placeId) {
          if (mounted) {
            context.push('/place-details/$placeId');
          }
        },
      );
      // Delay map loading slightly to let home screen UI render first
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(mapReadyProvider.notifier).state = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<User?>>(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          debugPrint('HomeScreen: authStateProvider user detected, initializing geofencing');
          final geofenceManager = ref.read(geofenceManagerProvider);
          geofenceManager.initialize(
            onNotificationTapped: (placeId) {
              if (mounted) {
                context.push('/place-details/$placeId');
              }
            },
          );
        }
      });
    });

    final theme = Theme.of(context);
    final suggestions = ref.watch(suggestionsProvider);
    final mapReady = ref.watch(mapReadyProvider);
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Athar'),
        elevation: 0,
        backgroundColor: theme.colorScheme.background,
        foregroundColor: theme.colorScheme.primary,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final notificationsAsync = ref.watch(notificationsProvider);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                      ),
                      onPressed: () {
                        context.go('/notifications');
                      },
                    ),
                    notificationsAsync.when(
                      data: (notifications) {
                        final unreadCount = notifications.where((n) => !n.read).length;
                        if (unreadCount == 0) return const SizedBox.shrink();
                        return Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
                },
                decoration: InputDecoration(
                  hintText: 'Search historical places...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Suggestions',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final isSelected = selectedCity == suggestion.name;
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        // Deselect if already selected
                        ref.read(selectedCityProvider.notifier).state = null;
                      } else {
                        // Select the city
                        ref.read(selectedCityProvider.notifier).state = suggestion.name;
                        // Move map to city location
                        if (suggestion.latitude != null && suggestion.longitude != null) {
                          final cameraPosition = CameraPosition(
                            target: LatLng(suggestion.latitude!, suggestion.longitude!),
                            zoom: suggestion.zoom ?? 12.0,
                          );
                          ref.read(mapCameraTargetProvider.notifier).state = cameraPosition;
                        }
                      }
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 130,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: isSelected ? 12 : 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image
                            if (suggestion.imageUrl != null)
                              suggestion.imageUrl!.startsWith('http')
                                  ? Image.network(
                                      suggestion.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary.withOpacity(0.7),
                                                theme.colorScheme.secondary.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      suggestion.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.colorScheme.primary.withOpacity(0.7),
                                                theme.colorScheme.secondary.withOpacity(0.7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                        );
                                      },
                                    )
                            else
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(0.7),
                                      theme.colorScheme.secondary.withOpacity(0.7),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            // Gradient Overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Selected Border Overlay
                            if (isSelected)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.primary,
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            // City Name
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    suggestion.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      height: 3,
                                      width: 30,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: mapReady
                    ? const MapView()
                    : Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).state = index;
          if (index == 1) {
            // Navigate to Bookmarks
            context.go('/bookmarks');
          } else if (index == 2) {
            // Navigate to Settings
            context.go('/settings');
          }
          // Home (index 0) stays on this screen
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'BookMark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
