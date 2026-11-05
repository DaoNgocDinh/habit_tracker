import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/habit.dart';
import '../../providers/habit_provider.dart';
import '../theme/app_theme.dart';

class AddEditHabitScreen extends StatefulWidget {
  final Habit? habitToEdit;

  const AddEditHabitScreen({super.key, this.habitToEdit});

  @override
  State<AddEditHabitScreen> createState() => _AddEditHabitScreenState();
}

class _AddEditHabitScreenState extends State<AddEditHabitScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late String _selectedFrequency;
  late TimeOfDay _reminderTime;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isSaving = false;

  bool get _isEditing => widget.habitToEdit != null;

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _descController = TextEditingController(text: h?.description ?? '');
    _selectedFrequency = h?.frequency ?? 'daily';
    _reminderTime = h != null
        ? TimeOfDay(hour: h.reminderHour, minute: h.reminderMinute)
        : const TimeOfDay(hour: 7, minute: 0);
    _selectedColor = h != null ? h.color : AppTheme.habitColorOptions.first;
    _selectedIcon = h != null ? h.icon : AppTheme.habitIconOptions.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  Future<void> _saveHabit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final provider = context.read<HabitProvider>();
    final habit = Habit(
      id: widget.habitToEdit?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      frequency: _selectedFrequency,
      reminderHour: _reminderTime.hour,
      reminderMinute: _reminderTime.minute,
      colorValue: _selectedColor.toARGB32(),
      iconCodePoint: _selectedIcon.codePoint,
      createdAt: widget.habitToEdit?.createdAt ?? DateTime.now(),
    );

    try {
      if (_isEditing) {
        await provider.updateHabit(habit);
      } else {
        await provider.addHabit(habit);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Đã cập nhật thói quen thành công!'
                : 'Đã thêm thói quen mới thành công!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Có lỗi xảy ra: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa thói quen' : 'Thêm thói quen mới'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _isSaving ? null : _saveHabit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 20),
              label: const Text('Lưu'),
              style: TextButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Xem trước Icon & Màu sắc
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _selectedColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedColor, width: 2),
                ),
                child: Icon(_selectedIcon, size: 36, color: _selectedColor),
              ),
            ),
            const SizedBox(height: 24),

            // Tên thói quen
            const Text(
              'Tên thói quen *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'VD: Dậy sớm lúc 06:00, Đọc sách, Tập thể dục...',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Vui lòng nhập tên thói quen';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),

            // Mô tả
            const Text(
              'Mô tả / Mục tiêu rèn luyện',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: 'Lý do rèn luyện hoặc chi tiết thực hiện...',
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 24),
                  child: Icon(Icons.description_outlined),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Tần suất rèn luyện
            const Text(
              'Tần suất thực hiện *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: const [
                    DropdownMenuItem(
                      value: 'daily',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, size: 18, color: Color(0xFF0F766E)),
                          SizedBox(width: 10),
                          Text('Hàng ngày (Cả tuần)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'weekdays',
                      child: Row(
                        children: [
                          Icon(Icons.work_outline, size: 18, color: Color(0xFF2563EB)),
                          SizedBox(width: 10),
                          Text('Ngày trong tuần (Thứ 2 - Thứ 6)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'weekends',
                      child: Row(
                        children: [
                          Icon(Icons.weekend_outlined, size: 18, color: Color(0xFFEA580C)),
                          SizedBox(width: 10),
                          Text('Cuối tuần (Thứ 7 & Chủ Nhật)'),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedFrequency = val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Giờ nhắc nhở
            const Text(
              'Thời gian nhắc nhở *',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickReminderTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF0F766E)),
                    const SizedBox(width: 12),
                    Text(
                      '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Đổi giờ',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F766E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF0F766E)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Chọn biểu tượng
            const Text(
              'Chọn biểu tượng',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: AppTheme.habitIconOptions.map((icon) {
                final isSelected = _selectedIcon.codePoint == icon.codePoint;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = icon),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _selectedColor.withValues(alpha: 0.2)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? _selectedColor : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isSelected ? _selectedColor : const Color(0xFF64748B),
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),

            // Chọn màu sắc
            const Text(
              'Chọn màu sắc',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 14,
              runSpacing: 12,
              children: AppTheme.habitColorOptions.map((color) {
                final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 36),

            // Nút Lưu chính
            ElevatedButton(
              onPressed: _isSaving ? null : _saveHabit,
              child: Text(_isEditing ? 'CẬP NHẬT THÓI QUEN' : 'TẠO THÓI QUEN MỚI'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
