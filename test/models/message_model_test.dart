import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/message_model.dart';

void main() {
  group('MessageModel', () {
    test('should create a message with required fields', () {
      final message = MessageModel(
        id: '1',
        content: 'Hello',
        type: MessageType.sender,
      );

      expect(message.id, '1');
      expect(message.content, 'Hello');
      expect(message.type, MessageType.sender);
      expect(message.timestamp, isNotNull);
      expect(message.status, MessageStatus.delivered);
    });

    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {'id': 1, 'body': 'This is a comment'};

        final message = MessageModel.fromJson(json);

        expect(message.id, '1');
        expect(message.content, 'This is a comment');
        expect(message.type, MessageType.receiver);
      });

      test('should handle missing fields gracefully', () {
        final json = <String, dynamic>{};

        final message = MessageModel.fromJson(json);

        expect(message.id, '');
        expect(message.content, '');
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final timestamp = DateTime(2024, 1, 15, 10, 30);
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
          timestamp: timestamp,
          status: MessageStatus.delivered,
        );

        final json = message.toJson();

        expect(json['id'], '1');
        expect(json['content'], 'Hello');
        expect(json['type'], 'sender');
        expect(json['timestamp'], timestamp.toIso8601String());
        expect(json['status'], 'delivered');
      });
    });

    group('factory constructors', () {
      test('sender should create sender message with sending status', () {
        final message = MessageModel.sender(id: '1', content: 'Hello');

        expect(message.type, MessageType.sender);
        expect(message.content, 'Hello');
        expect(message.status, MessageStatus.sending);
      });

      test('receiver should create receiver message', () {
        final message = MessageModel.receiver(id: '1', content: 'Hi there');

        expect(message.type, MessageType.receiver);
        expect(message.content, 'Hi there');
        expect(message.status, MessageStatus.delivered);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
        );
        final copy = message.copyWith(content: 'Updated');

        expect(copy.id, '1');
        expect(copy.content, 'Updated');
        expect(copy.type, MessageType.sender);
      });

      test('should preserve original fields when not specified', () {
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
          status: MessageStatus.failed,
        );
        final copy = message.copyWith(content: 'Updated');

        expect(copy.status, MessageStatus.failed);
      });
    });

    group('status helpers', () {
      test('isDelivered should return true for delivered status', () {
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
          status: MessageStatus.delivered,
        );
        expect(message.isDelivered, true);
      });

      test('hasFailed should return true for failed status', () {
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
          status: MessageStatus.failed,
        );
        expect(message.hasFailed, true);
      });

      test('isSending should return true for sending status', () {
        final message = MessageModel(
          id: '1',
          content: 'Hello',
          type: MessageType.sender,
          status: MessageStatus.sending,
        );
        expect(message.isSending, true);
      });
    });
  });

  group('MessageType', () {
    test('should have sender and receiver values', () {
      expect(MessageType.values, contains(MessageType.sender));
      expect(MessageType.values, contains(MessageType.receiver));
    });
  });

  group('MessageStatus', () {
    test('should have all status values', () {
      expect(MessageStatus.values, contains(MessageStatus.sending));
      expect(MessageStatus.values, contains(MessageStatus.sent));
      expect(MessageStatus.values, contains(MessageStatus.delivered));
      expect(MessageStatus.values, contains(MessageStatus.failed));
    });
  });
}
