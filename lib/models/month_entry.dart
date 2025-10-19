class MonthEntry {
  final int year;
  final int month; // 1-12
  final int count; // number of media in this month
  const MonthEntry({required this.year, required this.month, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MonthEntry && runtimeType == other.runtimeType && year == other.year && month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  String get shortLabel {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final yy = year % 100;
    return "${months[month - 1]} '$yy";
  }
}
