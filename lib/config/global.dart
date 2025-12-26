/// Global configuration for the chat application.
/// Contains API endpoints, timeouts, and other app-wide settings.
class GlobalConfig {
  GlobalConfig._();

  /// API request timeout duration
  static const Duration apiTimeout = Duration(seconds: 30);

  /// Base URL for the comments/messages API
  static const String baseUrl = 'https://dummyjson.com';

  /// Base URL for the Dictionary API
  static const String dictionaryBaseUrl =
      'https://api.dictionaryapi.dev/api/v2';

  /// Comments endpoint path
  static const String commentsEndpoint = '/comments';

  /// Dictionary entries endpoint path
  static const String dictionaryEndpoint = '/entries/en';
}
