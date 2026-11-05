import 'package:flutter/foundation.dart';
import '../data/database/app_database.dart';
import '../data/models/habit.dart';
import '../data/models/habit_stats.dart';
import '../utils/date_utils.dart';

class HabitProvider extends ChangeNotifier {
  final AppDatabase _db = AppDatabase.instance;

  List<Habit> _habits = [];
  DateTime _selectedDate = AppDateUtils.stripTime(DateTime.now());
  Set<int> _completedHabitIds = {};
  Map<int, int> _streaks = {};
  bool _isLoading = true;
  String _currentFilter = 'all'; // 'all', 'pending', 'completed'

  WeekStats? _weekStats;
  MonthStats? _monthStats;

  // Getters
  List<Habit> get habits => _habits;
  DateTime get selectedDate => _selectedDate;
  Set<int> get completedHabitIds => _completedHabitIds;
  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;
  WeekStats? get weekStats => _weekStats;
  MonthStats? get monthStats => _monthStats;

  /// Danh sách các thói quen áp dụng cho ngày được chọn
  List<Habit> get habitsForSelectedDate {
    return _habits.where((h) => h.appliesToDate(_selectedDate)).toList();
  }

  /// Danh sách thói quen sau khi áp dụng bộ lọc (Tất cả, Chưa xong, Đã xong)
  List<Habit> get filteredHabits {
    final list = habitsForSelectedDate;
    if (_currentFilter == 'completed') {
      return list.where((h) => _completedHabitIds.contains(h.id)).toList();
    } else if (_currentFilter == 'pending') {
      return list.where((h) => !_completedHabitIds.contains(h.id)).toList();
    }
    return list;
  }

  /// Thống kê ngày được chọn
  DayStats get currentDayStats {
    final total = habitsForSelectedDate.length;
    final completed = habitsForSelectedDate
        .where((h) => _completedHabitIds.contains(h.id))
        .length;
    return DayStats(
      date: _selectedDate,
      totalHabits: total,
      completedHabits: completed,
    );
  }

  bool isHabitCompleted(int habitId) {
    return _completedHabitIds.contains(habitId);
  }

  int getStreak(int habitId) {
    return _streaks[habitId] ?? 0;
  }

