import 'package:flutter/foundation.dart';
import 'package:plagit/config/env_config.dart';

/// Placeholder for WebSocket-based realtime features.
/// Will handle: live messaging, notification pushes, interview updates.
class RealtimeService {
  static final RealtimeService instance = RealtimeService._();
  RealtimeService._();

  bool _connected = false;
  bool get isConnected => _connected;

  /// Connect to WebSocket server.
  Future<void> connect({required String token}) async {
    if (EnvConfig.useMockData) {
      debugPrint('[Realtime] Mock mode — skipping WebSocket connection');
      return;
    }
    final url = '${EnvConfig.wsBaseUrl}/ws?token=$token';
    debugPrint('[Realtime] Connecting to $url');
    // TODO: Implement actual WebSocket connection
    // Use web_socket_channel package when ready
    _connected = true;
  }

  /// Disconnect from WebSocket.
  void disconnect() {
    _connected = false;
    debugPrint('[Realtime] Disconnected');
  }

  /// Subscribe to a channel (e.g., 'messages', 'notifications', 'interviews').
  void subscribe(
      String channel, void Function(Map<String, dynamic>) onMessage) {
    debugPrint('[Realtime] Subscribed to: $channel (mock — no-op)');
  }

  /// Unsubscribe from a channel.
  void unsubscribe(String channel) {
    debugPrint('[Realtime] Unsubscribed from: $channel');
  }
}
