import 'package:cloud_firestore/cloud_firestore.dart';

class BookmarkService {
  final FirebaseFirestore _firestore;
  final String userId;

  BookmarkService({
    required FirebaseFirestore firestore,
    required this.userId,
  }) : _firestore = firestore;

  /// Get bookmarks collection reference for current user
  CollectionReference get _bookmarksCollection =>
      _firestore.collection('users').doc(userId).collection('bookmarks');

  /// Add a place to bookmarks
  Future<void> addBookmark(String placeId) async {
    try {
      await _bookmarksCollection.doc(placeId).set({
        'placeId': placeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add bookmark: $e');
    }
  }

  /// Remove a place from bookmarks
  Future<void> removeBookmark(String placeId) async {
    try {
      await _bookmarksCollection.doc(placeId).delete();
    } catch (e) {
      throw Exception('Failed to remove bookmark: $e');
    }
  }

  /// Toggle bookmark (add if doesn't exist, remove if exists)
  Future<void> toggleBookmark(String placeId) async {
    try {
      final doc = await _bookmarksCollection.doc(placeId).get();
      if (doc.exists) {
        await removeBookmark(placeId);
      } else {
        await addBookmark(placeId);
      }
    } catch (e) {
      throw Exception('Failed to toggle bookmark: $e');
    }
  }

  /// Check if a place is bookmarked
  Future<bool> isBookmarked(String placeId) async {
    try {
      final doc = await _bookmarksCollection.doc(placeId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Get stream of bookmarked place IDs
  Stream<List<String>> getBookmarkedPlaceIds() {
    return _bookmarksCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  /// Get stream of all bookmarked place IDs as Set for quick lookup
  Stream<Set<String>> getBookmarkedPlaceIdsSet() {
    return getBookmarkedPlaceIds().map((ids) => ids.toSet());
  }
}
