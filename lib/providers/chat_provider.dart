import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/chat_session_model.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';

/// Provider for managing chat sessions and messages.
/// Handles message sending, receiving, and chat history.
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  final ConnectivityService _connectivityService;
  final Map<String, ChatSessionModel> _chatSessions = {};
  bool _isLoading = false;
  bool _isSendingMessage = false;
  String? _error;
  Timer? _autoReplyTimer;
  Timer? _typingTimer;

  ChatProvider({
    ApiService? apiService,
    ConnectivityService? connectivityService,
  }) : _apiService = apiService ?? ApiService(),
       _connectivityService = connectivityService ?? ConnectivityService();

  /// Gets all chat sessions sorted by: pinned (alphabetically) first, then unread, then by last activity
  List<ChatSessionModel> get chatSessions {
    final sessions = _chatSessions.values.toList();
    sessions.sort((a, b) {
      // First sort by pinned status
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      // If both are pinned, sort alphabetically by user name
      if (a.isPinned && b.isPinned) {
        return a.user.fullName.toLowerCase().compareTo(
          b.user.fullName.toLowerCase(),
        );
      }
      // Then sort by unread status
      if (a.hasUnread && !b.hasUnread) return -1;
      if (!a.hasUnread && b.hasUnread) return 1;
      // Then by last activity
      return b.lastActivity.compareTo(a.lastActivity);
    });
    return sessions;
  }

  /// Gets the loading state
  bool get isLoading => _isLoading;

  /// Gets the sending message state
  bool get isSendingMessage => _isSendingMessage;

  /// Gets any error message
  String? get error => _error;

  /// Gets a chat session by user ID
  ChatSessionModel? getChatSession(String visibleSessionId) {
    return _chatSessions[visibleSessionId];
  }

  /// Gets messages for a specific user
  List<MessageModel> getMessages(String visibleSessionId) {
    return _chatSessions[visibleSessionId]?.messages ?? [];
  }

  /// Creates or gets an existing chat session for a user
  ChatSessionModel getOrCreateSession(UserModel user) {
    if (!_chatSessions.containsKey(user.id)) {
      _chatSessions[user.id] = ChatSessionModel(id: user.id, user: user);
      notifyListeners();
    }
    return _chatSessions[user.id]!;
  }

  /// Sends a message from the user (sender)
  Future<void> sendMessage(String userId, String content) async {
    if (content.trim().isEmpty) return;

    _isSendingMessage = true;
    _error = null;
    notifyListeners();

    final session = _chatSessions[userId];
    if (session == null) {
      _error = 'Chat session not found';
      _isSendingMessage = false;
      notifyListeners();
      return;
    }

    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final senderMessage = MessageModel.sender(
      id: messageId,
      content: content.trim(),
      status: MessageStatus.sending,
    );

    _chatSessions[userId] = session.addMessage(senderMessage);
    _isSendingMessage = false;
    notifyListeners();

    // Check connectivity and update message status
    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      // Update to delivered status
      _updateMessageStatus(userId, messageId, MessageStatus.delivered);
      _scheduleAutoReply(userId, messageId);
    } else {
      // Mark as failed if no internet
      _updateMessageStatus(userId, messageId, MessageStatus.failed);
    }
  }

  /// Updates the status of a specific message
  void _updateMessageStatus(
    String userId,
    String messageId,
    MessageStatus status,
  ) {
    final session = _chatSessions[userId];
    if (session == null) return;

    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    final updatedMessage = session.messages[messageIndex].copyWith(
      status: status,
    );
    _chatSessions[userId] = session.updateMessage(messageId, updatedMessage);
    notifyListeners();
  }

  /// Retries sending a failed message
  Future<void> retryMessage(String userId, String messageId) async {
    final session = _chatSessions[userId];
    if (session == null) return;

    final messageIndex = session.messages.indexWhere((m) => m.id == messageId);
    if (messageIndex == -1) return;

    _updateMessageStatus(userId, messageId, MessageStatus.sending);

    final isConnected = await _connectivityService.checkConnectivity();
    if (isConnected) {
      _updateMessageStatus(userId, messageId, MessageStatus.delivered);
      _scheduleAutoReply(userId, messageId);
    } else {
      _updateMessageStatus(userId, messageId, MessageStatus.failed);
    }
  }

  /// Schedules an auto-reply from the receiver after a delay
  void _scheduleAutoReply(
    String visibleSessionId,
    String triggeredByMessageId,
  ) {
    _autoReplyTimer?.cancel();

    // Show typing indicator after a brief delay
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 500), () {
      _setTypingIndicator(visibleSessionId, true);
    });

    // Fetch message but show it after typing delay
    _autoReplyTimer = Timer(const Duration(seconds: 1), () async {
      await _fetchAndAddReceiverMessage(visibleSessionId);
    });
  }

  /// Sets the typing indicator for a session
  void _setTypingIndicator(String sessionId, bool isTyping) {
    final session = _chatSessions[sessionId];
    if (session != null) {
      _chatSessions[sessionId] = session.copyWith(isTyping: isTyping);
      notifyListeners();
    }
  }

  /// Fetches a random comment from the API and adds it as a receiver message
  Future<void> _fetchAndAddReceiverMessage(String visibleSessionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final randomMessage = await _apiService.fetchRandomComment();

      // Keep typing indicator for 2 more seconds to simulate typing
      await Future.delayed(const Duration(seconds: 2));

      _setTypingIndicator(visibleSessionId, false);

      if (randomMessage != null) {
        final session = _chatSessions[visibleSessionId];
        if (session != null) {
          final receiverMessage = MessageModel.receiver(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            content: randomMessage.content,
            isSeen: false,
          );
          _chatSessions[visibleSessionId] = session.addMessage(receiverMessage);
        }
      }
    } catch (e) {
      _setTypingIndicator(visibleSessionId, false);
      _error = 'Failed to receive message: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marks all messages in a session as seen
  void markSessionAsSeen(String userId) {
    final session = _chatSessions[userId];
    if (session != null && session.hasUnread) {
      _chatSessions[userId] = session.markAllAsSeen();
      notifyListeners();
    }
  }

  /// Gets the count of users with unread messages (not total unread messages)
  int get unreadChatsCount {
    return _chatSessions.values.where((session) => session.hasUnread).length;
  }

  /// Force refresh to update timestamps in chat history
  void refreshChatHistory() {
    notifyListeners();
  }

  /// Clears any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Pins or unpins a chat session
  void togglePinChat(String userId) {
    final session = _chatSessions[userId];
    if (session != null) {
      _chatSessions[userId] = session.copyWith(isPinned: !session.isPinned);
      notifyListeners();
    }
  }

  /// Checks if a chat is pinned
  bool isChatPinned(String userId) {
    return _chatSessions[userId]?.isPinned ?? false;
  }

  /// Deletes a chat session
  void deleteChat(String userId) {
    _chatSessions.remove(userId);
    notifyListeners();
  }

  /// Clears a specific chat session (alias for deleteChat)
  void clearChatSession(String userId) {
    deleteChat(userId);
  }

  /// Clears all chat sessions
  void clearAllSessions() {
    _chatSessions.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _autoReplyTimer?.cancel();
    _typingTimer?.cancel();
    _apiService.dispose();
    super.dispose();
  }
}
