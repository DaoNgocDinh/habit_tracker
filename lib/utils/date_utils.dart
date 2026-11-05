import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Định dạng YYYY-MM-DD dùng làm khóa trong SQLite
  static String toIsoDate(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Parse từ chuỗi YYYY-MM-DD sang DateTime
  static DateTime parseIsoDate(String dateStr) {
    return _isoFormat.parse(dateStr);
  }

  /// Chuẩn hóa ngày về 00:00:00 để so sánh chính xác
  static DateTime stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Kiểm tra 2 ngày có cùng ngày/tháng/năm
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Kiểm tra ngày có phải hôm nay
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Tên thứ tiếng Việt ngắn gọn (T2, T3, ...)
  static String getShortWeekdayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  /// Tên thứ tiếng Việt đầy đủ (Thứ Hai, Thứ Ba, ...)
  static String getFullWeekdayName(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  /// Chuỗi ngày hiển thị đầy đủ: "Thứ Sáu, 06 tháng 11, 2026"
  static String formatFullDate(DateTime date) {
    final weekday = getFullWeekdayName(date);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekday, $day/$month/${date.year}';
  }

  /// Chuỗi ngày hiển thị ngắn: "06/11"
  static String formatShortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  /// Lấy danh sách 7 ngày trong tuần chứa ngày được chọn (Bắt đầu từ Thứ 2 đến Chủ Nhật)
  static List<DateTime> getDaysOfWeek(DateTime anchor) {
    final cleanAnchor = stripTime(anchor);
    // Trong Dart: Monday = 1, Sunday = 7
    final monday = cleanAnchor.subtract(Duration(days: cleanAnchor.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  /// Lấy danh sách các ngày trong dải ngày quanh hôm nay (vd: 14 ngày gần nhất)
  static List<DateTime> getRecentDays(DateTime centerDate, {int daysBefore = 7, int daysAfter = 7}) {
    final clean = stripTime(centerDate);
    final start = clean.subtract(Duration(days: daysBefore));
    final count = daysBefore + daysAfter + 1;
    return List.generate(count, (i) => start.add(Duration(days: i)));
  }

  /// Lấy danh sách các ngày trong tháng
  static List<DateTime> getDaysInMonth(DateTime anchor) {
    final year = anchor.year;
    final month = anchor.month;
    final daysCount = DateTime(year, month + 1, 0).day;
    return List.generate(daysCount, (i) => DateTime(year, month, i + 1));
  }
}
