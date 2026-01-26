import '../models/movie.dart';
import '../models/cinema.dart';
import '../models/showtime.dart';
import 'firestore_service.dart';

class PaymentLogic {
  final FirestoreService firestoreService;
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final List<String> selectedSeats;
  final int totalPrice;

  PaymentLogic({
    required this.firestoreService,
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.selectedSeats,
    required this.totalPrice,
  });

  // Tạo URL VNPay Sandbox để thanh toán qua WebView
  Future<String?> createVNPayUrl() async {
    try {
      // Trong thực tế, URL này nên gọi từ Backend để đảm bảo an toàn checksum
      // Ở đây giả lập URL Sandbox để bạn test quy trình thanh toán
      await Future.delayed(const Duration(seconds: 1));

      final String txnRef = DateTime.now().millisecondsSinceEpoch.toString();
      final String vnpUrl = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

      final Map<String, String> params = {
        "vnp_Version": "2.1.0",
        "vnp_Command": "pay",
        "vnp_TmnCode": "DEMO0001", // Mã test mặc định của VNPay
        "vnp_Amount": "${totalPrice * 100}", // VNPay yêu cầu nhân 100
        "vnp_CurrCode": "VND",
        "vnp_TxnRef": txnRef,
        "vnp_OrderInfo": "Thanh toan ve: ${movie.title}",
        "vnp_OrderType": "other",
        "vnp_Locale": "vn",
        "vnp_ReturnUrl": "https://success.sdk.vnpay.vn/", // URL để app bắt sự kiện thành công
      };

      final queryString = Uri(queryParameters: params).query;
      // Chú ý: Ở môi trường thật phải có SecureHash (checksum)
      return "$vnpUrl?$queryString&vnp_SecureHash=dummyhash123456";
    } catch (e) {
      return null;
    }
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}đ';
  }
}