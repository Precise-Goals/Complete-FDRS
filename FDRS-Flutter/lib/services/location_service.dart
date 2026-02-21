import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

import 'distress_service.dart';
import 'service_locator.dart';

/// Result of an SOS attempt.
enum SosResult {
  success,
  sentViaRadio,
  queued,
  permissionDenied,
  locationDisabled,
  error,
}

class LocationService {
  final Location _location = Location();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Requests location permission at runtime.
  /// Returns true if permission is granted.
  Future<bool> requestPermissions() async {
    final status = await permission_handler.Permission.location.request();
    return status.isGranted;
  }

  /// Sends an SOS distress signal via the three-tier fallback chain:
  ///   1. Firebase RTDB (5 s timeout)
  ///   2. Radio link   (simulated placeholder)
  ///   3. Offline cache (auto-retry on reconnect)
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

      // Step 6: Deliver via fallback chain
      final distressService = locator<DistressService>();
      final result = await distressService.deliver(
        userId: userId ?? 'anonymous',
        latitude: latitude,
        longitude: longitude,
        buildNumber: buildNumber,
        timestamp: timestamp,
      );

      // Map delivery result to SosResult
      switch (result) {
        case DistressDeliveryResult.sentViaRtdb:
          return SosResult.success;
        case DistressDeliveryResult.sentViaRadio:
          return SosResult.sentViaRadio;
        case DistressDeliveryResult.queued:
          return SosResult.queued;
        case DistressDeliveryResult.failed:
          return SosResult.error;
      }
    } catch (e) {
      debugPrint('[SOS] Unexpected error: $e');
      return SosResult.error;
    }
  }
}
