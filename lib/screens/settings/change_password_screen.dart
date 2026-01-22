import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart' as validators;

final _oldPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final _newPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final _confirmPasswordVisibleProvider = StateProvider<bool>((ref) => false);

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    // Validation
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (oldPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your current password';
        _isLoading = false;
      });
      return;
    }

    final passwordError = validators.validatePassword(newPassword);
    if (passwordError != null) {
      setState(() {
        _errorMessage = passwordError;
        _isLoading = false;
      });
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage = 'New passwords do not match';
        _isLoading = false;
      });
      return;
    }

    if (oldPassword == newPassword) {
      setState(() {
        _errorMessage = 'New password must be different from current password';
        _isLoading = false;
      });
      return;
    }

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user == null || user.email == null) {
        throw Exception('No user logged in');
      }

      // Re-authenticate user with old password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password changed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } on FirebaseAuthException catch (e) {
      String errorMsg = 'Failed to change password';
      if (e.code == 'wrong-password') {
        errorMsg = 'Current password is incorrect';
      } else if (e.code == 'weak-password') {
        errorMsg = 'New password is too weak';
      } else if (e.code == 'requires-recent-login') {
        errorMsg = 'Please log out and log in again before changing password';
      }
      setState(() {
        _errorMessage = errorMsg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final oldPasswordVisible = ref.watch(_oldPasswordVisibleProvider);
    final newPasswordVisible = ref.watch(_newPasswordVisibleProvider);
    final confirmPasswordVisible = ref.watch(_confirmPasswordVisibleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.lock_reset, size: 64, color: theme.colorScheme.primary),
            const SizedBox(height: 24),
            Text(
              'Change Your Password',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your current password and choose a new one',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Current Password
            CustomTextField(
              hint: 'Current Password',
              controller: _oldPasswordController,
              obscureText: !oldPasswordVisible,
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  oldPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    ref.read(_oldPasswordVisibleProvider.notifier).state =
                        !oldPasswordVisible,
              ),
            ),
            const SizedBox(height: 16),

            // New Password
            CustomTextField(
              hint: 'New Password',
              controller: _newPasswordController,
              obscureText: !newPasswordVisible,
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  newPasswordVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () =>
                    ref.read(_newPasswordVisibleProvider.notifier).state =
                        !newPasswordVisible,
              ),
            ),
            const SizedBox(height: 16),

            // Confirm New Password
            CustomTextField(
              hint: 'Confirm New Password',
              controller: _confirmPasswordController,
              obscureText: !confirmPasswordVisible,
              keyboardType: TextInputType.visiblePassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  confirmPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed: () =>
                    ref.read(_confirmPasswordVisibleProvider.notifier).state =
                        !confirmPasswordVisible,
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            CustomButton.elevated(
              text: 'Change Password',
              onPressed: _isLoading ? null : _changePassword,
              isLoading: _isLoading,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            CustomButton.text(
              text: 'Cancel',
              onPressed: _isLoading ? null : () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
