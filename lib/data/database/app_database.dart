import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../../utils/date_utils.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('discipline_habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Khởi tạo FFI driver khi chạy trên Desktop (Windows / Linux)
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Bật khóa ngoại để ON DELETE CASCADE hoạt động
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // Tạo bảng thói quen
    await db.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        frequency TEXT NOT NULL,
        reminder_hour INTEGER NOT NULL,
        reminder_minute INTEGER NOT NULL,
        color_value INTEGER NOT NULL,
        icon_code_point INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tạo bảng lịch sử hoàn thành thói quen theo ngày
    await db.execute('''
      CREATE TABLE habit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');

    // Dữ liệu mẫu khởi tạo ban đầu để người dùng trải nghiệm ngay
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    final now = DateTime.now();

    final starterHabits = [
      {
        'title': 'Dậy sớm lúc 06:00',
        'description': 'Bắt đầu ngày mới đầy năng lượng, không bấm chuông báo lại',
        'frequency': 'daily',
        'reminder_hour': 6,
        'reminder_minute': 0,
        'color_value': 0xFF0D9488, // Teal
        'icon_code_point': Icons.alarm.codePoint,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'title': 'Tập thể dục 30 phút',
        'description': 'Chạy bộ nhẹ nhàng hoặc tập gym để nâng cao thể lực',
        'frequency': 'daily',
        'reminder_hour': 6,
        'reminder_minute': 30,
        'color_value': 0xFFEA580C, // Orange
        'icon_code_point': Icons.fitness_center.codePoint,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'title': 'Đọc sách 20 trang',
        'description': 'Đọc sách phát triển tư duy và kỹ năng chuyên môn',
        'frequency': 'daily',
        'reminder_hour': 21,
        'reminder_minute': 0,
        'color_value': 0xFF4F46E5, // Indigo
        'icon_code_point': Icons.menu_book.codePoint,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'title': 'Uống đủ 2 lít nước',
        'description': 'Uống đều đặn từng ngụm nước trong suốt cả ngày',
        'frequency': 'daily',
        'reminder_hour': 9,
        'reminder_minute': 0,
        'color_value': 0xFF0284C7, // Sky Blue
        'icon_code_point': Icons.local_drink.codePoint,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
      {
        'title': 'Lập kế hoạch ngày mai',
        'description': 'Viết ra 3 mục tiêu ưu tiên quan trọng nhất cho ngày kế tiếp',
        'frequency': 'weekdays',
        'reminder_hour': 22,
        'reminder_minute': 0,
        'color_value': 0xFF9333EA, // Purple
        'icon_code_point': Icons.checklist_rtl.codePoint,
        'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    final insertedIds = <int>[];
    for (final habitMap in starterHabits) {
      final id = await db.insert('habits', habitMap);
      insertedIds.add(id);
    }

    // Tạo sẵn một số log hoàn thành trong 5 ngày gần đây để biểu đồ tuần và tháng hiển thị đẹp
    for (int i = 1; i <= 5; i++) {
      final pastDate = now.subtract(Duration(days: i));
      final dateStr = AppDateUtils.toIsoDate(pastDate);

      // Cho hoàn thành 3 hoặc 4 thói quen mỗi ngày
      final habitsToComplete = insertedIds.take((i % 2 == 0) ? 4 : 3);
      for (final habitId in habitsToComplete) {
        await db.insert('habit_logs', {
          'habit_id': habitId,
          'date': dateStr,
          'completed_at': pastDate.toIso8601String(),
        });
      }
    }
  }

  // ================= CRUD THÓI QUEN =================

  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toMap());
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(int id) async {
    final db = await database;
    // Bảng habit_logs có ON DELETE CASCADE, đồng thời xóa chủ động để an toàn
    await db.delete('habit_logs', where: 'habit_id = ?', whereArgs: [id]);
    return await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Habit>> getAllHabits() async {
    final db = await database;
    final maps = await db.query('habits', orderBy: 'id ASC');
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  Future<Habit?> getHabitById(int id) async {
    final db = await database;
    final maps = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  // ================= LOGS & HOÀN THÀNH =================

  /// Lấy danh sách ID thói quen đã hoàn thành trong ngày
  Future<Set<int>> getCompletedHabitIdsForDate(String dateStr) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      columns: ['habit_id'],
      where: 'date = ?',
      whereArgs: [dateStr],
    );
    return maps.map((m) => m['habit_id'] as int).toSet();
  }

  /// Bật / Tắt trạng thái hoàn thành của một thói quen trong một ngày
  Future<bool> toggleHabitCompletion(int habitId, String dateStr) async {
    final db = await database;
    final existing = await db.query(
      'habit_logs',
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, dateStr],
    );

    if (existing.isNotEmpty) {
      // Đã hoàn thành -> Hủy đánh dấu
      await db.delete(
        'habit_logs',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitId, dateStr],
      );
      return false;
    } else {
      // Chưa hoàn thành -> Đánh dấu hoàn thành
      await db.insert('habit_logs', {
        'habit_id': habitId,
        'date': dateStr,
        'completed_at': DateTime.now().toIso8601String(),
      });
      return true;
    }
  }

  /// Tính chuỗi ngày liên tiếp (Streak) của một thói quen
  Future<int> getStreakForHabit(int habitId) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      columns: ['date'],
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'date DESC',
    );

    if (maps.isEmpty) return 0;

    final dates = maps.map((m) => m['date'] as String).toSet();
    final today = AppDateUtils.stripTime(DateTime.now());
    final todayStr = AppDateUtils.toIsoDate(today);
    final yesterdayStr = AppDateUtils.toIsoDate(today.subtract(const Duration(days: 1)));

    // Chuỗi có thể bắt đầu từ hôm nay hoặc hôm qua
    DateTime checkDate;
    if (dates.contains(todayStr)) {
      checkDate = today;
    } else if (dates.contains(yesterdayStr)) {
      checkDate = today.subtract(const Duration(days: 1));
    } else {
      return 0;
    }

    int streak = 0;
    while (true) {
      final dateStr = AppDateUtils.toIsoDate(checkDate);
      if (dates.contains(dateStr)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  /// Lấy tất cả các log giữa 2 mốc ngày (Dùng tính thống kê tuần/tháng)
  Future<List<HabitLog>> getLogsBetweenDates(String startDateStr, String endDateStr) async {
    final db = await database;
    final maps = await db.query(
      'habit_logs',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDateStr, endDateStr],
    );
    return maps.map((m) => HabitLog.fromMap(m)).toList();
  }

  /// Đếm số lần hoàn thành của từng thói quen trong một khoảng thời gian
  Future<Map<int, int>> getCompletionCountsForPeriod(String startDateStr, String endDateStr) async {
    final db = await database;
    final results = await db.rawQuery('''
      SELECT habit_id, COUNT(*) as count
      FROM habit_logs
      WHERE date >= ? AND date <= ?
      GROUP BY habit_id
    ''', [startDateStr, endDateStr]);

    final map = <int, int>{};
    for (final row in results) {
      map[row['habit_id'] as int] = row['count'] as int;
    }
    return map;
  }
}
