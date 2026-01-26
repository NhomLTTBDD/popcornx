// File này chứa logic xử lý cho màn hình chọn ghế
// Tách file này ra để tách biệt logic và UI, code dễ đọc hơn

import 'package:baitapthuchanh/services/firestore_service.dart';

// Class chứa các hàm logic cho màn hình chọn ghế
class SeatSelectionLogic {
  // Service để lấy dữ liệu từ Firestore
  final FirestoreService firestoreService;
  // ID của showtime
  final String showtimeId;
  // Giá vé cố định: 60.000đ / ghế
  static const int ticketPrice = 60000;

  SeatSelectionLogic({
    required this.firestoreService,
    required this.showtimeId,
  });

  Future<List<String>> loadBookedSeats() async {
    final booked = await firestoreService.getBookedSeats(showtimeId);
    
    final bookedList = booked.toList();
    
    return bookedList;
  }

  bool isSeatBooked(String seatId, List<String> bookedSeats) {
    if (bookedSeats.contains(seatId)) {
      return true;
    } else {
      return false;
    }
  }

  bool isSeatSelected(String seatId, List<String> selectedSeats) {
    if (selectedSeats.contains(seatId)) {
      return true;
    } else {
      return false;
    }
  }

  void addSeatToList(String seatId, List<String> selectedSeats) {
    selectedSeats.add(seatId);
  }

  void removeSeatFromList(String seatId, List<String> selectedSeats) {
    selectedSeats.remove(seatId);
  }

  int calculateTotalPrice(int seatCount) {
    return seatCount * ticketPrice;
  }

  bool hasSelectedSeats(List<String> selectedSeats) {
    if (selectedSeats.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  // Hàm tạo danh sách ghế: A1-A10, B1-B10, ..., F1-F10
  List<String> generateSeatList() {
    // Danh sách để lưu các ghế
    final seats = <String>[];
    
    // Tạo 6 hàng (A-F)
    for (int row = 0; row < 6; row++) {
      // Chuyển số thành chữ cái (65 là mã ASCII của 'A')
      final rowLetter = String.fromCharCode(65 + row);
      
      // Tạo 10 cột (1-10)
      for (int col = 1; col <= 10; col++) {
        // Tạo ID ghế (ví dụ: A1, A2, B3...)
        final seatId = '$rowLetter$col';
        // Thêm vào danh sách
        seats.add(seatId);
      }
    }
    
    // Trả về danh sách
    return seats;
  }

  // Hàm format giá tiền
  // Chuyển đổi số thành chuỗi có dấu phẩy ngăn cách hàng nghìn
  String formatPrice(int price) {
    // Bước 1: Chuyển số thành chuỗi (không có số thập phân)
    final priceString = price.toStringAsFixed(0);
    
    // Bước 2: Thêm dấu phẩy ngăn cách hàng nghìn
    final formattedPrice = priceString.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) {
        return '${m[1]},';
      },
    );
    
    // Bước 3: Thêm chữ "đ" ở cuối
    return '$formattedPriceđ';
  }
}
