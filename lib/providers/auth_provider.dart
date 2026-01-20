import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

// Simple providers that directly access Firebase (already initialized in main)
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Auth state stream
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref);
});

class AuthRepository {
  final Ref ref;
  AuthRepository(this.ref);

  Future<User?> signIn(String email, String password) async {
    try {
      debugPrint('🔑 Attempting sign in for: $email');
      final auth = ref.read(firebaseAuthProvider);
      final userCred = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Sign in successful: ${userCred.user?.email}');
      return userCred.user;
    } catch (e) {
      debugPrint('❌ Sign in failed: $e');
      rethrow;
    }
  }

  Future<User?> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      debugPrint('📝 Attempting sign up for: $email');
      final auth = ref.read(firebaseAuthProvider);
      final userCred = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCred.user;
      if (user != null) {
        debugPrint('👤 Updating display name to: $displayName');
        await user.updateDisplayName(displayName);

        final userModel = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: displayName,
        );
        debugPrint('💾 Saving user to Firestore...');
        final firestore = ref.read(firestoreProvider);
        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());
        debugPrint('✅ Sign up successful: ${user.email}');
      }
      return user;
    } catch (e) {
      debugPrint('❌ Sign up failed: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🚪 Attempting sign out...');
      final auth = ref.read(firebaseAuthProvider);
      await auth.signOut();
      debugPrint('✅ Sign out successful');
    } catch (e) {
      debugPrint('❌ Sign out failed: $e');
      rethrow;
    }
  }
}
