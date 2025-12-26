import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/models/dictionary_model.dart';

void main() {
  group('DefinitionModel', () {
    test('should parse JSON correctly', () {
      final json = {
        'definition': 'A greeting',
        'example': 'Hello, how are you?',
        'synonyms': ['hi', 'hey'],
        'antonyms': ['goodbye'],
      };

      final definition = DefinitionModel.fromJson(json);

      expect(definition.definition, 'A greeting');
      expect(definition.example, 'Hello, how are you?');
      expect(definition.synonyms, ['hi', 'hey']);
      expect(definition.antonyms, ['goodbye']);
    });

    test('should handle missing optional fields', () {
      final json = {'definition': 'A greeting'};

      final definition = DefinitionModel.fromJson(json);

      expect(definition.definition, 'A greeting');
      expect(definition.example, null);
      expect(definition.synonyms, isEmpty);
      expect(definition.antonyms, isEmpty);
    });
  });

  group('MeaningModel', () {
    test('should parse JSON correctly', () {
      final json = {
        'partOfSpeech': 'noun',
        'definitions': [
          {'definition': 'A greeting'},
        ],
        'synonyms': ['hi'],
        'antonyms': ['bye'],
      };

      final meaning = MeaningModel.fromJson(json);

      expect(meaning.partOfSpeech, 'noun');
      expect(meaning.definitions.length, 1);
      expect(meaning.synonyms, ['hi']);
      expect(meaning.antonyms, ['bye']);
    });

    test('should handle empty definitions', () {
      final json = {'partOfSpeech': 'noun'};

      final meaning = MeaningModel.fromJson(json);

      expect(meaning.definitions, isEmpty);
    });
  });

  group('PhoneticModel', () {
    test('should parse JSON correctly', () {
      final json = {
        'text': '/həˈloʊ/',
        'audio': 'https://example.com/audio.mp3',
        'sourceUrl': 'https://example.com',
      };

      final phonetic = PhoneticModel.fromJson(json);

      expect(phonetic.text, '/həˈloʊ/');
      expect(phonetic.audio, 'https://example.com/audio.mp3');
      expect(phonetic.sourceUrl, 'https://example.com');
    });

    test('hasAudio should return true when audio exists', () {
      final phonetic = PhoneticModel(audio: 'https://example.com/audio.mp3');
      expect(phonetic.hasAudio, true);
    });

    test('hasAudio should return false when audio is null', () {
      final phonetic = PhoneticModel();
      expect(phonetic.hasAudio, false);
    });

    test('hasAudio should return false when audio is empty', () {
      final phonetic = PhoneticModel(audio: '');
      expect(phonetic.hasAudio, false);
    });
  });

  group('DictionaryModel', () {
    test('should parse JSON correctly', () {
      final json = {
        'word': 'hello',
        'phonetic': '/həˈloʊ/',
        'phonetics': [
          {'text': '/həˈloʊ/', 'audio': 'https://example.com/audio.mp3'},
        ],
        'meanings': [
          {
            'partOfSpeech': 'noun',
            'definitions': [
              {'definition': 'A greeting'},
            ],
          },
        ],
        'sourceUrls': ['https://example.com'],
      };

      final dictionary = DictionaryModel.fromJson(json);

      expect(dictionary.word, 'hello');
      expect(dictionary.phonetic, '/həˈloʊ/');
      expect(dictionary.phonetics.length, 1);
      expect(dictionary.meanings.length, 1);
      expect(dictionary.sourceUrl, 'https://example.com');
    });

    test('bestPhonetic should return phonetic if available', () {
      final dictionary = DictionaryModel(
        word: 'hello',
        phonetic: '/həˈloʊ/',
        meanings: [],
      );

      expect(dictionary.bestPhonetic, '/həˈloʊ/');
    });

    test('bestPhonetic should fallback to phonetics list', () {
      final dictionary = DictionaryModel(
        word: 'hello',
        phonetics: [PhoneticModel(text: '/həˈloʊ/')],
        meanings: [],
      );

      expect(dictionary.bestPhonetic, '/həˈloʊ/');
    });

    test('audioUrl should return first available audio', () {
      final dictionary = DictionaryModel(
        word: 'hello',
        phonetics: [
          PhoneticModel(text: '/həˈloʊ/'),
          PhoneticModel(audio: 'https://example.com/audio.mp3'),
        ],
        meanings: [],
      );

      expect(dictionary.audioUrl, 'https://example.com/audio.mp3');
    });

    test('audioUrl should return null when no audio available', () {
      final dictionary = DictionaryModel(word: 'hello', meanings: []);

      expect(dictionary.audioUrl, null);
    });
  });

  group('DictionaryError', () {
    test('should parse JSON correctly', () {
      final json = {
        'title': 'No Definitions Found',
        'message': 'Sorry, no definitions found',
        'resolution': 'Try another word',
      };

      final error = DictionaryError.fromJson(json);

      expect(error.title, 'No Definitions Found');
      expect(error.message, 'Sorry, no definitions found');
      expect(error.resolution, 'Try another word');
    });

    test('should handle missing resolution', () {
      final json = {'title': 'Error', 'message': 'Something went wrong'};

      final error = DictionaryError.fromJson(json);

      expect(error.resolution, null);
    });
  });
}
