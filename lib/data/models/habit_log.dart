class HabitLog {
  final int? id;
  final int habitId;
  final String date; // YYYY-MM-DD
  final DateTime completedAt;

  const HabitLog({
    this.id,
    required this.habitId,
    required this.date,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'date': date,
      'completed_at': completedAt.toIso8601String(),
    };
  }

  factory HabitLog.fromMap(Map<String, dynamic> map) {
    return HabitLog(
      id: map['id'] as int?,
      habitId: map['habit_id'] as int,
      date: map['date'] as String,
      completedAt: DateTime.parse(map['completed_at'] as String),
    );
  }
}
