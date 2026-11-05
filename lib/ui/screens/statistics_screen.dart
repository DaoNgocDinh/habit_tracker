import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../utils/date_utils.dart';
import '../widgets/weekly_bar_chart.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<HabitProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê tiến độ'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Theo Ngày'),
                Tab(text: 'Theo Tuần'),
                Tab(text: 'Theo Tháng'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDayTab(context, provider),
          _buildWeekTab(context, provider),
          _buildMonthTab(context, provider),
        ],
      ),
    );
  }

  // ================= TAB 1: THỐNG KÊ NGÀY =================
  Widget _buildDayTab(BuildContext context, HabitProvider provider) {
    final theme = Theme.of(context);
    final dayStats = provider.currentDayStats;
    final habits = provider.habitsForSelectedDate;
    final rate = dayStats.rate;
    final percentage = dayStats.percentage;

    String feedbackText;
    Color feedbackColor;
    if (dayStats.isPerfect) {
      feedbackText = 'Xuất sắc! Bạn đã hoàn thành 100% mục tiêu hôm nay. Hãy giữ vững kỷ luật này!';
      feedbackColor = const Color(0xFF10B981);
    } else if (rate >= 0.5) {
      feedbackText = 'Khởi đầu tốt! Bạn đã đạt hơn một nửa số mục tiêu. Hãy hoàn thành các mục còn lại!';
      feedbackColor = theme.colorScheme.primary;
    } else {
      feedbackText = 'Mỗi ngày là một cơ hội mới. Hãy bắt đầu từ việc nhỏ nhất để xây dựng kỷ luật!';
      feedbackColor = const Color(0xFFEA580C);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Thẻ tỷ lệ hoàn thành tròn
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Tiến độ ngày ${AppDateUtils.formatShortDate(dayStats.date)}',
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: rate,
                        strokeWidth: 12,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          dayStats.isPerfect ? const Color(0xFF10B981) : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: dayStats.isPerfect ? const Color(0xFF10B981) : theme.colorScheme.primary,
                          ),
                        ),
                        const Text(
                          'Hoàn thành',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Nhận xét truyền cảm hứng
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: feedbackColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  feedbackText,
                  style: TextStyle(
                    fontSize: 13,
                    color: feedbackColor,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3 Thẻ thống kê số lượng
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tổng số',
                value: '${dayStats.totalHabits}',
                icon: Icons.checklist,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Đã xong',
                value: '${dayStats.completedHabits}',
                icon: Icons.check_circle_outline,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Còn lại',
                value: '${dayStats.totalHabits - dayStats.completedHabits}',
                icon: Icons.pending_actions,
                color: const Color(0xFFEA580C),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Danh sách thói quen hôm nay và trạng thái
        const Text(
          'Chi tiết các thói quen trong ngày',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        ...habits.map((habit) {
          final isDone = provider.isHabitCompleted(habit.id!);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(
                  isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isDone ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    habit.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDone ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                Text(
                  habit.reminderTimeString,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= TAB 2: THỐNG KÊ TUẦN =================
  Widget _buildWeekTab(BuildContext context, HabitProvider provider) {
    final weekStats = provider.weekStats;
    if (weekStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final bestDay = weekStats.bestDay;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Biểu đồ cột tuần trực quan
        WeeklyBarChart(weekStats: weekStats),
        const SizedBox(height: 16),

        // Các chỉ số tổng quan tuần
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tỷ lệ trung bình',
                value: '${weekStats.averagePercentage}%',
                icon: Icons.pie_chart_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Lượt hoàn thành',
                value: '${weekStats.totalCompletedHabits}',
                icon: Icons.task_alt,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Ngày tốt nhất trong tuần
        if (bestDay != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.emoji_events, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ngày kỷ luật tốt nhất tuần',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppDateUtils.getFullWeekdayName(bestDay.date)} (${AppDateUtils.formatShortDate(bestDay.date)})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${bestDay.percentage}%',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ================= TAB 3: THỐNG KÊ THÁNG =================
  Widget _buildMonthTab(BuildContext context, HabitProvider provider) {
    final monthStats = provider.monthStats;
    if (monthStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final topHabit = monthStats.topHabit;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tổng quan tháng
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Tỷ lệ tháng',
                value: '${monthStats.averagePercentage}%',
                icon: Icons.calendar_month,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                title: 'Ngày đạt 100%',
                value: '${monthStats.perfectDaysCount} ngày',
                icon: Icons.star_outline,
                color: const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Thói quen rèn luyện kiên trì nhất tháng
        if (topHabit != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: topHabit.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(topHabit.icon, color: topHabit.color, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thói quen kiên trì nhất tháng',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        topHabit.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${monthStats.habitCompletionCounts[topHabit.id] ?? 0} lần',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFEA580C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // Heatmap/Grid lịch chấm điểm các ngày trong tháng
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bản đồ rèn luyện Tháng ${monthStats.month}/${monthStats.year}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Màu sắc thể hiện mức độ hoàn thành mục tiêu từng ngày',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Grid các ngày
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: monthStats.days.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final dayStat = monthStats.days[index];
                  final rate = dayStat.rate;

                  Color cellColor;
                  Color textColor;
                  if (rate >= 1.0) {
                    cellColor = const Color(0xFF10B981); // 100% xanh lá
                    textColor = Colors.white;
                  } else if (rate >= 0.5) {
                    cellColor = theme.colorScheme.primary.withValues(alpha: 0.7);
                    textColor = Colors.white;
                  } else if (rate > 0) {
                    cellColor = const Color(0xFFFDE68A);
                    textColor = const Color(0xFF92400E);
                  } else {
                    cellColor = const Color(0xFFF1F5F9);
                    textColor = const Color(0xFF94A3B8);
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: cellColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${dayStat.date.day}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tỷ lệ hoàn thành từng thói quen cụ thể
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hiệu suất từng thói quen trong tháng',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ...monthStats.activeHabits.map((habit) {
                final completedTimes = monthStats.habitCompletionCounts[habit.id] ?? 0;
                // Ước tính số ngày thói quen đó áp dụng trong tháng
                final daysInMonth = monthStats.days.where((d) => habit.appliesToDate(d.date)).length;
                final habitRate = daysInMonth > 0 ? (completedTimes / daysInMonth).clamp(0.0, 1.0) : 0.0;
                final habitPercent = (habitRate * 100).round();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(habit.icon, size: 16, color: habit.color),
                              const SizedBox(width: 8),
                              Text(
                                habit.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$completedTimes/$daysInMonth ngày ($habitPercent%)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: habitRate,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFF1F5F9),
                          valueColor: AlwaysStoppedAnimation<Color>(habit.color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
