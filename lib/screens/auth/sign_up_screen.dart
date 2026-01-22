import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';

final _signUpAgreedProvider = StateProvider<bool>((ref) => false);
final _signUpAgreedErrorProvider = StateProvider<bool>((ref) => false);
final signUpLoadingProvider = StateProvider<bool>((ref) => false);
final signUpErrorProvider = StateProvider<String?>((ref) => null);

final _nameControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final _emailControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final _passwordControllerProvider = Provider.autoDispose<TextEditingController>(
  (ref) {
    final controller = TextEditingController();
    ref.onDispose(() => controller.dispose());
    return controller;
  },
);

final _confirmPasswordControllerProvider =
    Provider.autoDispose<TextEditingController>((ref) {
      final controller = TextEditingController();
      ref.onDispose(() => controller.dispose());
      return controller;
    });

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final nameController = ref.watch(_nameControllerProvider);
    final emailController = ref.watch(_emailControllerProvider);
    final passwordController = ref.watch(_passwordControllerProvider);
    final confirmPasswordController = ref.watch(
      _confirmPasswordControllerProvider,
    );
    final passwordVisible = ref.watch(signUpPasswordVisibleProvider);
    final confirmPasswordVisible = ref.watch(
      signUpConfirmPasswordVisibleProvider,
    );
    final emailError = ref.watch(signUpEmailErrorProvider);
    final passwordError = ref.watch(signUpPasswordErrorProvider);
    final confirmPasswordError = ref.watch(signUpConfirmPasswordErrorProvider);
    final agreed = ref.watch(_signUpAgreedProvider);
    final agreedError = !agreed && ref.watch(_signUpAgreedErrorProvider)
        ? 'Please accept terms and Conditions'
        : null;
    final loading = ref.watch(signUpLoadingProvider);
    final errorMessage = ref.watch(signUpErrorProvider);

    void validateAndSubmit() async {
      bool valid = true;
      ref.read(signUpEmailErrorProvider.notifier).state = null;
      ref.read(signUpPasswordErrorProvider.notifier).state = null;
      ref.read(signUpConfirmPasswordErrorProvider.notifier).state = null;
      ref.read(_signUpAgreedErrorProvider.notifier).state = false;
      ref.read(signUpErrorProvider.notifier).state = null;

      final name = nameController.text;
      final email = emailController.text;
      final password = passwordController.text;
      final confirmPassword = confirmPasswordController.text;
      final emailValidation = validateEmail(email);
      final passwordValidation = validatePassword(password);
      final confirmPasswordValidation = validateConfirmPassword(
        confirmPassword,
        password,
      );

      if (emailValidation != null) {
        ref.read(signUpEmailErrorProvider.notifier).state = emailValidation;
        valid = false;
      }
      if (passwordValidation != null) {
        ref.read(signUpPasswordErrorProvider.notifier).state =
            passwordValidation;
        valid = false;
      }
      if (confirmPasswordValidation != null) {
        ref.read(signUpConfirmPasswordErrorProvider.notifier).state =
            confirmPasswordValidation;
        valid = false;
      }
      if (!ref.read(_signUpAgreedProvider)) {
        ref.read(_signUpAgreedErrorProvider.notifier).state = true;
        valid = false;
      }
      if (valid) {
        ref.read(signUpLoadingProvider.notifier).state = true;
        try {
          final authRepo = ref.read(authRepositoryProvider);
          final user = await authRepo.signUp(email, password, name);

          // Reset loading state before navigation
          ref.read(signUpLoadingProvider.notifier).state = false;

          if (user != null && context.mounted) {
            // Small delay for smooth transition
            await Future.delayed(const Duration(milliseconds: 100));
            // Sign out after registration
            await authRepo.signOut();
            if (context.mounted) {
              context.go('/signin');
            }
          } else {
            ref.read(signUpErrorProvider.notifier).state =
                'Sign up failed. Please try again.';
          }
        } catch (e) {
          ref.read(signUpErrorProvider.notifier).state = e.toString();
          ref.read(signUpLoadingProvider.notifier).state = false;
        }
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        resizeToAvoidBottomInset: true, // <-- changed from false
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              // Removed NeverScrollableScrollPhysics to allow scrolling
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    'assets/icon.svg',
                    width: 70,
                    height: 70,
                    colorFilter: ColorFilter.mode(
                      colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Create Account',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to join Al-Athar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    hint: 'Enter your full name',
                    controller: nameController,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Enter your email',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: colorScheme.primary,
                    ),
                    validator: (_) => emailError,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Create a password',
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colorScheme.primary,
                      ),
                      onPressed: () =>
                          ref
                                  .read(signUpPasswordVisibleProvider.notifier)
                                  .state =
                              !passwordVisible,
                    ),
                    validator: (_) => passwordError,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    hint: 'Re-enter your password',
                    controller: confirmPasswordController,
                    obscureText: !confirmPasswordVisible,
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: colorScheme.primary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        confirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colorScheme.primary,
                      ),
                      onPressed: () =>
                          ref
                                  .read(
                                    signUpConfirmPasswordVisibleProvider
                                        .notifier,
                                  )
                                  .state =
                              !confirmPasswordVisible,
                    ),
                    validator: (_) => confirmPasswordError,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: agreed,
                        onChanged: (val) {
                          ref.read(_signUpAgreedProvider.notifier).state =
                              val ?? false;
                          ref.read(_signUpAgreedErrorProvider.notifier).state =
                              false;
                        },
                        activeColor: colorScheme.primary,
                      ),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text('I agree to the '),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Terms of Use',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Text(' and '),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'Privacy Policy',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (agreedError != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                        top: 4,
                        bottom: 8,
                      ),
                      child: Text(
                        agreedError,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 28),
                  CustomButton.elevated(
                    text: 'Sign Up',
                    onPressed: loading ? null : validateAndSubmit,
                    isLoading: loading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.go('/signin'),
                        child: Text(
                          'Sign In',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: colorScheme.error),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
