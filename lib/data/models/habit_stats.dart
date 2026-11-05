import '../models/habit.dart';

/// Thống kê cho một ngày cụ thể
class DayStats {
  final DateTime date;
  final int totalHabits;
  final int completedHabits;

  const DayStats({
    required this.date,
    required this.totalHabits,
    required this.completedHabits,
  });

  double get rate => totalHabits > 0 ? (completedHabits / totalHabits) : 0.0;
  int get percentage => (rate * 100).round();
  bool get isPerfect => totalHabits > 0 && completedHabits >= totalHabits;
}

/// Thống kê theo tuần (7 ngày)
class WeekStats {
  final DateTime startDate;
  final DateTime endDate;
  final List<DayStats> days;

  const WeekStats({
    required this.startDate,
    required this.endDate,
    required this.days,
  });

  int get totalPossibleHabits => days.fold(0, (sum, d) => sum + d.totalHabits);
  int get totalCompletedHabits => days.fold(0, (sum, d) => sum + d.completedHabits);

  double get averageRate =>
      totalPossibleHabits > 0 ? (totalCompletedHabits / totalPossibleHabits) : 0.0;

  int get averagePercentage => (averageRate * 100).round();

  DayStats? get bestDay {
    if (days.isEmpty) return null;
    DayStats best = days.first;
    for (final day in days) {
      if (day.rate > best.rate) {
        best = day;
      }
    }
    return best;
  }
}

/// Thống kê theo tháng
class MonthStats {
  final int year;
  final int month;
  final List<DayStats> days;
  final Map<int, int> habitCompletionCounts; // habitId -> số lần hoàn thành trong tháng
  final List<Habit> activeHabits;

  const MonthStats({
    required this.year,
    required this.month,
    required this.days,
    required this.habitCompletionCounts,
    required this.activeHabits,
  });

  int get totalPossibleHabits => days.fold(0, (sum, d) => sum + d.totalHabits);
  int get totalCompletedHabits => days.fold(0, (sum, d) => sum + d.completedHabits);

  double get averageRate =>
      totalPossibleHabits > 0 ? (totalCompletedHabits / totalPossibleHabits) : 0.0;

  int get averagePercentage => (averageRate * 100).round();

  /// Số ngày hoàn thành 100% mục tiêu
  int get perfectDaysCount => days.where((d) => d.isPerfect).length;

  /// Lấy thói quen có số lần hoàn thành nhiều nhất trong tháng
  Habit? get topHabit {
    if (activeHabits.isEmpty || habitCompletionCounts.isEmpty) return null;
    Habit? top;
    int maxCount = -1;
    for (final habit in activeHabits) {
      final count = habitCompletionCounts[habit.id] ?? 0;
      if (count > maxCount) {
        maxCount = count;
        top = habit;
      }
    }
    return top;
  }
}
