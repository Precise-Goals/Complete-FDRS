import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'database_service.dart';
import 'service_locator.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  User? _user;
  String? _error;

  User? get user => _user;
  String? get error => _error;

  bool get isLoggedIn => _user != null;

  AuthService() {
    _firebaseAuth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();

      // Persist user data to RTDB /users/{uid} on every login
      if (user != null) {
        _saveUserToRTDB(user);
      }
    });
  }

  Future<void> _saveUserToRTDB(User user) async {
    try {
      final dbService = locator<DatabaseService>();
      await dbService.saveUserData(
        uid: user.uid,
        email: user.email,
        lastLogin: DateTime.now().toUtc().toIso8601String(),
      );
    } catch (e) {
      debugPrint('[Auth] Failed to save user to RTDB: $e');
    }
  }

  /// Sign in with email and password
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _error = null;
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      notifyListeners();
      return _error;
    } catch (e) {
      _error = 'Sign in failed. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  /// Sign up (create account) with email and password
  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      _error = null;
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      notifyListeners();
      return _error;
    } catch (e) {
      _error = 'Sign up failed. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  /// Sign in with Google
  Future<String?> signInWithGoogle() async {
    try {
      _error = null;

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled the sign-in
        return 'Google sign-in cancelled.';
      }

      // Obtain the auth details from the Google sign-in
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      await _firebaseAuth.signInWithCredential(credential);
      return null; // success
    } catch (e) {
      debugPrint('[Auth] Google sign-in error: $e');
      _error = 'Google sign-in failed. Please try again.';
      notifyListeners();
      return _error;
    }
  }

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
    } on FirebaseAuthException catch (e) {
      debugPrint('[Auth] Anonymous sign-in error: ${e.message}');
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
  }

  void signIn() {
    notifyListeners();
  }

  /// Maps Firebase auth error codes to user-friendly messages
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials. Please check and try again.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
