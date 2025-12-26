/// Utility class for formatting dates and times in the chat application.
class DateFormatter {
  DateFormatter._();

  /// Formats a DateTime to a human-readable relative time string.
  /// Examples: "Just now", "5m ago", "2h ago", "Yesterday", "Jan 12"
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return _formatDate(dateTime);
    }
  }

  /// Formats a DateTime to a short date string (e.g., "Jan 12")
  static String _formatDate(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dateTime.month - 1]} ${dateTime.day}';
  }

  /// Formats a DateTime to a time string (e.g., "2:30 PM")
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  /// Formats a DateTime to a message timestamp format
  /// Shows time for today, "Yesterday" for yesterday, or date for older
  static String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDay == today) {
      return formatTime(dateTime);
    } else if (today.difference(messageDay).inDays == 1) {
      return 'Yesterday ${formatTime(dateTime)}';
    } else {
      return '${_formatDate(dateTime)} ${formatTime(dateTime)}';
    }
  }
}
