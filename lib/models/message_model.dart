/// Enum representing the type of message sender
enum MessageType { sender, receiver }

/// Enum representing the delivery status of a message
enum MessageStatus {
  sending, // Message is being sent
  sent, // Message sent successfully (single tick)
  delivered, // Message delivered (double tick)
  failed, // Message failed to send
}

/// Represents a chat message in the application.
class MessageModel {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final bool isSeen;

  MessageModel({
    required this.id,
    required this.content,
    required this.type,
    DateTime? timestamp,
    this.status = MessageStatus.delivered,
    this.isSeen = false,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Creates a MessageModel from JSON response (DummyJSON comments format)
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id']?.toString() ?? '',
      content: json['body'] ?? '',
      type: MessageType.receiver,
      status: MessageStatus.delivered,
    );
  }

  /// Converts the MessageModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'isSeen': isSeen,
    };
  }

  /// Creates a sender message (local message) - initially in sending state
  factory MessageModel.sender({
    required String id,
    required String content,
    MessageStatus status = MessageStatus.sending,
  }) {
    return MessageModel(
      id: id,
      content: content,
      type: MessageType.sender,
      status: status,
    );
  }

  /// Creates a receiver message from API response
  factory MessageModel.receiver({
    required String id,
    required String content,
    bool isSeen = false,
  }) {
    return MessageModel(
      id: id,
      content: content,
      type: MessageType.receiver,
      status: MessageStatus.delivered,
      isSeen: isSeen,
    );
  }

  /// Whether the message has been delivered successfully
  bool get isDelivered => status == MessageStatus.delivered;

  /// Whether the message failed to send
  bool get hasFailed => status == MessageStatus.failed;

  /// Whether the message is still sending
  bool get isSending => status == MessageStatus.sending;

  /// Creates a copy of the MessageModel with optional new values
  MessageModel copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    MessageStatus? status,
    bool? isSeen,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      isSeen: isSeen ?? this.isSeen,
    );
  }
}
