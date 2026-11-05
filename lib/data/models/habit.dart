import 'package:flutter/material.dart';

class Habit {
  final int? id;
  final String title;
  final String description;
  final String frequency; // 'daily', 'weekdays', 'weekends'
  final int reminderHour;
  final int reminderMinute;
  final int colorValue;
  final int iconCodePoint;
  final DateTime createdAt;

  const Habit({
    this.id,
    required this.title,
    this.description = '',
    required this.frequency,
    required this.reminderHour,
    required this.reminderMinute,
    required this.colorValue,
    required this.iconCodePoint,
    required this.createdAt,
  });

  /// Chuyển đổi thành Map để lưu vào SQLite
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'frequency': frequency,
      'reminder_hour': reminderHour,
      'reminder_minute': reminderMinute,
      'color_value': colorValue,
      'icon_code_point': iconCodePoint,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Khởi tạo Habit từ Map đọc từ SQLite
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: (map['description'] as String?) ?? '',
      frequency: map['frequency'] as String,
      reminderHour: map['reminder_hour'] as int,
      reminderMinute: map['reminder_minute'] as int,
      colorValue: map['color_value'] as int,
      iconCodePoint: map['icon_code_point'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Chuỗi hiển thị giờ nhắc nhở (Định dạng HH:mm)
  String get reminderTimeString {
    final hourStr = reminderHour.toString().padLeft(2, '0');
    final minuteStr = reminderMinute.toString().padLeft(2, '0');
    return '$hourStr:$minuteStr';
  }

  /// Hiển thị tần suất bằng tiếng Việt
  String get frequencyLabel {
    switch (frequency) {
      case 'weekdays':
        return 'Thứ 2 - Thứ 6';
      case 'weekends':
        return 'Thứ 7 & CN';
      case 'daily':
      default:
        return 'Hàng ngày';
    }
  }

  /// Kiểm tra xem thói quen có áp dụng cho một ngày cụ thể hay không
  bool appliesToDate(DateTime date) {
    if (frequency == 'daily') return true;
    final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
    if (frequency == 'weekdays') return !isWeekend;
    if (frequency == 'weekends') return isWeekend;
    return true;
  }

  Color get color => Color(colorValue);

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Habit copyWith({
    int? id,
    String? title,
    String? description,
    String? frequency,
    int? reminderHour,
    int? reminderMinute,
    int? colorValue,
    int? iconCodePoint,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      frequency: frequency ?? this.frequency,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
