class DateFormatter {
  static const List<String> _thaiMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  static String formatYMD(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// แปลง DateTime เป็นวันที่ย่อภาษาไทย เช่น 29 ก.ย., 14 ต.ค.
  static String formatThaiShortDate(DateTime date) {
    final day = date.day;
    final monthStr = _thaiMonths[date.month - 1];
    return '$day $monthStr';
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
