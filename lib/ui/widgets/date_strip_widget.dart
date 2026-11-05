import 'package:flutter/material.dart';
import '../../utils/date_utils.dart';

class DateStripWidget extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  const DateStripWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  State<DateStripWidget> createState() => _DateStripWidgetState();
}

class _DateStripWidgetState extends State<DateStripWidget> {
  late final ScrollController _scrollController;
  late final List<DateTime> _days;
  final double _itemWidth = 56.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Tạo danh sách 14 ngày: 7 ngày trước và 6 ngày sau hôm nay
    _days = AppDateUtils.getRecentDays(DateTime.now(), daysBefore: 7, daysAfter: 6);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  void _scrollToSelectedDate() {
    if (!_scrollController.hasClients) return;
    final index = _days.indexWhere((d) => AppDateUtils.isSameDay(d, widget.selectedDate));
    if (index != -1) {
      final offset = (index * (_itemWidth + 8)) - (MediaQuery.of(context).size.width / 2) + (_itemWidth / 2);
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void didUpdateWidget(covariant DateStripWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!AppDateUtils.isSameDay(oldWidget.selectedDate, widget.selectedDate)) {
      _scrollToSelectedDate();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final date = _days[index];
          final isSelected = AppDateUtils.isSameDay(date, widget.selectedDate);
          final isToday = AppDateUtils.isToday(date);
          final weekdayStr = AppDateUtils.getShortWeekdayName(date);

          return GestureDetector(
            onTap: () => widget.onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _itemWidth,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : isToday
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : isToday
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0),
                  width: isSelected || isToday ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayStr,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.85)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Chấm tròn nhỏ biểu thị hôm nay
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? Colors.white
                          : isToday
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
