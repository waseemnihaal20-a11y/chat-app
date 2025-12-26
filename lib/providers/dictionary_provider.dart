import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/dictionary_model.dart';
import '../services/dictionary_service.dart';

/// Provider for managing dictionary lookups and audio playback.
/// Handles word definition fetching and pronunciation audio.
class DictionaryProvider extends ChangeNotifier {
  final DictionaryService _dictionaryService;
  final AudioPlayer _audioPlayer;

  DictionaryModel? _currentDefinition;
  DictionaryError? _error;
  bool _isLoading = false;
  bool _isPlayingAudio = false;
  String? _currentWord;

  DictionaryProvider({
    DictionaryService? dictionaryService,
    AudioPlayer? audioPlayer,
  }) : _dictionaryService = dictionaryService ?? DictionaryService(),
       _audioPlayer = audioPlayer ?? AudioPlayer() {
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlayingAudio = false;
      notifyListeners();
    });
  }

  /// Gets the current word being looked up
  String? get currentWord => _currentWord;

  /// Gets the current dictionary definition
  DictionaryModel? get currentDefinition => _currentDefinition;

  /// Gets any error from the last lookup
  DictionaryError? get error => _error;

  /// Gets the loading state
  bool get isLoading => _isLoading;

  /// Gets the audio playing state
  bool get isPlayingAudio => _isPlayingAudio;

  /// Whether there's an audio URL available for the current word
  bool get hasAudio => _currentDefinition?.audioUrl != null;

  /// Looks up a word in the dictionary
  Future<void> lookupWord(String word) async {
    if (word.trim().isEmpty) return;

    _currentWord = word.trim();
    _isLoading = true;
    _error = null;
    _currentDefinition = null;
    notifyListeners();

    try {
      _currentDefinition = await _dictionaryService.getDefinition(word);
      _error = null;
    } on DictionaryError catch (e) {
      _error = e;
      _currentDefinition = null;
    } catch (e) {
      _error = DictionaryError(
        title: 'Error',
        message: 'An unexpected error occurred: $e',
      );
      _currentDefinition = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Plays the pronunciation audio for the current word
  Future<void> playAudio() async {
    final audioUrl = _currentDefinition?.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) return;

    try {
      _isPlayingAudio = true;
      notifyListeners();

      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      _isPlayingAudio = false;
      notifyListeners();
    }
  }

  /// Stops any currently playing audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlayingAudio = false;
      notifyListeners();
    } catch (_) {}
  }

  /// Clears the current definition and error
  void clear() {
    _currentWord = null;
    _currentDefinition = null;
    _error = null;
    _isLoading = false;
    stopAudio();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _dictionaryService.dispose();
    super.dispose();
  }
}
