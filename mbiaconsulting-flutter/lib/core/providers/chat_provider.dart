import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import '../../models/conversation_model.dart';
import '../../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final SocketService _socket;
  final String? Function() _getToken;

  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];
  String? _activeConversationId;
  bool _loadingConversations = false;
  bool _loadingMessages = false;
  String? _error;

  ChatProvider({
    required SocketService socketService,
    required String? Function() getToken,
  })  : _socket = socketService,
        _getToken = getToken;

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;
  String? get activeConversationId => _activeConversationId;
  bool get loadingConversations => _loadingConversations;
  bool get loadingMessages => _loadingMessages;
  String? get error => _error;

  ApiService get _api => ApiService(token: _getToken());

  // ── Conversations ──────────────────────────────────────────────────────────

  Future<void> loadConversations() async {
    _loadingConversations = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.get('/chat/conversations') as List<dynamic>;
      _conversations = data
          .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loadingConversations = false;
      notifyListeners();
    }
  }

  Future<ConversationModel?> getOrCreateConversation({
    String? subject,
    String? consultationId,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (subject != null) body['subject'] = subject;
      if (consultationId != null) body['consultationId'] = consultationId;
      final data = await _api.post('/chat/conversations', body)
          as Map<String, dynamic>;
      final conv = ConversationModel.fromJson(data);
      // Upsert in local list
      final idx = _conversations.indexWhere((c) => c.id == conv.id);
      if (idx >= 0) {
        _conversations[idx] = conv;
      } else {
        _conversations.insert(0, conv);
      }
      notifyListeners();
      return conv;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // ── Real-time chat ─────────────────────────────────────────────────────────

  void joinConversation(String conversationId) {
    if (_activeConversationId == conversationId) return;

    // Leave previous conversation if any
    if (_activeConversationId != null) {
      _socket.leaveConversation(_activeConversationId!);
      _removeSocketListeners();
    }

    _activeConversationId = conversationId;
    _messages = [];
    _loadingMessages = true;
    notifyListeners();

    _socket.joinConversation(conversationId);
    _attachSocketListeners();
  }

  void leaveCurrentConversation() {
    if (_activeConversationId == null) return;
    _socket.leaveConversation(_activeConversationId!);
    _removeSocketListeners();
    _activeConversationId = null;
    _messages = [];
    notifyListeners();
  }

  void sendMessage(String text) {
    if (_activeConversationId == null || text.trim().isEmpty) return;
    _socket.sendMessage(_activeConversationId!, text.trim());
  }

  // ── Socket listeners ───────────────────────────────────────────────────────

  void _attachSocketListeners() {
    _socket.on('message_history', (raw) {
      final list = raw as List<dynamic>;
      _messages = list
          .map((e) => MessageModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _loadingMessages = false;
      notifyListeners();
    });

    _socket.on('new_message', (raw) {
      final msg = MessageModel.fromJson(raw as Map<String, dynamic>);
      if (!_messages.any((m) => m.id == msg.id)) {
        _messages = [..._messages, msg];
        _updateConversationLastMessage(msg.conversationId, msg.text);
        notifyListeners();
      }
    });

    _socket.on('messages_read', (_) {
      notifyListeners();
    });
  }

  void _removeSocketListeners() {
    _socket.off('message_history');
    _socket.off('new_message');
    _socket.off('messages_read');
  }

  void _updateConversationLastMessage(String convId, String text) {
    final idx = _conversations.indexWhere((c) => c.id == convId);
    if (idx < 0) return;
    // Replace with updated object (ConversationModel is immutable)
    final old = _conversations[idx];
    _conversations = List.from(_conversations)
      ..[idx] = ConversationModel(
        id: old.id,
        userId: old.userId,
        subject: old.subject,
        lastMessage: text,
        unreadCount: old.unreadCount,
        isActive: old.isActive,
        updatedAt: DateTime.now(),
        userName: old.userName,
        userEmail: old.userEmail,
      );
  }

  @override
  void dispose() {
    _removeSocketListeners();
    super.dispose();
  }
}
