import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create a user with required fields', () {
      final user = UserModel(id: '1', fullName: 'John Doe');

      expect(user.id, '1');
      expect(user.fullName, 'John Doe');
      expect(user.username, null);
      expect(user.createdAt, isNotNull);
    });

    test('should create a user with all fields', () {
      final createdAt = DateTime(2024, 1, 15);
      final user = UserModel(
        id: '1',
        fullName: 'John Doe',
        username: 'johnd',
        createdAt: createdAt,
      );

      expect(user.id, '1');
      expect(user.fullName, 'John Doe');
      expect(user.username, 'johnd');
      expect(user.createdAt, createdAt);
    });

    group('fromJson', () {
      test('should parse JSON correctly', () {
        final json = {'id': 1, 'fullName': 'John Doe', 'username': 'johnd'};

        final user = UserModel.fromJson(json);

        expect(user.id, '1');
        expect(user.fullName, 'John Doe');
        expect(user.username, 'johnd');
      });

      test('should handle missing optional fields', () {
        final json = {'id': 1, 'fullName': 'John Doe'};

        final user = UserModel.fromJson(json);

        expect(user.id, '1');
        expect(user.fullName, 'John Doe');
        expect(user.username, null);
      });

      test('should handle full_name key format', () {
        final json = {'id': 1, 'full_name': 'John Doe'};

        final user = UserModel.fromJson(json);

        expect(user.fullName, 'John Doe');
      });
    });

    group('toJson', () {
      test('should convert to JSON correctly', () {
        final createdAt = DateTime(2024, 1, 15);
        final user = UserModel(
          id: '1',
          fullName: 'John Doe',
          username: 'johnd',
          createdAt: createdAt,
        );

        final json = user.toJson();

        expect(json['id'], '1');
        expect(json['fullName'], 'John Doe');
        expect(json['username'], 'johnd');
        expect(json['createdAt'], createdAt.toIso8601String());
      });
    });

    group('initial', () {
      test('should return uppercase first letter', () {
        final user = UserModel(id: '1', fullName: 'John Doe');
        expect(user.initial, 'J');
      });

      test('should return "?" for empty name', () {
        final user = UserModel(id: '1', fullName: '');
        expect(user.initial, '?');
      });

      test('should handle lowercase names', () {
        final user = UserModel(id: '1', fullName: 'alice');
        expect(user.initial, 'A');
      });
    });

    group('equality', () {
      test('should be equal if ids match', () {
        final user1 = UserModel(id: '1', fullName: 'John Doe');
        final user2 = UserModel(id: '1', fullName: 'Jane Doe');

        expect(user1, user2);
      });

      test('should not be equal if ids differ', () {
        final user1 = UserModel(id: '1', fullName: 'John Doe');
        final user2 = UserModel(id: '2', fullName: 'John Doe');

        expect(user1, isNot(user2));
      });
    });

    group('copyWith', () {
      test('should create copy with updated fields', () {
        final user = UserModel(id: '1', fullName: 'John Doe');
        final copy = user.copyWith(fullName: 'Jane Doe');

        expect(copy.id, '1');
        expect(copy.fullName, 'Jane Doe');
      });

      test('should preserve original fields when not specified', () {
        final user = UserModel(
          id: '1',
          fullName: 'John Doe',
          username: 'johnd',
        );
        final copy = user.copyWith(fullName: 'Jane Doe');

        expect(copy.username, 'johnd');
      });
    });
  });
}