  // ================= LOAD DATA =================

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habits = await _db.getAllHabits();
      await _loadCompletionsForDate(_selectedDate);
      await _loadStreaks();
      await refreshStatistics();
    } catch (e) {
      debugPrint('Lỗi tải dữ liệu: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setSelectedDate(DateTime date) async {
    final clean = AppDateUtils.stripTime(date);
    if (AppDateUtils.isSameDay(_selectedDate, clean)) return;

    _selectedDate = clean;
    await _loadCompletionsForDate(clean);
    await refreshStatistics();
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> _loadCompletionsForDate(DateTime date) async {
    final dateStr = AppDateUtils.toIsoDate(date);
    _completedHabitIds = await _db.getCompletedHabitIdsForDate(dateStr);
  }

  Future<void> _loadStreaks() async {
    final map = <int, int>{};
    for (final habit in _habits) {
      if (habit.id != null) {
        map[habit.id!] = await _db.getStreakForHabit(habit.id!);
      }
    }
    _streaks = map;
  }

  // ================= ACTIONS =================

  /// Thêm thói quen mới
  Future<void> addHabit(Habit habit) async {
    final newId = await _db.insertHabit(habit);
    final newHabit = habit.copyWith(id: newId);
    _habits.add(newHabit);
    _streaks[newId] = 0;
    await refreshStatistics();
    notifyListeners();
  }

  /// Cập nhật thói quen
  Future<void> updateHabit(Habit habit) async {
    await _db.updateHabit(habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
    await refreshStatistics();
    notifyListeners();
  }

  /// Xóa thói quen
  Future<void> deleteHabit(int habitId) async {
    await _db.deleteHabit(habitId);
    _habits.removeWhere((h) => h.id == habitId);
    _completedHabitIds.remove(habitId);
    _streaks.remove(habitId);
    await refreshStatistics();
    notifyListeners();
  }

  /// Đánh dấu hoàn thành / bỏ hoàn thành
  Future<void> toggleHabitCompletion(int habitId) async {
    final dateStr = AppDateUtils.toIsoDate(_selectedDate);
    final isDone = await _db.toggleHabitCompletion(habitId, dateStr);

    if (isDone) {
      _completedHabitIds.add(habitId);
    } else {
      _completedHabitIds.remove(habitId);
    }

    // Cập nhật lại streak
    _streaks[habitId] = await _db.getStreakForHabit(habitId);
    await refreshStatistics();
    notifyListeners();
  }

  // ================= THỐNG KÊ (TUẦN & THÁNG) =================

  Future<void> refreshStatistics() async {
    _weekStats = await calculateWeekStats(_selectedDate);
    _monthStats = await calculateMonthStats(_selectedDate);
  }

  /// Tính thống kê 7 ngày trong tuần
  Future<WeekStats> calculateWeekStats(DateTime anchorDate) async {
    final daysOfWeek = AppDateUtils.getDaysOfWeek(anchorDate);
    final startDateStr = AppDateUtils.toIsoDate(daysOfWeek.first);
    final endDateStr = AppDateUtils.toIsoDate(daysOfWeek.last);

    final logs = await _db.getLogsBetweenDates(startDateStr, endDateStr);
    final logsByDate = <String, Set<int>>{};
    for (final log in logs) {
      logsByDate.putIfAbsent(log.date, () => <int>{}).add(log.habitId);
    }

    final dayStatsList = <DayStats>[];
    for (final day in daysOfWeek) {
      final dateStr = AppDateUtils.toIsoDate(day);
      final dueHabits = _habits.where((h) => h.appliesToDate(day)).toList();
      final completedSet = logsByDate[dateStr] ?? <int>{};
      final completedCount = dueHabits.where((h) => completedSet.contains(h.id)).length;

      dayStatsList.add(DayStats(
        date: day,
        totalHabits: dueHabits.length,
        completedHabits: completedCount,
      ));
    }

    return WeekStats(
      startDate: daysOfWeek.first,
      endDate: daysOfWeek.last,
      days: dayStatsList,
    );
  }

  /// Tính thống kê trong tháng
  Future<MonthStats> calculateMonthStats(DateTime anchorDate) async {
    final daysInMonth = AppDateUtils.getDaysInMonth(anchorDate);
    final startDateStr = AppDateUtils.toIsoDate(daysInMonth.first);
    final endDateStr = AppDateUtils.toIsoDate(daysInMonth.last);

    final logs = await _db.getLogsBetweenDates(startDateStr, endDateStr);
    final logsByDate = <String, Set<int>>{};
    final habitCompletionCounts = <int, int>{};

    for (final log in logs) {
      logsByDate.putIfAbsent(log.date, () => <int>{}).add(log.habitId);
      habitCompletionCounts[log.habitId] = (habitCompletionCounts[log.habitId] ?? 0) + 1;
    }

    final dayStatsList = <DayStats>[];
    for (final day in daysInMonth) {
      final dateStr = AppDateUtils.toIsoDate(day);
      final dueHabits = _habits.where((h) => h.appliesToDate(day)).toList();
      final completedSet = logsByDate[dateStr] ?? <int>{};
      final completedCount = dueHabits.where((h) => completedSet.contains(h.id)).length;

      dayStatsList.add(DayStats(
        date: day,
        totalHabits: dueHabits.length,
        completedHabits: completedCount,
      ));
    }

    return MonthStats(
      year: anchorDate.year,
      month: anchorDate.month,
      days: dayStatsList,
      habitCompletionCounts: habitCompletionCounts,
      activeHabits: _habits,
    );
  }
}
