import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';

class SocketService {
  io.Socket? _socket;

  bool get isConnected => _socket?.connected ?? false;

  void connect(String token) {
    if (isConnected) return;

    _socket = io.io(
      '${AppConstants.socketUrl}/chat',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .build(),
    );

    _socket!.onConnect((_) => debugPrint('[Socket] Connected'));
    _socket!.onDisconnect((_) => debugPrint('[Socket] Disconnected'));
    _socket!.on('error', (e) => debugPrint('[Socket] Error: $e'));

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  // ── Conversation rooms ────────────────────────────────────────────────────

  void joinConversation(String conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  void leaveConversation(String conversationId) {
    _socket?.emit('leave_conversation', conversationId);
  }

  void sendMessage(String conversationId, String text) {
    _socket?.emit('send_message', {
      'conversationId': conversationId,
      'text': text,
    });
  }

  void markRead(String conversationId) {
    _socket?.emit('mark_read', conversationId);
  }

  // ── Event subscriptions ───────────────────────────────────────────────────

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }
}
