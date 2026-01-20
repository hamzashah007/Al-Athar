import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/suggestion_model.dart';

// Provider for city suggestions
final suggestionsProvider = Provider<List<SuggestionModel>>((ref) {
  // For now, return hardcoded data
  // Later, this can fetch from Firestore
  return [
    SuggestionModel(id: '1', name: 'Makkah', order: 1),
    SuggestionModel(id: '2', name: 'Madinah', order: 2),
    SuggestionModel(id: '3', name: 'Taif', order: 3),
    SuggestionModel(id: '4', name: 'Riyadh', order: 4),
    SuggestionModel(id: '5', name: 'Jeddah', order: 5),
    SuggestionModel(id: '6', name: 'Abha', order: 6),
    SuggestionModel(id: '7', name: 'Dammam', order: 7),
    SuggestionModel(id: '8', name: 'Tabuk', order: 8),
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
