import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracker/data/models/habit.dart';
import 'package:habit_tracker/data/models/habit_stats.dart';

void main() {
  group('Habit Model Tests', () {
    test('Habit serialization & deserialization', () {
      final habit = Habit(
        id: 1,
        title: 'Chạy bộ buổi sáng',
        description: 'Chạy 3km quanh công viên',
        frequency: 'daily',
        reminderHour: 6,
        reminderMinute: 15,
        colorValue: 0xFF10B981,
        iconCodePoint: 61440,
        createdAt: DateTime(2026, 11, 6, 6, 0),
      );

      final map = habit.toMap();
      expect(map['id'], 1);
      expect(map['title'], 'Chạy bộ buổi sáng');
      expect(map['frequency'], 'daily');
      expect(map['reminder_hour'], 6);
      expect(map['reminder_minute'], 15);

      final fromMap = Habit.fromMap(map);
      expect(fromMap.id, habit.id);
      expect(fromMap.title, habit.title);
      expect(fromMap.reminderTimeString, '06:15');
      expect(fromMap.frequencyLabel, 'Hàng ngày');
    });

    test('Habit frequency filter verification', () {
      final weekdayHabit = Habit(
        title: 'Học tiếng Anh',
        frequency: 'weekdays',
        reminderHour: 20,
        reminderMinute: 0,
        colorValue: 0xFF2563EB,
        iconCodePoint: 61440,
        createdAt: DateTime.now(),
      );

      final wednesday = DateTime(2026, 11, 4); // Wednesday
      final sunday = DateTime(2026, 11, 8); // Sunday

      expect(weekdayHabit.appliesToDate(wednesday), isTrue);
      expect(weekdayHabit.appliesToDate(sunday), isFalse);
    });
  });

  group('Statistics Calculation Tests', () {
    test('DayStats percentage and completion rate', () {
      final dayStats = DayStats(
        date: DateTime(2026, 11, 6),
        totalHabits: 4,
        completedHabits: 3,
      );

      expect(dayStats.rate, 0.75);
      expect(dayStats.percentage, 75);
      expect(dayStats.isPerfect, isFalse);

      final perfectStats = DayStats(
        date: DateTime(2026, 11, 6),
        totalHabits: 4,
        completedHabits: 4,
      );
      expect(perfectStats.isPerfect, isTrue);
      expect(perfectStats.percentage, 100);
    });

    test('WeekStats average and best day', () {
      final days = [
        DayStats(date: DateTime(2026, 11, 2), totalHabits: 4, completedHabits: 2), // 50%
        DayStats(date: DateTime(2026, 11, 3), totalHabits: 4, completedHabits: 4), // 100%
        DayStats(date: DateTime(2026, 11, 4), totalHabits: 4, completedHabits: 3), // 75%
      ];

      final weekStats = WeekStats(
        startDate: DateTime(2026, 11, 2),
        endDate: DateTime(2026, 11, 8),
        days: days,
      );

      expect(weekStats.totalPossibleHabits, 12);
      expect(weekStats.totalCompletedHabits, 9);
      expect(weekStats.averagePercentage, 75);
      expect(weekStats.bestDay?.date.day, 3);
    });
  });
}
