import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isSignUp => _isSignUp;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void toggleSignUp() {
    _isSignUp = !_isSignUp;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signIn() async {
    if (emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _errorMessage = 'Please enter email and password.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    String? error;
    if (_isSignUp) {
      error = await _authService.signUpWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
    } else {
      error = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );
    }

    _isLoading = false;

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final error = await _authService.signInWithGoogle();

    _isLoading = false;

    if (error != null) {
      _errorMessage = error;
      notifyListeners();
    }
  }
}
