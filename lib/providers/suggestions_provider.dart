import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/suggestion_model.dart';

// Provider for city suggestions with coordinates and images
final suggestionsProvider = Provider<List<SuggestionModel>>((ref) {
  return [
    SuggestionModel(
      id: '1',
      name: 'Makkah',
      imageUrl: 'assets/suggestion_styles/Mecca.png',
      order: 1,
      latitude: 21.4225,
      longitude: 39.8262,
      zoom: 12.0,
    ),
    SuggestionModel(
      id: '2',
      name: 'Madinah',
      imageUrl: 'assets/suggestion_styles/madinah.png',
      order: 2,
      latitude: 24.4672,
      longitude: 39.6142,
      zoom: 12.0,
    ),
    SuggestionModel(
      id: '3',
      name: 'Taif',
      imageUrl: 'assets/suggestion_styles/taif.png',
      order: 3,
      latitude: 21.2622,
      longitude: 40.4117,
      zoom: 12.0,
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
