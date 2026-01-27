import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/suggestion_model.dart';

// Provider for city suggestions with coordinates
final suggestionsProvider = Provider<List<SuggestionModel>>((ref) {
  return [
    SuggestionModel(
      id: '1',
      name: 'Makkah',
      order: 1,
      latitude: 21.4225,
      longitude: 39.8262,
      zoom: 12.0,
    ),
    SuggestionModel(
      id: '2',
      name: 'Madinah',
      order: 2,
      latitude: 24.4672,
      longitude: 39.6142,
      zoom: 12.0,
    ),
    SuggestionModel(
      id: '3',
      name: 'Taif',
      order: 3,
      latitude: 21.2622,
      longitude: 40.4117,
      zoom: 12.0,
    ),
    SuggestionModel(
      id: '4',
      name: 'Riyadh',
      order: 4,
      latitude: 24.7136,
      longitude: 46.6753,
      zoom: 11.0,
    ),
    SuggestionModel(
      id: '5',
      name: 'Jeddah',
      order: 5,
      latitude: 21.5433,
      longitude: 39.1728,
      zoom: 11.0,
    ),
  ];
});

// Future provider for Firestore-based suggestions (when you add Firebase)
// final firestoreSuggestionsProvider = StreamProvider<List<SuggestionModel>>((ref) {
//   // Return stream from Firestore
//   return FirebaseFirestore.instance
//       .collection('suggestions')
//       .orderBy('order')
//       .snapshots()
//       .map((snapshot) => snapshot.docs
//           .map((doc) => SuggestionModel.fromMap(doc.data(), doc.id))
//           .toList());
// });
