import 'package:flutter/material.dart';
import '../../data/models/habit_stats.dart';
import '../../utils/date_utils.dart';

class WeeklyBarChart extends StatelessWidget {
  final WeekStats weekStats;

  const WeeklyBarChart({
    super.key,
    required this.weekStats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biểu đồ tuần này',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tiến độ 7 ngày gần nhất',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Trung bình: ${weekStats.averagePercentage}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 7 Cột biểu đồ
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekStats.days.map((dayStat) {
                final isToday = AppDateUtils.isToday(dayStat.date);
                final rate = dayStat.rate.clamp(0.0, 1.0);
                final percent = dayStat.percentage;

                Color barColor;
                if (rate >= 1.0) {
                  barColor = const Color(0xFF10B981); // 100% xanh lá
                } else if (rate >= 0.5) {
                  barColor = theme.colorScheme.primary; // >50% teal
                } else if (rate > 0) {
                  barColor = const Color(0xFFF59E0B); // Amber
                } else {
                  barColor = const Color(0xFFCBD5E1); // 0% xám
                }

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Phần trăm hiển thị phía trên cột
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday
                              ? theme.colorScheme.primary
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Cột Bar Chart
                      Expanded(
                        child: Container(
                          width: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.bottomCenter,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final height = constraints.maxHeight * rate;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                width: 20,
                                height: height < 4 && rate > 0 ? 4 : height,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Nhãn Thứ
                      Text(
                        AppDateUtils.getShortWeekdayName(dayStat.date),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday
                              ? theme.colorScheme.primary
                              : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Ngày số (VD: 06)
                      Text(
                        '${dayStat.date.day}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isToday
                              ? theme.colorScheme.primary
                              : const Color(0xFF94A3B8),
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
