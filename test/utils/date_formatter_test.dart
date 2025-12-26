import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('formatRelativeTime', () {
      test('should return "Just now" for times less than 60 seconds ago', () {
        final now = DateTime.now();
        final result = DateFormatter.formatRelativeTime(now);
        expect(result, 'Just now');
      });

      test('should return minutes ago for times less than 60 minutes ago', () {
        final fiveMinutesAgo = DateTime.now().subtract(
          const Duration(minutes: 5),
        );
        final result = DateFormatter.formatRelativeTime(fiveMinutesAgo);
        expect(result, '5m ago');
      });

      test('should return hours ago for times less than 24 hours ago', () {
        final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
        final result = DateFormatter.formatRelativeTime(twoHoursAgo);
        expect(result, '2h ago');
      });

      test('should return "Yesterday" for times 1 day ago', () {
        final yesterday = DateTime.now().subtract(const Duration(days: 1));
        final result = DateFormatter.formatRelativeTime(yesterday);
        expect(result, 'Yesterday');
      });

      test('should return days ago for times less than 7 days ago', () {
        final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
        final result = DateFormatter.formatRelativeTime(threeDaysAgo);
        expect(result, '3d ago');
      });

      test('should return formatted date for times more than 7 days ago', () {
        final date = DateTime(2024, 1, 15);
        final result = DateFormatter.formatRelativeTime(date);
        expect(result, 'Jan 15');
      });
    });

    group('formatTime', () {
      test('should format morning time correctly', () {
        final morning = DateTime(2024, 1, 15, 9, 30);
        final result = DateFormatter.formatTime(morning);
        expect(result, '9:30 AM');
      });

      test('should format afternoon time correctly', () {
        final afternoon = DateTime(2024, 1, 15, 14, 45);
        final result = DateFormatter.formatTime(afternoon);
        expect(result, '2:45 PM');
      });

      test('should format midnight correctly', () {
        final midnight = DateTime(2024, 1, 15, 0, 5);
        final result = DateFormatter.formatTime(midnight);
        expect(result, '12:05 AM');
      });

      test('should format noon correctly', () {
        final noon = DateTime(2024, 1, 15, 12, 0);
        final result = DateFormatter.formatTime(noon);
        expect(result, '12:00 PM');
      });
    });

    group('formatMessageTime', () {
      test('should return time only for today', () {
        final now = DateTime.now();
        final todayTime = DateTime(now.year, now.month, now.day, 10, 30);
        final result = DateFormatter.formatMessageTime(todayTime);
        expect(result, '10:30 AM');
      });

      test('should return "Yesterday" prefix for yesterday', () {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1, 15, 45);
        final result = DateFormatter.formatMessageTime(yesterday);
        expect(result.startsWith('Yesterday'), true);
      });

      test('should return date and time for older dates', () {
        final oldDate = DateTime(2024, 3, 10, 14, 20);
        final result = DateFormatter.formatMessageTime(oldDate);
        expect(result, 'Mar 10 2:20 PM');
      });
    });
  });
}
