class DateFormatter {
  static String formatYMD(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static ({String from, String to}) calculateDateRange({
    required int days,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final today = DateTime.utc(current.year, current.month, current.day);
    final past = today.subtract(Duration(days: days));
    return (from: formatYMD(past), to: formatYMD(today));
  }
}
