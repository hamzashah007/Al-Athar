import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bookmark_service.dart';
import '../models/place_model.dart';
import 'auth_provider.dart';
import 'places_provider.dart';

/// Provider for BookmarkService
final bookmarkServiceProvider = Provider<BookmarkService?>((ref) {
  final firestore = ref.watch(firestoreProvider);
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return BookmarkService(
          firestore: firestore,
          userId: user.uid,
        );
      }
      return null;
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Provider for bookmarked place IDs as a Set (for quick lookup)
final bookmarkedPlaceIdsProvider = StreamProvider<Set<String>>((ref) {
  final bookmarkService = ref.watch(bookmarkServiceProvider);

  if (bookmarkService == null) {
    return Stream.value(<String>{});
  }

  return bookmarkService.getBookmarkedPlaceIdsSet();
});

/// Provider to check if a specific place is bookmarked
final isPlaceBookmarkedProvider =
    Provider.family<bool, String>((ref, placeId) {
  final bookmarkedIds = ref.watch(bookmarkedPlaceIdsProvider);

  return bookmarkedIds.when(
    data: (ids) => ids.contains(placeId),
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Provider for list of bookmarked places (full PlaceModel objects)
final bookmarkedPlacesProvider = Provider<AsyncValue<List<PlaceModel>>>((ref) {
  final bookmarkedIds = ref.watch(bookmarkedPlaceIdsProvider);
  final allPlaces = ref.watch(placesProvider);

  return bookmarkedIds.when(
    data: (ids) {
      return allPlaces.when(
        data: (places) {
          final filtered = places.where((place) => ids.contains(place.id)).toList();
          return AsyncValue.data(filtered);
        },
        loading: () => const AsyncValue.loading(),
        error: (err, stack) => AsyncValue.error(err, stack),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
  );
});

/// Provider for toggling bookmark
final bookmarkToggleProvider =
    Provider.family<Future<void> Function(), String>((ref, placeId) {
  return () async {
    final bookmarkService = ref.read(bookmarkServiceProvider);
    if (bookmarkService == null) {
      throw Exception('User not authenticated');
    }
    await bookmarkService.toggleBookmark(placeId);
  };
});
