// Small time-formatting helpers shared by the Reports widgets.

import 'package:nexoraiot/contexts/consumption/domain/entities/consumption_view.dart';

const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
];

/// Builds the chart X-axis labels in the device's local timezone, evenly spaced
/// across the report window that ends at [endUtc]. The Day view uses 24h format.
List<String> buildAxisLabels(DateTime? endUtc, ConsumptionRange range) {
  final end = (endUtc ?? DateTime.now().toUtc()).toLocal();
  final window = switch (range) {
    ConsumptionRange.day => const Duration(hours: 24),
    ConsumptionRange.week => const Duration(days: 7),
    ConsumptionRange.month => const Duration(days: 30),
    ConsumptionRange.year => const Duration(days: 360),
  };
  final start = end.subtract(window);

  const count = 5;
  final labels = <String>[];
  for (var i = 0; i < count; i++) {
    final t = start.add(
      Duration(microseconds: window.inMicroseconds * i ~/ (count - 1)),
    );
    labels.add(_formatAxis(range, t));
  }
  return labels;
}

String _formatAxis(ConsumptionRange range, DateTime t) {
  switch (range) {
    case ConsumptionRange.day: // 24-hour clock, e.g. "14:30"
      final h = t.hour.toString().padLeft(2, '0');
      final m = t.minute.toString().padLeft(2, '0');
      return '$h:$m';
    case ConsumptionRange.week:
      return _weekdays[t.weekday - 1];
    case ConsumptionRange.month:
      return '${t.month}/${t.day}';
    case ConsumptionRange.year:
      return _months[t.month - 1];
  }
}

/// A short, human relative time such as "now", "5m ago", "3h ago", "2d ago".
String relativeTime(DateTime time) {
  final now = DateTime.now().toUtc();
  final t = time.toUtc();
  var diff = now.difference(t);
  if (diff.isNegative) diff = Duration.zero;

  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  final weeks = (diff.inDays / 7).floor();
  if (weeks < 5) return '${weeks}w ago';
  final months = (diff.inDays / 30).floor();
  return '${months}mo ago';
}

/// A local 12-hour clock label such as "2:00 PM".
String clockTime(DateTime time) {
  final t = time.toLocal();
  final h12 = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final suffix = t.hour < 12 ? 'AM' : 'PM';
  return '$h12:$minute $suffix';
}
