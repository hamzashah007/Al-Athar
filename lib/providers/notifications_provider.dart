import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'auth_provider.dart';

final notificationsProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('user_notifications')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => AppNotification.fromMap(doc.data(), doc.id))
          .toList());
});
