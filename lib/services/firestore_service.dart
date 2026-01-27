import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/place_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService(this._firestore);

  /// Get all historical places from Firestore
  Stream<List<PlaceModel>> getPlaces() {
    try {
      return _firestore.collection('places').snapshots().map(
            (snapshot) => snapshot.docs
                .map((doc) => PlaceModel.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ Error fetching places: $e');
      rethrow;
    }
  }

  /// Get a single place by ID
  Future<PlaceModel?> getPlaceById(String placeId) async {
    try {
      final doc = await _firestore.collection('places').doc(placeId).get();
      if (doc.exists) {
        return PlaceModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching place $placeId: $e');
      return null;
    }
  }

  /// Get places by city
  Stream<List<PlaceModel>> getPlacesByCity(String city) {
    try {
      return _firestore
          .collection('places')
          .where('city', isEqualTo: city)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => PlaceModel.fromMap(doc.data(), doc.id))
                .toList(),
          );
    } catch (e) {
      debugPrint('❌ Error fetching places for city $city: $e');
      rethrow;
    }
  }

  /// Search places by name
  Future<List<PlaceModel>> searchPlaces(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a simple implementation. For production, consider using Algolia or similar
      final snapshot = await _firestore.collection('places').get();
      final places = snapshot.docs
          .map((doc) => PlaceModel.fromMap(doc.data(), doc.id))
          .toList();

      if (query.isEmpty) return places;

      return places
          .where((place) =>
              place.name.toLowerCase().contains(query.toLowerCase()) ||
              place.city.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error searching places: $e');
      return [];
    }
  }
}
