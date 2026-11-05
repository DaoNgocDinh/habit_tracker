import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../utils/date_utils.dart';
import '../widgets/date_strip_widget.dart';
import '../widgets/habit_card.dart';
import '../widgets/empty_state_widget.dart';
import 'add_edit_habit_screen.dart';

class HabitListScreen extends StatelessWidget {
  const HabitListScreen({super.key});

  void _confirmDeleteHabit(BuildContext context, int habitId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thói quen "$title"? Toàn bộ lịch sử hoàn thành cũng sẽ bị xóa.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<HabitProvider>().deleteHabit(habitId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa thói quen.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HabitProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final selectedDate = provider.selectedDate;
    final dayStats = provider.currentDayStats;
    final filteredHabits = provider.filteredHabits;
    final isToday = AppDateUtils.isToday(selectedDate);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header: Ngày và Thanh tiến độ hoàn thành trong ngày
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isToday ? 'Hôm nay' : AppDateUtils.getFullWeekdayName(selectedDate),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.formatFullDate(selectedDate),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      // Badge Tỷ lệ hoàn thành
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: dayStats.isPerfect
                              ? const Color(0xFF10B981).withValues(alpha: 0.12)
                              : theme.colorScheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: dayStats.isPerfect
                                ? const Color(0xFF10B981)
                                : theme.colorScheme.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              dayStats.isPerfect ? Icons.check_circle : Icons.trending_up,
                              size: 18,
                              color: dayStats.isPerfect
                                  ? const Color(0xFF10B981)
                                  : theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${dayStats.percentage}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: dayStats.isPerfect
                                    ? const Color(0xFF10B981)
                                    : theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Thanh tiến độ trực quan
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: dayStats.rate,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        dayStats.isPerfect
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Đã hoàn thành ${dayStats.completedHabits}/${dayStats.totalHabits} thói quen',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),

            // Thanh chọn ngày ngang (Date Strip)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  DateStripWidget(
                    selectedDate: selectedDate,
                    onDateSelected: (date) => provider.setSelectedDate(date),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ],
              ),
            ),

            // Bộ lọc: Tất cả | Chưa xong | Đã xong
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _buildFilterChip(context, label: 'Tất cả', filterKey: 'all', count: provider.habitsForSelectedDate.length),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Chưa xong',
                    filterKey: 'pending',
                    count: provider.habitsForSelectedDate.where((h) => !provider.isHabitCompleted(h.id!)).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    context,
                    label: 'Đã xong',
                    filterKey: 'completed',
                    count: provider.habitsForSelectedDate.where((h) => provider.isHabitCompleted(h.id!)).length,
                  ),
                ],
              ),
            ),

            // Danh sách thói quen
            Expanded(
              child: filteredHabits.isEmpty
                  ? EmptyStateWidget(
                      title: provider.habits.isEmpty
                          ? 'Chưa có thói quen nào'
                          : 'Không có thói quen phù hợp',
                      message: provider.habits.isEmpty
                          ? 'Hãy tạo thói quen đầu tiên để bắt đầu hành trình rèn luyện kỷ luật bản thân!'
                          : 'Không có thói quen nào trong danh mục lọc hiện tại.',
                      actionLabel: provider.habits.isEmpty ? 'Tạo thói quen ngay' : null,
                      onAction: provider.habits.isEmpty
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AddEditHabitScreen(),
                                ),
                              );
                            }
                          : null,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 80),
                      itemCount: filteredHabits.length,
                      itemBuilder: (context, index) {
                        final habit = filteredHabits[index];
                        final isCompleted = provider.isHabitCompleted(habit.id!);
                        final streak = provider.getStreak(habit.id!);

                        return HabitCard(
                          habit: habit,
                          isCompleted: isCompleted,
                          streak: streak,
                          onToggle: () => provider.toggleHabitCompletion(habit.id!),
                          onEdit: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditHabitScreen(habitToEdit: habit),
                              ),
                            );
                          },
                          onDelete: () => _confirmDeleteHabit(context, habit.id!, habit.title),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String filterKey,
    required int count,
  }) {
    final provider = context.watch<HabitProvider>();
    final isSelected = provider.currentFilter == filterKey;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => provider.setFilter(filterKey),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
