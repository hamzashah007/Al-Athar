import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- UI State Providers for Auth Screens ---
final signInPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final signUpPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final signUpConfirmPasswordVisibleProvider = StateProvider<bool>((ref) => false);

final signInEmailErrorProvider = StateProvider<String?>((ref) => null);
final signInPasswordErrorProvider = StateProvider<String?>((ref) => null);
final signUpEmailErrorProvider = StateProvider<String?>((ref) => null);
final signUpPasswordErrorProvider = StateProvider<String?>((ref) => null);
final signUpConfirmPasswordErrorProvider = StateProvider<String?>((ref) => null);
