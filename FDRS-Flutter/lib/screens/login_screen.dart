import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../viewmodels/login_viewmodel.dart';
import '../widgets/login_widgets.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(),
      child: Consumer<LoginViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const HeroBanner(),
                  PageTransitionSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> primaryAnimation,
                      Animation<double> secondaryAnimation,
                    ) {
                      return FadeThroughTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        child: child,
                      );
                    },
                    child: _buildPage(model),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPage(LoginViewModel model) {
    return Column(
      children: [
        // Error message
        if (model.errorMessage != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withAlpha(77)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.redAccent, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      model.errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        LoginForm(
          onSignInPressed: model.isLoading ? () {} : model.signIn,
          emailController: model.emailController,
          passwordController: model.passwordController,
          isSignUp: model.isSignUp,
          isLoading: model.isLoading,
        ),
        SocialSignIn(
          onGoogleSignInPressed:
              model.isLoading ? () {} : model.signInWithGoogle,
          onToggleSignUp: model.toggleSignUp,
          isSignUp: model.isSignUp,
          isLoading: model.isLoading,
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
