import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider', () {
    late NavigationProvider provider;

    setUp(() {
      provider = NavigationProvider();
    });

    test('should start with bottom nav index 0', () {
      expect(provider.currentBottomNavIndex, 0);
    });

    test('should start with users list tab selected', () {
      expect(provider.currentHomeTab, HomeTab.usersList);
      expect(provider.isUsersListTab, true);
      expect(provider.isChatHistoryTab, false);
    });

    group('setBottomNavIndex', () {
      test('should update bottom nav index', () {
        provider.setBottomNavIndex(1);
        expect(provider.currentBottomNavIndex, 1);

        provider.setBottomNavIndex(2);
        expect(provider.currentBottomNavIndex, 2);
      });

      test('should not update for same index', () {
        var notified = false;
        provider.addListener(() => notified = true);

        provider.setBottomNavIndex(0);

        expect(notified, false);
      });

      test('should not update for invalid index', () {
        provider.setBottomNavIndex(-1);
        expect(provider.currentBottomNavIndex, 0);

        provider.setBottomNavIndex(5);
        expect(provider.currentBottomNavIndex, 0);
      });
    });

    group('setHomeTab', () {
      test('should update home tab', () {
        provider.setHomeTab(HomeTab.chatHistory);

        expect(provider.currentHomeTab, HomeTab.chatHistory);
        expect(provider.isChatHistoryTab, true);
        expect(provider.isUsersListTab, false);
      });

      test('should not notify for same tab', () {
        var notified = false;
        provider.addListener(() => notified = true);

        provider.setHomeTab(HomeTab.usersList);

        expect(notified, false);
      });
    });

    group('toggleHomeTab', () {
      test('should toggle from users list to chat history', () {
        expect(provider.isUsersListTab, true);

        provider.toggleHomeTab();

        expect(provider.isChatHistoryTab, true);
      });

      test('should toggle from chat history to users list', () {
        provider.setHomeTab(HomeTab.chatHistory);

        provider.toggleHomeTab();

        expect(provider.isUsersListTab, true);
      });
    });

    group('reset', () {
      test('should reset to initial state', () {
        provider.setBottomNavIndex(2);
        provider.setHomeTab(HomeTab.chatHistory);

        provider.reset();

        expect(provider.currentBottomNavIndex, 0);
        expect(provider.currentHomeTab, HomeTab.usersList);
      });
    });
  });

  group('HomeTab', () {
    test('should have usersList and chatHistory values', () {
      expect(HomeTab.values, contains(HomeTab.usersList));
      expect(HomeTab.values, contains(HomeTab.chatHistory));
    });
  });
}
