# BÁO CÁO DỰ ÁN: ỨNG DỤNG RÈN LUYỆN KỶ LUẬT CÁ NHÂN (HABIT TRACKER)

---

## I. TỔNG QUAN DỰ ÁN
- **Tên dự án:** Habit Discipline Tracker (Ứng dụng Rèn luyện Kỷ luật Cá nhân)
- **Nền tảng phát triển:** Flutter 3.x / Dart 3.x
- **Cơ sở dữ liệu cục bộ:** SQLite (`sqflite`, `sqflite_common_ffi`, `sqlite3_flutter_libs`)
- **Quản lý trạng thái (State Management):** `Provider` (`ChangeNotifier`)
- **Giao diện thiết kế:** Material 3, phong cách trực quan, hiện đại, tối ưu trải nghiệm người dùng (UX/UI).

---

## II. ĐỐI CHIẾU VỚI CHECKLIST ĐÁNH GIÁ (5 MỤC)

| STT | Yêu cầu Checklist | Trạng thái | Vị trí triển khai trong mã nguồn |
|:---:|:---|:---:|:---|
| **1** | **Thiết kế giao diện người dùng** đầy đủ 3 màn hình: Danh sách thói quen, Thêm/sửa thói quen, Thống kê tiến độ. | **HOÀN THÀNH 100%** | - `lib/ui/screens/home_screen.dart`<br>- `lib/ui/screens/habit_list_screen.dart`<br>- `lib/ui/screens/add_edit_habit_screen.dart`<br>- `lib/ui/screens/statistics_screen.dart` |
| **2** | **Cài đặt tính năng Thêm, Xóa, Sửa thói quen** với đầy đủ thuộc tính: Tên, mô tả, tần suất, thời gian nhắc nhở (kèm biểu tượng & màu sắc). | **HOÀN THÀNH 100%** | - `lib/data/models/habit.dart`<br>- `lib/ui/screens/add_edit_habit_screen.dart`<br>- `lib/data/database/app_database.dart` |
| **3** | **Triển khai hệ thống đánh dấu hoàn thành hàng ngày** với giao diện trực quan, tương tác mượt mà, hiển thị chuỗi ngày (Streak 🔥). | **HOÀN THÀNH 100%** | - `lib/ui/widgets/habit_card.dart`<br>- `lib/ui/widgets/date_strip_widget.dart`<br>- `lib/data/models/habit_log.dart` |
| **4** | **Lưu trữ dữ liệu bằng SQLite** (bền vững, không mất khi tắt app, hỗ trợ cả Android, iOS và Windows Desktop). | **HOÀN THÀNH 100%** | - `lib/data/database/app_database.dart`<br>- Cơ chế Seed Data mẫu ban đầu tự động |
| **5** | **Màn hình thống kê hiển thị tỷ lệ hoàn thành theo Ngày, Tuần và Tháng** kèm biểu đồ cột và lịch heatmap. | **HOÀN THÀNH 100%** | - `lib/ui/screens/statistics_screen.dart`<br>- `lib/ui/widgets/weekly_bar_chart.dart`<br>- `lib/data/models/habit_stats.dart` |

---

## III. CẤU TRÚC THƯ MỤC DỰ ÁN

```text
habit_tracker/
├── lib/
│   ├── data/
│   │   ├── database/
│   │   │   └── app_database.dart       # Quản lý SQLite: Tạo bảng, Seed Data, CRUD, tính Streak
│   │   └── models/
│   │       ├── habit.dart              # Model thói quen (Tên, mô tả, tần suất, giờ nhắc, màu, icon)
│   │       ├── habit_log.dart          # Model lịch sử đánh dấu hoàn thành theo ngày (YYYY-MM-DD)
│   │       └── habit_stats.dart        # Model tính toán thống kê Ngày, Tuần, Tháng
│   ├── providers/
│   │   └── habit_provider.dart         # Provider quản lý State toàn cục ứng dụng
│   ├── ui/
│   │   ├── screens/
│   │   │   ├── home_screen.dart            # Màn hình chính chứa NavigationBar (Thói quen & Thống kê)
│   │   │   ├── habit_list_screen.dart      # Danh sách thói quen, Date Strip, Bộ lọc, Thanh tiến độ
│   │   │   ├── add_edit_habit_screen.dart  # Form Thêm/Sửa thói quen, TimePicker, Color/Icon Picker
│   │   │   └── statistics_screen.dart      # Thống kê tiến độ theo Ngày, Tuần, Tháng
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Định nghĩa Theme Material 3, bảng màu Teal kỷ luật
│   │   └── widgets/
│   │       ├── date_strip_widget.dart  # Thanh cuộn chọn ngày trực quan (T2 -> CN)
│   │       ├── habit_card.dart         # Card thói quen, nút check tròn animated, menu Sửa/Xóa
│   │       ├── weekly_bar_chart.dart   # Biểu đồ cột tùy biến hiển thị tiến độ 7 ngày trong tuần
│   │       └── empty_state_widget.dart # Giao diện khi danh sách thói quen rỗng
│   ├── utils/
│   │   └── date_utils.dart             # Xử lý chuẩn hóa ngày tháng, tên thứ tiếng Việt
│   └── main.dart                       # Điểm khởi chạy ứng dụng, cấu hình FFI cho Desktop/Mobile
└── test/
    └── widget_test.dart                # Bộ kiểm thử tự động (Unit test Model & Thống kê)
```

