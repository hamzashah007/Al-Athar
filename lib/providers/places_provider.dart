import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/place_model.dart';
import '../services/firestore_service.dart';
import 'auth_provider.dart';

// Firestore service provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirestoreService(firestore);
});

// Stream of all places
final placesProvider = StreamProvider<List<PlaceModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlaces();
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected city filter
final selectedCityProvider = StateProvider<String?>((ref) => null);

// Filtered places based on search and city (Google Maps style)
final filteredPlacesProvider = Provider<AsyncValue<List<PlaceModel>>>((ref) {
  final placesAsync = ref.watch(placesProvider);
  final searchQuery = ref.watch(searchQueryProvider).trim().toLowerCase();
  final selectedCity = ref.watch(selectedCityProvider);

  return placesAsync.when(
    data: (places) {
      var filtered = places;

      // Apply city filter first
      if (selectedCity != null && selectedCity.isNotEmpty) {
        filtered = filtered
            .where((place) =>
                place.city.toLowerCase() == selectedCity.toLowerCase())
            .toList();
      }

      // Apply enhanced search filter (Google Maps style)
      if (searchQuery.isNotEmpty) {
        filtered = filtered.where((place) {
          final placeName = place.name.toLowerCase();
          final placeCity = place.city.toLowerCase();
          final shortHistory = place.shortHistory.toLowerCase();
          final fullHistory = place.fullHistory.toLowerCase();
          
          // Search in multiple fields
          return placeName.contains(searchQuery) ||
              placeCity.contains(searchQuery) ||
              shortHistory.contains(searchQuery) ||
              fullHistory.contains(searchQuery) ||
              // Support partial word matching
              placeName.split(' ').any((word) => word.startsWith(searchQuery)) ||
              placeCity.split(' ').any((word) => word.startsWith(searchQuery));
        }).toList();
        
        // Sort results by relevance
        filtered.sort((a, b) {
          // Exact name match gets highest priority
          if (a.name.toLowerCase() == searchQuery) return -1;
          if (b.name.toLowerCase() == searchQuery) return 1;
          
          // Name starts with query
          final aNameStarts = a.name.toLowerCase().startsWith(searchQuery);
          final bNameStarts = b.name.toLowerCase().startsWith(searchQuery);
          if (aNameStarts && !bNameStarts) return -1;
          if (!aNameStarts && bNameStarts) return 1;
          
          // Name contains query
          final aNameContains = a.name.toLowerCase().contains(searchQuery);
          final bNameContains = b.name.toLowerCase().contains(searchQuery);
          if (aNameContains && !bNameContains) return -1;
          if (!aNameContains && bNameContains) return 1;
          
          // City match
          final aCityMatch = a.city.toLowerCase().contains(searchQuery);
          final bCityMatch = b.city.toLowerCase().contains(searchQuery);
          if (aCityMatch && !bCityMatch) return -1;
          if (!aCityMatch && bCityMatch) return 1;
          
          // Default alphabetical
          return a.name.compareTo(b.name);
        });
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

// Get a single place by ID
final placeByIdProvider =
    FutureProvider.family<PlaceModel?, String>((ref, placeId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlaceById(placeId);
});
