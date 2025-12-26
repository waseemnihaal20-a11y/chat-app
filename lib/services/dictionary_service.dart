import 'package:dio/dio.dart';

import '../config/global.dart';
import '../models/dictionary_model.dart';

/// Service for fetching word definitions from the Dictionary API.
class DictionaryService {
  late final Dio _dio;

  DictionaryService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: GlobalConfig.dictionaryBaseUrl,
        connectTimeout: GlobalConfig.apiTimeout,
        receiveTimeout: GlobalConfig.apiTimeout,
        sendTimeout: GlobalConfig.apiTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  /// Fetches the definition of a word from the Dictionary API.
  /// Returns a [DictionaryModel] on success.
  /// Throws [DictionaryError] if the word is not found.
  Future<DictionaryModel> getDefinition(String word) async {
    if (word.isEmpty) {
      throw DictionaryError(
        title: 'Invalid Word',
        message: 'Please provide a word to search for.',
      );
    }

    final cleanWord = _cleanWord(word);
    if (cleanWord.isEmpty) {
      throw DictionaryError(
        title: 'Invalid Word',
        message: 'The word contains no valid characters.',
      );
    }

    try {
      final response = await _dio.get(
        '${GlobalConfig.dictionaryEndpoint}/$cleanWord',
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List && data.isNotEmpty) {
          return DictionaryModel.fromJson(data.first);
        }
        throw DictionaryError(
          title: 'No Definitions Found',
          message: 'No definitions found for "$cleanWord".',
        );
      }

      throw DictionaryError(
        title: 'Error',
        message: 'Failed to fetch definition: ${response.statusCode}',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        final data = e.response?.data;
        if (data is Map<String, dynamic>) {
          throw DictionaryError.fromJson(data);
        }
        throw DictionaryError(
          title: 'No Definitions Found',
          message: 'Sorry, we couldn\'t find definitions for "$cleanWord".',
          resolution: 'You can try searching for a different word.',
        );
      }
      throw DictionaryError(
        title: 'Network Error',
        message: 'Failed to connect to the dictionary service.',
        resolution: 'Please check your internet connection and try again.',
      );
    } catch (e) {
      if (e is DictionaryError) rethrow;
      throw DictionaryError(
        title: 'Unexpected Error',
        message: 'An unexpected error occurred: $e',
      );
    }
  }

  /// Cleans a word by removing punctuation and extra whitespace
  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w\s-]'), '').trim().toLowerCase();
  }

  /// Disposes of the Dio client
  void dispose() {
    _dio.close();
  }
}
