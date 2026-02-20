import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/service_locator.dart';

class ProfileViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();
  final DatabaseService _databaseService = locator<DatabaseService>();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String get userEmail => _authService.user?.email ?? 'Anonymous';
  String get userUid => _authService.user?.uid ?? 'FDRS-XXXX-X';

  String _buildNumber = 'Loading...';
  String get buildNumber => _buildNumber;

  String? _profileImageBase64;
  String? get profileImageBase64 => _profileImageBase64;

  ProfileViewModel() {
    _initData();
  }

  Future<void> _initData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final androidInfo = await _deviceInfo.androidInfo;
      _buildNumber = androidInfo.display;

      final uid = _authService.user?.uid;
      if (uid != null) {
        final profileData = await _databaseService.getUserProfile(uid);
        if (profileData != null) {
          nameController.text = profileData['name'] ?? '';

          String rawMobile = profileData['mobile'] ?? '';
          if (rawMobile.length == 10) {
            mobileController.text =
                '${rawMobile.substring(0, 5)}-${rawMobile.substring(5)}';
          } else {
            mobileController.text = rawMobile;
          }

          addressController.text = profileData['address'] ?? '';
          _profileImageBase64 = profileData['profileImage'];
        } else {
          nameController.text = _authService.user?.displayName ?? '';
        }
      }
    } catch (e) {
      debugPrint('[Profile] Error loading data: $e');
      _buildNumber = 'unknown';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveProfile(BuildContext context) async {
    final uid = _authService.user?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    String rawMobile = mobileController.text.replaceAll('-', '').trim();

    await _databaseService.updateUserProfile(uid, {
      'name': nameController.text.trim(),
      'mobile': rawMobile,
      'address': addressController.text.trim(),
      if (_profileImageBase64 != null) 'profileImage': _profileImageBase64,
    });

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 400,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        _profileImageBase64 = base64Encode(bytes);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[Profile] Error picking image: $e');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
