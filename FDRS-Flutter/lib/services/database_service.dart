import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  /// Saves user data under /users/{uid} in RTDB.
  Future<void> saveUserData({
    required String uid,
    String? email,
    required String lastLogin,
  }) async {
    try {
      await _db.child('users').child(uid).update({
        'uid': uid,
        'email': email ?? 'anonymous',
        'lastLogin': lastLogin,
      });
      debugPrint('[RTDB] User data saved for $uid');
    } catch (e) {
      debugPrint('[RTDB] Failed to save user data: $e');
    }
  }

  /// Gets user profile data from /users/{uid}
  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final snapshot = await _db.child('users').child(uid).get();
      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    } catch (e) {
      debugPrint('[RTDB] Failed to get user profile: $e');
    }
    return null;
  }

  /// Updates user profile data at /users/{uid}
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.child('users').child(uid).update(data);
      debugPrint('[RTDB] User profile updated for $uid');
    } catch (e) {
      debugPrint('[RTDB] Failed to update user profile: $e');
    }
  }

  /// Pushes a distress signal under /signals in RTDB.
  Future<bool> sendDistressSignal({
    required String userId,
    required double latitude,
    required double longitude,
    required String buildNumber,
    required String timestamp,
  }) async {
    try {
      final sanitizedBuild = buildNumber.replaceAll(RegExp(r'[.#$\[\]]'), '_');
      final signalId = '${userId}_$sanitizedBuild';
      await _db.child('signals').child(signalId).set({
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'buildNumber': buildNumber,
        'timestamp': timestamp,
      });
      debugPrint('[RTDB] Distress signal sent for $userId');
      return true;
    } catch (e) {
      debugPrint('[RTDB] Failed to send distress signal: $e');
      return false;
    }
  }
}
