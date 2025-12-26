import 'package:flutter/foundation.dart';

/// Provider for managing app settings like notifications, privacy, etc.
class SettingsProvider extends ChangeNotifier {
  // Notification settings
  bool _pushNotificationsEnabled = true;
  bool _messageSoundsEnabled = true;

  // Privacy settings
  bool _readReceiptsEnabled = true;
  bool _onlineStatusEnabled = true;

  // Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get messageSoundsEnabled => _messageSoundsEnabled;
  bool get readReceiptsEnabled => _readReceiptsEnabled;
  bool get onlineStatusEnabled => _onlineStatusEnabled;

  // Setters with notifications
  void setPushNotifications(bool value) {
    if (_pushNotificationsEnabled != value) {
      _pushNotificationsEnabled = value;
      notifyListeners();
    }
  }

  void setMessageSounds(bool value) {
    if (_messageSoundsEnabled != value) {
      _messageSoundsEnabled = value;
      notifyListeners();
    }
  }

  void setReadReceipts(bool value) {
    if (_readReceiptsEnabled != value) {
      _readReceiptsEnabled = value;
      notifyListeners();
    }
  }

  void setOnlineStatus(bool value) {
    if (_onlineStatusEnabled != value) {
      _onlineStatusEnabled = value;
      notifyListeners();
    }
  }

  // Toggle methods for convenience
  void togglePushNotifications() =>
      setPushNotifications(!_pushNotificationsEnabled);
  void toggleMessageSounds() => setMessageSounds(!_messageSoundsEnabled);
  void toggleReadReceipts() => setReadReceipts(!_readReceiptsEnabled);
  void toggleOnlineStatus() => setOnlineStatus(!_onlineStatusEnabled);
}
