import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/suggestions_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/places_provider.dart';
import '../../providers/geofence_provider.dart';
import '../../widgets/permission_denied_dialog.dart';
import 'map_view.dart';

/// Provider to control lazy loading of the map
final mapReadyProvider = StateProvider<bool>((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _permissionDialogShown = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize geofencing after UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check location permission first
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      
      // Show dialog if location is denied
      if (!serviceEnabled && mounted && !_permissionDialogShown) {
        _permissionDialogShown = true;
        await PermissionDeniedDialog.showLocationServicesDisabled(context);
      } else if (permission == LocationPermission.denied && mounted && !_permissionDialogShown) {
        _permissionDialogShown = true;
        await PermissionDeniedDialog.showLocationDenied(context);
      }
      
      // Initialize geofence manager with navigation callback
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
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.notifications,
                color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
              onPressed: () {
                context.go('/notifications');
              },
            ),
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
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  final isSelected = selectedCity == suggestion.name;
                  return Card(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.2)
                        : null,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isSelected
                          ? BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            )
                          : BorderSide.none,
                    ),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        if (isSelected) {
                          // Deselect if already selected
                          ref.read(selectedCityProvider.notifier).state = null;
                        } else {
                          // Select the city
                          ref.read(selectedCityProvider.notifier).state = suggestion.name;
                        }
                      },
                      child: Container(
                        width: 100,
                        padding: const EdgeInsets.all(16),
                        alignment: Alignment.center,
                        child: Text(
                          suggestion.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : null,
                          ),
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