---

## IV. CHI TIẾT KỸ THUẬT VÀ TÍNH NĂNG NỔI BẬT

### 1. Cơ sở dữ liệu SQLite (`app_database.dart`)
- **Bảng `habits`**: Lưu trữ thông tin thói quen (tên, mô tả, tần suất `daily`/`weekdays`/`weekends`, giờ phút nhắc nhở, màu sắc, icon, ngày tạo).
- **Bảng `habit_logs`**: Lưu nhật ký hoàn thành thói quen với cặp khóa `(habit_id, date)` duy nhất. Có khóa ngoại `FOREIGN KEY(habit_id) REFERENCES habits(id) ON DELETE CASCADE`.
- **Dữ liệu mẫu (Seeded Data)**: Khi vừa cài đặt và mở app, hệ thống tự động khởi tạo sẵn các thói quen kỷ luật kinh điển (Dậy sớm 06:00, Tập thể dục 30p, Đọc sách, Uống 2L nước, Lập kế hoạch ngày mai) cùng lịch sử hoàn thành một số ngày gần nhất, giúp giáo viên/người chấm bài trải nghiệm ngay biểu đồ mà không mất thời gian nhập thủ công.
- **Tương thích đa nền tảng**: Tích hợp `sqflite_common_ffi` giúp ứng dụng có thể chạy và chấm điểm trực tiếp trên máy Windows (`flutter run -d windows`) cũng như trên giả lập/điện thoại Android/iOS.

### 2. Quản lý Thói quen (CRUD)
- **Thêm mới**: Nút FAB nổi bật ở màn hình chính, kiểm tra tính hợp lệ của Form (bắt buộc nhập tên thói quen, chọn tần suất, chọn giờ nhắc bằng `showTimePicker`, chọn icon và bảng màu trực quan).
- **Chỉnh sửa**: Menu 3 chấm trên từng thẻ thói quen -> "Chỉnh sửa" -> Nạp sẵn dữ liệu cũ vào Form để sửa đổi.
- **Xóa an toàn**: Menu 3 chấm -> "Xóa" -> Hiển thị `AlertDialog` xác nhận để tránh người dùng bấm nhầm.

### 3. Đánh dấu hoàn thành hàng ngày
- Nút Checkmark hình tròn lớn chuyển sang màu xanh lá sinh động khi bấm hoàn thành.
- Tên thói quen có hiệu ứng gạch ngang (`lineThrough`) và chuyển màu nhẹ nhàng.
- Hiển thị huy hiệu ngọn lửa chuỗi ngày (Streak 🔥) tăng dần khi hoàn thành liên tiếp.
- Thanh ngày (`DateStripWidget`) cho phép lướt qua các ngày trong tuần để xem lại hoặc bù tiến độ.

### 4. Hệ thống thống kê chuyên sâu (`StatisticsScreen`)
- **Theo Ngày**:
  - Đồng hồ tiến độ tròn (`CircularProgressIndicator`) hiển thị % hoàn thành trong ngày.
  - Các thẻ đếm: Tổng số, Đã xong, Còn lại.
  - Lời khuyên/nhận xét động theo phong độ kỷ luật hàng ngày.
- **Theo Tuần**:
  - Biểu đồ cột 7 ngày (`WeeklyBarChart`) hiển thị % hoàn thành từ Thứ 2 đến Chủ Nhật.
  - Tỷ lệ trung bình toàn tuần và tổng số lượt hoàn thành.
  - Tôn vinh "Ngày kỷ luật tốt nhất tuần".
- **Theo Tháng**:
  - Tỷ lệ hoàn thành trung bình tháng.
  - Đếm số "Ngày kỷ luật hoàn hảo" (đạt 100% mục tiêu).
  - Tuyên dương "Thói quen kiên trì nhất tháng".
  - Bản đồ lịch chấm điểm dạng lưới (Calendar Heatmap Grid) phủ màu theo tỷ lệ từng ngày.
  - Thanh tiến độ riêng cho từng thói quen cụ thể để người dùng biết điểm mạnh/yếu của mình.

---

## V. HƯỚNG DẪN CHẠY VÀ KIỂM THỬ

1. Chuyển vào thư mục dự án:
   ```bash
   cd habit_tracker
   ```
2. Chạy ứng dụng trên Windows (khởi chạy ngay trên máy tính mà không cần emulator):
   ```bash
   flutter run -d windows
   ```
3. Hoặc chạy trên thiết bị Android / iOS:
   ```bash
   flutter run
   ```
4. Chạy kiểm thử tự động (Unit Test):
   ```bash
   flutter test
   ```
5. Kiểm tra chất lượng mã nguồn:
   ```bash
   dart analyze
   # Kết quả: No issues found! (0 lỗi, 0 cảnh báo)
   ```
