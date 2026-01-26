import 'package:baitapthuchanh/models/booking.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Class chứa các hàm logic cho màn hình vé đã mua
class MyTicketsLogic {
  // Service để lấy dữ liệu từ Firestore
  final FirestoreService firestoreService;

  MyTicketsLogic({
    required this.firestoreService,
  });

  // Hàm kiểm tra user có đăng nhập không
  bool checkUserLoggedIn() {
    // Lấy user hiện tại
    final user = FirebaseAuth.instance.currentUser;
    // Nếu user khác null thì đã đăng nhập
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  // Hàm lấy user ID
  String? getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  // Hàm lấy stream danh sách bookings của user
  // Stream này sẽ tự động cập nhật khi có thay đổi trong Firestore
  Stream<List<Booking>> getUserBookingsStream() {
    // Bước 1: Lấy user ID
    final userId = getUserId();
    
    // Bước 2: Kiểm tra có user ID không
    if (userId == null) {
      // Không có user thì trả về stream rỗng
      return Stream.value([]);
    }

    // Bước 3: Lấy stream bookings từ Firestore
    return firestoreService.getUserBookingsStream(userId);
  }

  // Hàm format ngày tháng
  // Chuyển đổi DateTime thành chuỗi dạng dd/MM/yyyy
  String formatDate(DateTime? date) {
    // Kiểm tra date có null không
    if (date == null) {
      return 'N/A';
    }
    
    // Lấy ngày
    final day = date.day;
    // Lấy tháng
    final month = date.month;
    // Lấy năm
    final year = date.year;
    
    // Trả về chuỗi định dạng
    return '$day/$month/$year';
  }
}
