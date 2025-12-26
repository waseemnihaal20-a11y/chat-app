/// Represents a definition of a word
class DefinitionModel {
  final String definition;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;

  DefinitionModel({
    required this.definition,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory DefinitionModel.fromJson(Map<String, dynamic> json) {
    return DefinitionModel(
      definition: json['definition'] ?? '',
      example: json['example'],
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}

/// Represents a meaning (part of speech) of a word
class MeaningModel {
  final String partOfSpeech;
  final List<DefinitionModel> definitions;
  final List<String> synonyms;
  final List<String> antonyms;

  MeaningModel({
    required this.partOfSpeech,
    required this.definitions,
    this.synonyms = const [],
    this.antonyms = const [],
  });

  factory MeaningModel.fromJson(Map<String, dynamic> json) {
    return MeaningModel(
      partOfSpeech: json['partOfSpeech'] ?? '',
      definitions:
          (json['definitions'] as List?)
              ?.map((d) => DefinitionModel.fromJson(d))
              .toList() ??
          [],
      synonyms: List<String>.from(json['synonyms'] ?? []),
      antonyms: List<String>.from(json['antonyms'] ?? []),
    );
  }
}

/// Represents phonetic information including audio
class PhoneticModel {
  final String? text;
  final String? audio;
  final String? sourceUrl;

  PhoneticModel({this.text, this.audio, this.sourceUrl});

  factory PhoneticModel.fromJson(Map<String, dynamic> json) {
    return PhoneticModel(
      text: json['text'],
      audio: json['audio'],
      sourceUrl: json['sourceUrl'],
    );
  }

  /// Returns true if this phonetic has a valid audio URL
  bool get hasAudio => audio != null && audio!.isNotEmpty;
}

/// Represents a complete dictionary entry for a word
class DictionaryModel {
  final String word;
  final String? phonetic;
  final List<PhoneticModel> phonetics;
  final List<MeaningModel> meanings;
  final String? sourceUrl;

  DictionaryModel({
    required this.word,
    this.phonetic,
    this.phonetics = const [],
    required this.meanings,
    this.sourceUrl,
  });

  factory DictionaryModel.fromJson(Map<String, dynamic> json) {
    return DictionaryModel(
      word: json['word'] ?? '',
      phonetic: json['phonetic'],
      phonetics:
          (json['phonetics'] as List?)
              ?.map((p) => PhoneticModel.fromJson(p))
              .toList() ??
          [],
      meanings:
          (json['meanings'] as List?)
              ?.map((m) => MeaningModel.fromJson(m))
              .toList() ??
          [],
      sourceUrl: (json['sourceUrls'] as List?)?.firstOrNull,
    );
  }

  /// Gets the best available phonetic text
  String? get bestPhonetic {
    if (phonetic != null && phonetic!.isNotEmpty) return phonetic;
    for (final p in phonetics) {
      if (p.text != null && p.text!.isNotEmpty) return p.text;
    }
    return null;
  }

  /// Gets the first available audio URL
  String? get audioUrl {
    for (final p in phonetics) {
      if (p.hasAudio) return p.audio;
    }
    return null;
  }
}

/// Represents a dictionary API error response
class DictionaryError {
  final String title;
  final String message;
  final String? resolution;

  DictionaryError({
    required this.title,
    required this.message,
    this.resolution,
  });

  factory DictionaryError.fromJson(Map<String, dynamic> json) {
    return DictionaryError(
      title: json['title'] ?? 'Error',
      message: json['message'] ?? 'An unknown error occurred',
      resolution: json['resolution'],
    );
  }
}
