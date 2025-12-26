import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/config/global.dart';

void main() {
  group('GlobalConfig', () {
    test('should have correct API timeout', () {
      expect(GlobalConfig.apiTimeout, const Duration(seconds: 30));
    });

    test('should have correct base URL', () {
      expect(GlobalConfig.baseUrl, 'https://dummyjson.com');
    });

    test('should have correct dictionary base URL', () {
      expect(
        GlobalConfig.dictionaryBaseUrl,
        'https://api.dictionaryapi.dev/api/v2',
      );
    });

    test('should have correct comments endpoint', () {
      expect(GlobalConfig.commentsEndpoint, '/comments');
    });

    test('should have correct dictionary endpoint', () {
      expect(GlobalConfig.dictionaryEndpoint, '/entries/en');
    });
  });
}
