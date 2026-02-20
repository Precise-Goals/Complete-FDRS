import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

class MainViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  bool get isLoggedIn => _authService.isLoggedIn;

  void onTabTapped(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
