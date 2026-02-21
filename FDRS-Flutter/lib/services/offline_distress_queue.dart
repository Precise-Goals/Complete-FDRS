import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'database_service.dart';
import 'service_locator.dart';

/// Persists distress signals to disk when offline and auto-flushes
/// them to RTDB once connectivity is restored.
class OfflineDistressQueue {
  static const String _fileName = 'pending_distress_signals.json';

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  // ─── Persistence helpers ───────────────────────────────────────────

  Future<File> _getQueueFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<Map<String, dynamic>>> _readQueue() async {
    try {
      final file = await _getQueueFile();
      if (!await file.exists()) return [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[OfflineQueue] read error: $e');
      return [];
    }
  }

  Future<void> _writeQueue(List<Map<String, dynamic>> queue) async {
    final file = await _getQueueFile();
    await file.writeAsString(jsonEncode(queue));
  }

  // ─── Public API ────────────────────────────────────────────────────

  /// Append a signal to the local queue.
  Future<void> enqueue({
    required String userId,
    required double latitude,
    required double longitude,
    required String buildNumber,
    required String timestamp,
  }) async {
    final queue = await _readQueue();
    queue.add({
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'buildNumber': buildNumber,
      'timestamp': timestamp,
    });
    await _writeQueue(queue);
    debugPrint('[OfflineQueue] Signal queued (${queue.length} pending)');
  }

  /// Try to push all queued signals to RTDB.
  /// Successfully sent signals are removed from the queue.
  Future<void> flush() async {
    final queue = await _readQueue();
    if (queue.isEmpty) return;

    debugPrint('[OfflineQueue] Flushing ${queue.length} pending signal(s)…');

    final dbService = locator<DatabaseService>();
    final remaining = <Map<String, dynamic>>[];

    for (final signal in queue) {
      try {
        final ok = await dbService.sendDistressSignal(
          userId: signal['userId'] as String,
          latitude: (signal['latitude'] as num).toDouble(),
          longitude: (signal['longitude'] as num).toDouble(),
          buildNumber: signal['buildNumber'] as String,
          timestamp: signal['timestamp'] as String,
        );
        if (!ok) remaining.add(signal);
      } catch (_) {
        remaining.add(signal);
      }
    }

    await _writeQueue(remaining);
    debugPrint(
        '[OfflineQueue] Flush done — ${queue.length - remaining.length} sent, '
        '${remaining.length} still pending');
  }

  /// Begin listening for connectivity changes. When connectivity is
  /// restored, automatically [flush] the queue.
  void startAutoFlush() {
    _connectivitySub?.cancel();
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((results) async {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        debugPrint('[OfflineQueue] Connectivity restored — flushing…');
        await flush();
      }
    });
    debugPrint('[OfflineQueue] Auto-flush listener started');
  }

  /// Stop listening for connectivity changes.
  void dispose() {
    _connectivitySub?.cancel();
  }
}
