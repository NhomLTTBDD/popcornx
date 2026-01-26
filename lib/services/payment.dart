import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../models/cinema.dart';
import '../models/showtime.dart';
import 'firestore_service.dart';

class PaymentResult {
  final bool success;
  final String? bookingId;
  final String? errorMessage;

  PaymentResult.success(this.bookingId)
      : success = true,
        errorMessage = null;

  PaymentResult.failure(this.errorMessage)
      : success = false,
        bookingId = null;
}

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

  bool checkUserLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  Future<PaymentResult> processPayment() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return PaymentResult.failure('Vui lòng đăng nhập để đặt vé');
      }

      final bookingId = await firestoreService.createBooking(
        userId: user.uid,
        movieId: movie.id,
        cinemaId: cinema.id,
        showtimeId: showtime.id,
        seats: selectedSeats,
        totalPrice: totalPrice,
        status: 'paid', // Đặt status là 'paid' ngay khi tạo booking
      );

      if (bookingId.isEmpty) {
        return PaymentResult.failure('Thanh toán thất bại');
      }

      return PaymentResult.success(bookingId);
    } catch (e) {
      return PaymentResult.failure('Có lỗi xảy ra. Vui lòng thử lại.');
    }
  }

  String formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        )}đ';
  }
}