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
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlaces();
});

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Selected city filter
final selectedCityProvider = StateProvider<String?>((ref) => null);

// Filtered places based on search and city (Google Maps style with fuzzy matching)
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

      // Apply enhanced search filter (Google Maps style with fuzzy matching)
      if (searchQuery.isNotEmpty) {
        // Split search query into words for better matching
        final queryWords = searchQuery.split(' ').where((w) => w.isNotEmpty).toList();
        
        filtered = filtered.where((place) {
          final placeName = place.name.toLowerCase();
          final placeCity = place.city.toLowerCase();
          final shortHistory = place.shortHistory.toLowerCase();
          final fullHistory = place.fullHistory.toLowerCase();
          
          // For each query word, check if it matches any field
          return queryWords.every((queryWord) {
            // Direct contains in name (highest priority)
            if (placeName.contains(queryWord)) return true;
            
            // Direct contains in city
            if (placeCity.contains(queryWord)) return true;
            
            // Check individual words in name (word boundaries)
            final nameWords = placeName.split(' ');
            if (nameWords.any((word) => 
                word.startsWith(queryWord) || 
                word.contains(queryWord) ||
                queryWord.contains(word))) return true;
            
            // Check individual words in city
            final cityWords = placeCity.split(' ');
            if (cityWords.any((word) => 
                word.startsWith(queryWord) || 
                word.contains(queryWord))) return true;
            
            // Search in history fields (lower priority)
            if (shortHistory.contains(queryWord)) return true;
            if (fullHistory.contains(queryWord)) return true;
            
            // Check for partial matches (fuzzy)
            // e.g., "masjid" matches "masjid", "mosque", etc.
            if (queryWord.length >= 3) {
              // Check if name contains at least 70% of query characters
              int matchCount = 0;
              for (var char in queryWord.split('')) {
                if (placeName.contains(char)) matchCount++;
              }
              if (matchCount / queryWord.length >= 0.7) return true;
            }
            
            return false;
          });
        }).toList();
        
        // Sort results by relevance (enhanced)
        filtered.sort((a, b) {
          final aName = a.name.toLowerCase();
          final bName = b.name.toLowerCase();
          final aCity = a.city.toLowerCase();
          final bCity = b.city.toLowerCase();
          int scoreA = 0;
          int scoreB = 0;
          for (var queryWord in queryWords) {
            // Exact full match (highest score)
            if (aName == searchQuery) scoreA += 100;
            if (bName == searchQuery) scoreB += 100;
            // Exact word match
            if (aName == queryWord) scoreA += 50;
            if (bName == queryWord) scoreB += 50;
            // Name starts with query
            if (aName.startsWith(queryWord)) scoreA += 30;
            if (bName.startsWith(queryWord)) scoreB += 30;
            // Name contains query
            if (aName.contains(queryWord)) scoreA += 20;
            if (bName.contains(queryWord)) scoreB += 20;
            // Individual word in name starts with query
            if (aName.split(' ').any((w) => w.startsWith(queryWord))) scoreA += 15;
            if (bName.split(' ').any((w) => w.startsWith(queryWord))) scoreB += 15;
            // City match
            if (aCity.contains(queryWord)) scoreA += 10;
            if (bCity.contains(queryWord)) scoreB += 10;
            // History contains query
            if (a.shortHistory.toLowerCase().contains(queryWord)) scoreA += 5;
            if (b.shortHistory.toLowerCase().contains(queryWord)) scoreB += 5;
          }
          // Sort by score (higher score first)
          if (scoreA != scoreB) return scoreB.compareTo(scoreA);
          // If same score, alphabetical
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
