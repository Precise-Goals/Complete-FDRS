import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'database_service.dart';
import 'service_locator.dart';

/// Result of an SOS attempt.
enum SosResult { success, permissionDenied, locationDisabled, error }

class LocationService {
  final Location _location = Location();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Requests location permission at runtime.
  /// Returns true if permission is granted.
  Future<bool> requestPermissions() async {
    final status = await permission_handler.Permission.location.request();
    return status.isGranted;
  }

  /// Sends an SOS distress signal.
  /// 1. Requests location permission
  /// 2. Enables location service if disabled
  /// 3. Reads exact lat/long from GPS
  /// 4. Reads device build number
  /// 5. Generates exact UTC ISO-8601 timestamp
  /// 6. Pushes everything to RTDB /signals
  Future<SosResult> sendSOS(String? userId) async {
    try {
      // Step 1: Request permission
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        debugPrint('[SOS] Location permission denied');
        return SosResult.permissionDenied;
      }

      // Step 2: Ensure location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          debugPrint('[SOS] Location service disabled');
          return SosResult.locationDisabled;
        }
      }

      // Step 3: Get exact location
      final locationData = await _location.getLocation();
      final double latitude = locationData.latitude ?? 0.0;
      final double longitude = locationData.longitude ?? 0.0;

      // Step 4: Get device build number
      String buildNumber = 'unknown';
      try {
        final androidInfo = await _deviceInfo.androidInfo;
        buildNumber = androidInfo.display;
      } catch (e) {
        debugPrint('[SOS] Could not get device info: $e');
      }

      // Step 5: Exact UTC timestamp
      final String timestamp = DateTime.now().toUtc().toIso8601String();

      // Step 6: Push to RTDB /signals
      final dbService = locator<DatabaseService>();
      final success = await dbService.sendDistressSignal(
        userId: userId ?? 'anonymous',
        latitude: latitude,
        longitude: longitude,
        buildNumber: buildNumber,
        timestamp: timestamp,
      );

      return success ? SosResult.success : SosResult.error;
    } catch (e) {
      debugPrint('[SOS] Unexpected error: $e');
      return SosResult.error;
    }
  }
}
