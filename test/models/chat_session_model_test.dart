import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/chat_session_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_model.dart';

void main() {
  group('ChatSessionModel', () {
    late UserModel testUser;

    setUp(() {
      testUser = UserModel(id: '1', fullName: 'Test User');
    });

    test('should create session with required fields', () {
      final session = ChatSessionModel(id: '1', user: testUser);

      expect(session.id, '1');
      expect(session.user, testUser);
      expect(session.messages, isEmpty);
      expect(session.lastActivity, isNotNull);
    });

    test('should create session with messages', () {
      final messages = [MessageModel.sender(id: '1', content: 'Hello')];
      final session = ChatSessionModel(
        id: '1',
        user: testUser,
        messages: messages,
      );

      expect(session.messages.length, 1);
    });

    group('lastMessage', () {
      test('should return null for empty messages', () {
        final session = ChatSessionModel(id: '1', user: testUser);

        expect(session.lastMessage, null);
      });

      test('should return last message', () {
        final messages = [
          MessageModel.sender(id: '1', content: 'First'),
          MessageModel.sender(id: '2', content: 'Second'),
        ];
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          messages: messages,
        );

        expect(session.lastMessage?.content, 'Second');
      });
    });

    group('lastMessagePreview', () {
      test('should return placeholder for empty messages', () {
        final session = ChatSessionModel(id: '1', user: testUser);

        expect(session.lastMessagePreview, 'No messages yet');
      });

      test('should return full message if short', () {
        final messages = [MessageModel.sender(id: '1', content: 'Hello')];
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          messages: messages,
        );

        expect(session.lastMessagePreview, 'Hello');
      });

      test('should truncate long messages', () {
        final longMessage = 'A' * 100;
        final messages = [MessageModel.sender(id: '1', content: longMessage)];
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          messages: messages,
        );

        expect(session.lastMessagePreview.length, 53); // 50 + '...'
        expect(session.lastMessagePreview.endsWith('...'), true);
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final session = ChatSessionModel(id: '1', user: testUser);
        final json = session.toJson();

        expect(json['id'], '1');
        expect(json['user'], isA<Map>());
        expect(json['messages'], isA<List>());
        expect(json['lastActivity'], isNotNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final session = ChatSessionModel(id: '1', user: testUser);
        final newUser = UserModel(id: '2', fullName: 'New User');
        final copy = session.copyWith(user: newUser);

        expect(copy.id, '1');
        expect(copy.user.id, '2');
      });

      test('should preserve original fields when not specified', () {
        final messages = [MessageModel.sender(id: '1', content: 'Hello')];
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          messages: messages,
        );
        final copy = session.copyWith(id: '2');

        expect(copy.messages.length, 1);
      });
    });

    group('addMessage', () {
      test('should add message and return new session', () {
        final session = ChatSessionModel(id: '1', user: testUser);
        final message = MessageModel.sender(id: '1', content: 'Hello');

        final newSession = session.addMessage(message);

        expect(newSession.messages.length, 1);
        expect(newSession.messages.first.content, 'Hello');
      });

      test('should preserve existing messages', () {
        final messages = [MessageModel.sender(id: '1', content: 'First')];
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          messages: messages,
        );
        final newMessage = MessageModel.sender(id: '2', content: 'Second');

        final newSession = session.addMessage(newMessage);

        expect(newSession.messages.length, 2);
        expect(newSession.messages[0].content, 'First');
        expect(newSession.messages[1].content, 'Second');
      });

      test('should update lastActivity', () {
        final oldTime = DateTime(2024, 1, 1);
        final session = ChatSessionModel(
          id: '1',
          user: testUser,
          lastActivity: oldTime,
        );
        final message = MessageModel.sender(id: '1', content: 'Hello');

        final newSession = session.addMessage(message);

        expect(newSession.lastActivity.isAfter(oldTime), true);
      });
    });
  });
}
