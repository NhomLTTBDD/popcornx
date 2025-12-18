PopcornX – Movie Ticket Booking App (Flutter)
1. Giới thiệu dự án
PopcornX là ứng dụng đặt vé xem phim đa nền tảng được phát triển bằng Flutter, mô phỏng hệ thống bán vé của các rạp phim như CGV, BHD, Galaxy.
Luồng sử dụng chính của app:
Xem phim → Chọn rạp → Chọn suất chiếu → Chọn ghế → Thanh toán → Nhận vé điện tử (QR)
Dự án được xây dựng nhằm:
Áp dụng kiến thức Flutter + Firebase/Backend vào sản phẩm thực tế
Rèn kỹ năng làm việc nhóm, quản lý source code bằng GitHub
Tạo ra một ứng dụng có giao diện đẹp, mượt, dễ sử dụng

2. Công nghệ sử dụng

Flutter: xây dựng UI & logic ứng dụng
Firebase Authentication: đăng nhập / đăng ký
Firebase Firestore: lưu trữ dữ liệu phim, suất chiếu, vé
Firebase Storage: lưu trữ hình ảnh poster phim
GitHub: quản lý source code

3. Tính năng chính
3.1. Dành cho người dùng
🔐 Xác thực
Đăng ký / Đăng nhập bằng Email & Password
Đăng nhập nhanh bằng Google (Firebase Auth)

🎞️ Xem danh sách phim
Phim đang chiếu
Phim sắp chiếu
Lọc phim theo thể loại

📄 Chi tiết phim
Tên phim
Poster
Thời lượng
Đạo diễn, diễn viên
Mô tả nội dung
Trailer (YouTube Player)

🏢 Chọn rạp & suất chiếu
Danh sách rạp (CGV, BHD, Galaxy – mock data)
Địa chỉ rạp
Phòng chiếu
Lịch chiếu theo ngày
Giờ chiếu tương ứng

💺 Chọn ghế (Seat Booking)
Sơ đồ ghế từ A–F, số 1–12
Trạng thái ghế:
Trống
Đã đặt
Đang chọn
Tự động tính tổng tiền theo loại ghế

💳 Thanh toán (Demo)
Thanh toán mô phỏng
Hiển thị đầy đủ:
Phim
Rạp
Suất chiếu
Ghế
Tổng tiền

🎟️ Vé điện tử
Xuất vé sau khi thanh toán
Mã QR
Thông tin vé đầy đủ
Lưu vé vào mục “Vé của tôi”

📜 Lịch sử đặt vé
Xem danh sách các vé đã đặt
Xem lại mã QR của vé cũ

👤 Trang cá nhân
Đổi avatar
Cập nhật tên, email

4. Tính năng Admin (Optional – tăng điểm)
Quản lý phim (thêm / sửa / xóa)
Quản lý lịch chiếu
Quản lý vé
Upload poster phim lên Firebase Storage