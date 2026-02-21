import 'dart:async';

import 'package:flutter/foundation.dart';

import 'database_service.dart';
import 'offline_distress_queue.dart';
import 'service_locator.dart';

/// Outcome of the distress-signal delivery chain.
enum DistressDeliveryResult {
  /// Successfully written to Firebase RTDB.
  sentViaRtdb,

  /// RTDB timed out; sent via radio link (simulated).
  sentViaRadio,

  /// All real-time channels failed; signal cached locally and will
  /// auto-send when connectivity returns.
  queued,

  /// Everything failed (should be rare — queueing is the safety net).
  failed,
}

/// Orchestrates a three-tier delivery chain for distress signals:
///   1. Firebase RTDB (5 s timeout)
///   2. Radio link   (simulated — placeholder for LoRa/mesh SDK)
///   3. Offline queue (auto-retry on reconnect)
class DistressService {
  static const Duration _rtdbTimeout = Duration(seconds: 5);
  static const Duration _radioSimDelay = Duration(seconds: 1);

  /// Attempt to deliver a distress signal through the fallback chain.
  Future<DistressDeliveryResult> deliver({
    required String userId,
    required double latitude,
    required double longitude,
    required String buildNumber,
    required String timestamp,
  }) async {
    // ── Tier 1: RTDB ──────────────────────────────────────────────────
    try {
      final dbService = locator<DatabaseService>();
      final ok = await dbService
          .sendDistressSignal(
            userId: userId,
            latitude: latitude,
            longitude: longitude,
            buildNumber: buildNumber,
            timestamp: timestamp,
          )
          .timeout(_rtdbTimeout);

      if (ok) {
        debugPrint('[Distress] ✓ Sent via RTDB');
        return DistressDeliveryResult.sentViaRtdb;
      }
    } on TimeoutException {
      debugPrint('[Distress] RTDB timed out after ${_rtdbTimeout.inSeconds}s');
    } catch (e) {
      debugPrint('[Distress] RTDB error: $e');
    }

    // ── Tier 2: Radio link (simulated) ────────────────────────────────
    try {
      final radioOk = await _attemptRadioSend(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        buildNumber: buildNumber,
        timestamp: timestamp,
      );
      if (radioOk) {
        debugPrint('[Distress] ✓ Sent via Radio Link');
        return DistressDeliveryResult.sentViaRadio;
      }
    } catch (e) {
      debugPrint('[Distress] Radio error: $e');
    }

    // ── Tier 3: Offline queue ─────────────────────────────────────────
    try {
      final queue = locator<OfflineDistressQueue>();
      await queue.enqueue(
        userId: userId,
        latitude: latitude,
        longitude: longitude,
        buildNumber: buildNumber,
        timestamp: timestamp,
      );
      debugPrint('[Distress] ✓ Signal queued for later delivery');
      return DistressDeliveryResult.queued;
    } catch (e) {
      debugPrint('[Distress] Queue error: $e');
    }

    return DistressDeliveryResult.failed;
  }

  // ─── Radio simulation ──────────────────────────────────────────────

  /// Placeholder for a real radio/mesh SDK.
  /// Replace this body with actual hardware calls when available.
  Future<bool> _attemptRadioSend({
    required String userId,
    required double latitude,
    required double longitude,
    required String buildNumber,
    required String timestamp,
  }) async {
    debugPrint('[Radio] Attempting radio transmission…');
    await Future.delayed(_radioSimDelay);

    // Simulated: radio succeeds ~50% of the time in demo mode.
    // In production, replace with real hardware result.
    // For now, we'll return false so the cache tier gets exercised
    // in offline scenarios, making the demo more useful.
    debugPrint('[Radio] Radio link unavailable (simulated)');
    return false;
  }
}
