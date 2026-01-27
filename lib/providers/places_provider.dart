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

// Filtered places based on search and city
final filteredPlacesProvider = Provider<AsyncValue<List<PlaceModel>>>((ref) {
  final placesAsync = ref.watch(placesProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCity = ref.watch(selectedCityProvider);

  return placesAsync.when(
    data: (places) {
      var filtered = places;

      // Apply city filter
      if (selectedCity != null && selectedCity.isNotEmpty) {
        filtered = filtered
            .where((place) =>
                place.city.toLowerCase() == selectedCity.toLowerCase())
            .toList();
      }

      // Apply search filter
      if (searchQuery.isNotEmpty) {
        filtered = filtered
            .where((place) =>
                place.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                place.city.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
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
