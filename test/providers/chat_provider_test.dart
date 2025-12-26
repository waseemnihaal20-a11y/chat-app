import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/providers/chat_provider.dart';

void main() {
  group('ChatProvider', () {
    late ChatProvider provider;
    late UserModel testUser;

    setUp(() {
      provider = ChatProvider();
      testUser = UserModel(id: 'test-user-1', fullName: 'Test User');
    });

    tearDown(() {
      provider.dispose();
    });

    test('should start with no chat sessions', () {
      expect(provider.chatSessions, isEmpty);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, false);
    });

    test('should not be sending message initially', () {
      expect(provider.isSendingMessage, false);
    });

    test('should have no error initially', () {
      expect(provider.error, null);
    });

    group('getOrCreateSession', () {
      test('should create new session for new user', () {
        final session = provider.getOrCreateSession(testUser);

        expect(session.user, testUser);
        expect(session.messages, isEmpty);
        expect(provider.chatSessions.length, 1);
      });

      test('should return existing session for known user', () {
        final session1 = provider.getOrCreateSession(testUser);
        final session2 = provider.getOrCreateSession(testUser);

        expect(session1.id, session2.id);
        expect(provider.chatSessions.length, 1);
      });
    });

    group('getChatSession', () {
      test('should return session when exists', () {
        provider.getOrCreateSession(testUser);

        final session = provider.getChatSession(testUser.id);

        expect(session, isNotNull);
        expect(session?.user.id, testUser.id);
      });

      test('should return null when session does not exist', () {
        final session = provider.getChatSession('non-existent');

        expect(session, null);
      });
    });

    group('getMessages', () {
      test('should return empty list for non-existent session', () {
        final messages = provider.getMessages('non-existent');

        expect(messages, isEmpty);
      });

      test('should return messages for existing session', () {
        provider.getOrCreateSession(testUser);

        final messages = provider.getMessages(testUser.id);

        expect(messages, isA<List>());
      });
    });

    group('sendMessage', () {
      test('should add sender message to session', () async {
        provider.getOrCreateSession(testUser);

        await provider.sendMessage(testUser.id, 'Hello');

        final messages = provider.getMessages(testUser.id);
        expect(messages.length, 1);
        expect(messages.first.content, 'Hello');
      });

      test('should not add empty message', () async {
        provider.getOrCreateSession(testUser);

        await provider.sendMessage(testUser.id, '');

        final messages = provider.getMessages(testUser.id);
        expect(messages, isEmpty);
      });

      test('should not add whitespace-only message', () async {
        provider.getOrCreateSession(testUser);

        await provider.sendMessage(testUser.id, '   ');

        final messages = provider.getMessages(testUser.id);
        expect(messages, isEmpty);
      });

      test('should set error for non-existent session', () async {
        await provider.sendMessage('non-existent', 'Hello');

        expect(provider.error, 'Chat session not found');
      });

      test('should trim message content', () async {
        provider.getOrCreateSession(testUser);

        await provider.sendMessage(testUser.id, '  Hello World  ');

        final messages = provider.getMessages(testUser.id);
        expect(messages.first.content, 'Hello World');
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        await provider.sendMessage('non-existent', 'Hello');
        expect(provider.error, isNotNull);

        provider.clearError();

        expect(provider.error, null);
      });
    });

    group('clearChatSession', () {
      test('should remove specific session', () {
        provider.getOrCreateSession(testUser);
        expect(provider.chatSessions.length, 1);

        provider.clearChatSession(testUser.id);

        expect(provider.chatSessions, isEmpty);
      });
    });

    group('clearAllSessions', () {
      test('should remove all sessions', () {
        provider.getOrCreateSession(testUser);
        provider.getOrCreateSession(
          UserModel(id: 'user-2', fullName: 'User 2'),
        );
        expect(provider.chatSessions.length, 2);

        provider.clearAllSessions();

        expect(provider.chatSessions, isEmpty);
      });
    });

    group('chatSessions sorting', () {
      test('should return sessions sorted by last activity', () async {
        final user1 = UserModel(id: 'user-1', fullName: 'User 1');
        final user2 = UserModel(id: 'user-2', fullName: 'User 2');

        provider.getOrCreateSession(user1);
        await Future.delayed(const Duration(milliseconds: 10));
        provider.getOrCreateSession(user2);

        final sessions = provider.chatSessions;

        // user2 should be first (more recent)
        expect(sessions.first.user.id, 'user-2');
      });
    });
  });
}
