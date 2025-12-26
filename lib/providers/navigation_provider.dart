import 'package:flutter/foundation.dart';

/// Enum for the home screen tab options
enum HomeTab { usersList, chatHistory }

/// Provider for managing navigation state across the app.
/// Handles bottom navigation and home screen tab selection.
class NavigationProvider extends ChangeNotifier {
  int _currentBottomNavIndex = 0;
  HomeTab _currentHomeTab = HomeTab.usersList;

  /// Gets the current bottom navigation index
  int get currentBottomNavIndex => _currentBottomNavIndex;

  /// Gets the current home tab selection
  HomeTab get currentHomeTab => _currentHomeTab;

  /// Whether the current tab is the users list
  bool get isUsersListTab => _currentHomeTab == HomeTab.usersList;

  /// Whether the current tab is chat history
  bool get isChatHistoryTab => _currentHomeTab == HomeTab.chatHistory;

  /// Sets the bottom navigation index
  void setBottomNavIndex(int index) {
    if (index != _currentBottomNavIndex && index >= 0 && index <= 2) {
      _currentBottomNavIndex = index;
      notifyListeners();
    }
  }

  /// Sets the home tab selection
  void setHomeTab(HomeTab tab) {
    if (tab != _currentHomeTab) {
      _currentHomeTab = tab;
      notifyListeners();
    }
  }

  /// Toggles between users list and chat history tabs
  void toggleHomeTab() {
    _currentHomeTab = _currentHomeTab == HomeTab.usersList
        ? HomeTab.chatHistory
        : HomeTab.usersList;
    notifyListeners();
  }

  /// Resets navigation to initial state
  void reset() {
    _currentBottomNavIndex = 0;
    _currentHomeTab = HomeTab.usersList;
    notifyListeners();
  }
}
