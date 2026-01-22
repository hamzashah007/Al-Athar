import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_form_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

final loadingProvider = StateProvider<bool>((ref) => false);
final errorProvider = StateProvider<String?>((ref) => null);

// Controllers as providers to persist across rebuilds
final emailControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

final passwordControllerProvider = Provider.autoDispose<TextEditingController>((
  ref,
) {
  final controller = TextEditingController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class SignInScreen extends ConsumerWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final passwordVisible = ref.watch(signInPasswordVisibleProvider);
    final emailError = ref.watch(signInEmailErrorProvider);
    final passwordError = ref.watch(signInPasswordErrorProvider);
    final loading = ref.watch(loadingProvider);
    final errorMessage = ref.watch(errorProvider);

    void validateAndSubmit() async {
      debugPrint('SignIn: validateAndSubmit called');
      bool valid = true;
      ref.read(signInEmailErrorProvider.notifier).state = null;
      ref.read(signInPasswordErrorProvider.notifier).state = null;
      ref.read(errorProvider.notifier).state = null;
      final email = emailController.text;
      final password = passwordController.text;
      debugPrint('SignIn: Email=$email, Password length=${password.length}');
      final emailValidation = validateEmail(email);
      final passwordValidation = validatePassword(password);
      if (emailValidation != null) {
        debugPrint('SignIn: Email validation error=$emailValidation');
        ref.read(signInEmailErrorProvider.notifier).state = emailValidation;
        valid = false;
      }
      if (passwordValidation != null) {
        debugPrint('SignIn: Password validation error=$passwordValidation');
        ref.read(signInPasswordErrorProvider.notifier).state =
            passwordValidation;
        valid = false;
      }
      if (valid) {
        ref.read(loadingProvider.notifier).state = true;
        try {
          final authRepo = ref.read(authRepositoryProvider);
          final user = await authRepo.signIn(email, password);

          // Reset loading state before navigation
          ref.read(loadingProvider.notifier).state = false;

          if (user != null && context.mounted) {
            // Small delay for smooth transition
            await Future.delayed(const Duration(milliseconds: 100));
            if (context.mounted) {
              context.go('/home');
            }
          } else {
            ref.read(errorProvider.notifier).state =
                'Sign in failed. Please try again.';
          }
        } catch (e) {
          ref.read(errorProvider.notifier).state = e.toString();
          ref.read(loadingProvider.notifier).state = false;
        }
      }
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SvgPicture.asset(
                    'assets/icon.svg',
                    width: 70,
                    height: 70,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to Al-Athar',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onBackground.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
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
                    hint: 'Enter your password',
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
                                  .read(signInPasswordVisibleProvider.notifier)
                                  .state =
                              !passwordVisible,
                    ),
                    validator: (_) => passwordError,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: Implement forgot password navigation
                      },
                      child: Text(
                        'Forgot Password?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  CustomButton.elevated(
                    text: 'Sign In',
                    onPressed: loading ? null : validateAndSubmit,
                    isLoading: loading,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 12),
                  CustomButton.outlined(
                    text: 'Continue as Guest Mode',
                    onPressed: loading
                        ? null
                        : () async {
                            debugPrint('SignIn: Guest Mode button pressed');
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setBool('guestMode', true);
                            context.go('/home');
                          },
                    width: double.infinity,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: theme.textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/signup');
                        },
                        child: Text(
                          'Sign Up',
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
