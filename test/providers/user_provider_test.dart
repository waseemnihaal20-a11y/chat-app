import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/providers/user_provider.dart';

void main() {
  group('UserProvider', () {
    late UserProvider provider;

    setUp(() {
      provider = UserProvider();
    });

    test('should initialize with default users', () {
      expect(provider.users, isNotEmpty);
      expect(provider.users.length, 5);
    });

    test('should not be loading initially', () {
      expect(provider.isLoading, false);
    });

    test('should have no error initially', () {
      expect(provider.error, null);
    });

    group('addUser', () {
      test('should add a new user to the list', () {
        final initialCount = provider.users.length;
        provider.addUser('New User');

        expect(provider.users.length, initialCount + 1);
        expect(provider.users.first.fullName, 'New User');
      });

      test('should set error for empty name', () {
        provider.addUser('');

        expect(provider.error, 'Name cannot be empty');
      });

      test('should set error for whitespace-only name', () {
        provider.addUser('   ');

        expect(provider.error, 'Name cannot be empty');
      });

      test('should trim whitespace from name', () {
        provider.addUser('  John Doe  ');

        expect(provider.users.first.fullName, 'John Doe');
      });

      test('should generate username from name', () {
        provider.addUser('John Doe');

        expect(provider.users.first.username, 'john_doe');
      });
    });

    group('removeUser', () {
      test('should remove user by id', () {
        final userId = provider.users.first.id;
        final initialCount = provider.users.length;

        provider.removeUser(userId);

        expect(provider.users.length, initialCount - 1);
        expect(provider.getUserById(userId), null);
      });

      test('should do nothing for non-existent id', () {
        final initialCount = provider.users.length;

        provider.removeUser('non-existent-id');

        expect(provider.users.length, initialCount);
      });
    });

    group('updateUser', () {
      test('should update user full name', () {
        final userId = provider.users.first.id;

        provider.updateUser(userId, fullName: 'Updated Name');

        expect(provider.getUserById(userId)?.fullName, 'Updated Name');
      });

      test('should update user username', () {
        final userId = provider.users.first.id;

        provider.updateUser(userId, username: 'newusername');

        expect(provider.getUserById(userId)?.username, 'newusername');
      });

      test('should do nothing for non-existent id', () {
        final firstUser = provider.users.first;

        provider.updateUser('non-existent-id', fullName: 'Test');

        expect(provider.users.first.fullName, firstUser.fullName);
      });
    });

    group('getUserById', () {
      test('should return user when exists', () {
        final expectedUser = provider.users.first;

        final result = provider.getUserById(expectedUser.id);

        expect(result, expectedUser);
      });

      test('should return null when user does not exist', () {
        final result = provider.getUserById('non-existent-id');

        expect(result, null);
      });
    });

    group('clearError', () {
      test('should clear error message', () {
        provider.addUser('');
        expect(provider.error, isNotNull);

        provider.clearError();

        expect(provider.error, null);
      });
    });

    group('setLoading', () {
      test('should set loading state', () {
        provider.setLoading(true);
        expect(provider.isLoading, true);

        provider.setLoading(false);
        expect(provider.isLoading, false);
      });
    });
  });
}
