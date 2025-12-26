import 'message_model.dart';
import 'user_model.dart';

/// Represents a chat session with a user, including message history.
class ChatSessionModel {
  final String id;
  final UserModel user;
  final List<MessageModel> messages;
  final DateTime lastActivity;
  final bool isTyping;
  final bool isPinned;

  ChatSessionModel({
    required this.id,
    required this.user,
    List<MessageModel>? messages,
    DateTime? lastActivity,
    this.isTyping = false,
    this.isPinned = false,
  }) : messages = messages ?? [],
       lastActivity = lastActivity ?? DateTime.now();

  /// Gets the last message in the chat session
  MessageModel? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.last;
  }

  /// Gets the last message preview text (truncated)
  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    final msg = messages.last.content;
    if (msg.length <= 50) return msg;
    return '${msg.substring(0, 50)}...';
  }

  /// Gets the count of unread/unseen messages (receiver messages not seen)
  int get unreadCount {
    return messages
        .where((m) => m.type == MessageType.receiver && !m.isSeen)
        .length;
  }

  /// Whether this session has unread messages
  bool get hasUnread => unreadCount > 0;

  /// Converts the ChatSessionModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'messages': messages.map((m) => m.toJson()).toList(),
      'lastActivity': lastActivity.toIso8601String(),
      'isTyping': isTyping,
      'isPinned': isPinned,
    };
  }

  /// Creates a copy of the ChatSessionModel with optional new values
  ChatSessionModel copyWith({
    String? id,
    UserModel? user,
    List<MessageModel>? messages,
    DateTime? lastActivity,
    bool? isTyping,
    bool? isPinned,
  }) {
    return ChatSessionModel(
      id: id ?? this.id,
      user: user ?? this.user,
      messages: messages ?? List.from(this.messages),
      lastActivity: lastActivity ?? this.lastActivity,
      isTyping: isTyping ?? this.isTyping,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  /// Adds a message to the chat session and returns a new session
  ChatSessionModel addMessage(MessageModel message) {
    return copyWith(
      messages: [...messages, message],
      lastActivity: DateTime.now(),
    );
  }

  /// Updates a specific message in the session
  ChatSessionModel updateMessage(
    String messageId,
    MessageModel updatedMessage,
  ) {
    final updatedMessages = messages.map((m) {
      if (m.id == messageId) return updatedMessage;
      return m;
    }).toList();
    return copyWith(messages: updatedMessages);
  }

  /// Marks all receiver messages as seen
  ChatSessionModel markAllAsSeen() {
    final updatedMessages = messages.map((m) {
      if (m.type == MessageType.receiver && !m.isSeen) {
        return m.copyWith(isSeen: true);
      }
      return m;
    }).toList();
    return copyWith(messages: updatedMessages);
  }
}
