# Habit Discipline Tracker (Ứng dụng Kỷ luật Cá nhân)

Ứng dụng Flutter giúp theo dõi và quản lý thói quen hàng ngày nhằm rèn luyện kỷ luật cá nhân, lưu trữ bền vững với SQLite và hệ thống thống kê trực quan.

## Tính năng chính

- **Quản lý thói quen**: Thêm, xóa (có xác nhận), sửa với các trường tên, mô tả, tần suất (hàng ngày, ngày làm việc, cuối tuần), giờ nhắc nhở, màu sắc và biểu tượng.
- **Đánh dấu hoàn thành trực quan**: Nút checkmark chuyển màu sinh động, hiệu ứng hoàn thành, bộ đếm chuỗi ngày liên tiếp (Streak 🔥).
- **Bộ chọn ngày thông minh**: Dải ngày ngang cuộn mượt mà để xem lại hoặc đánh dấu cho các ngày khác nhau.
- **Lưu trữ SQLite**: Sử dụng `sqflite` và `sqflite_common_ffi` (chạy hoàn hảo trên cả Android, iOS và Windows Desktop). Có sẵn dữ liệu mẫu khi cài đặt.
- **Thống kê chuyên sâu**:
  - **Theo Ngày**: Đồng hồ tròn tỷ lệ %, số lượng đã xong/còn lại, lời nhận xét kỷ luật.
  - **Theo Tuần**: Biểu đồ cột 7 ngày trực quan (T2 - CN), tỷ lệ trung bình, ngày tốt nhất.
  - **Theo Tháng**: Tỷ lệ trung bình tháng, số ngày đạt 100%, bản đồ nhiệt (Heatmap calendar grid), tỷ lệ chi tiết từng thói quen.

## Hướng dẫn chạy

```bash
# 1. Chạy trên Windows Desktop:
flutter run -d windows

# 2. Chạy trên Android/iOS:
flutter run

# 3. Chạy kiểm thử tự động:
flutter test

# 4. Phân tích mã nguồn:
dart analyze
```
