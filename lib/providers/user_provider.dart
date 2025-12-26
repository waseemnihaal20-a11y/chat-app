import 'package:flutter/foundation.dart';

import '../models/user_model.dart';

/// Provider for managing the users list.
/// Handles CRUD operations for users with ChangeNotifier for UI updates.
class UserProvider extends ChangeNotifier {
  final List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  /// Gets the list of all users
  List<UserModel> get users => List.unmodifiable(_users);

  /// Gets the loading state
  bool get isLoading => _isLoading;

  /// Gets any error message
  String? get error => _error;

  /// Initializes with some default users
  UserProvider() {
    _initializeDefaultUsers();
  }

  void _initializeDefaultUsers() {
    _users.addAll([
      UserModel(id: '1', fullName: 'Emma Wilson', username: 'emmac'),
      UserModel(id: '2', fullName: 'James Rodriguez', username: 'jamesr'),
      UserModel(id: '3', fullName: 'Sarah Chen', username: 'sarahc'),
      UserModel(id: '4', fullName: 'Michael Brown', username: 'mikeb'),
      UserModel(id: '5', fullName: 'Olivia Martinez', username: 'oliviam'),
    ]);
  }

  /// Adds a new user to the list
  void addUser(String fullName) {
    if (fullName.trim().isEmpty) {
      _error = 'Name cannot be empty';
      notifyListeners();
      return;
    }

    final newUser = UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: fullName.trim(),
      username: fullName.trim().toLowerCase().replaceAll(' ', '_'),
    );

    _users.insert(0, newUser);
    _error = null;
    notifyListeners();
  }

  /// Removes a user from the list
  void removeUser(String userId) {
    _users.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  /// Updates an existing user
  void updateUser(String userId, {String? fullName, String? username}) {
    final index = _users.indexWhere((user) => user.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(
        fullName: fullName,
        username: username,
      );
      notifyListeners();
    }
  }

  /// Gets a user by ID
  UserModel? getUserById(String userId) {
    try {
      return _users.firstWhere((user) => user.id == userId);
    } catch (_) {
      return null;
    }
  }

  /// Clears any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Sets loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
