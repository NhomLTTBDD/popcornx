import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/navigation/app_routes.dart';
import 'package:baitapthuchanh/navigation/app_page_route.dart';
import 'package:baitapthuchanh/screens/welcome_screen.dart';
import 'package:baitapthuchanh/screens/signin_screen.dart';
import 'package:baitapthuchanh/screens/signup_screen.dart';
import 'package:baitapthuchanh/screens/dashboard_screen.dart';
import 'package:baitapthuchanh/screens/profile_screen.dart';
import 'package:baitapthuchanh/screens/forget_password_screen.dart';
import 'package:baitapthuchanh/screens/all_movies_screen.dart';
import 'package:baitapthuchanh/screens/movie_detail_screen.dart';
import 'package:baitapthuchanh/screens/cinema_selection_screen.dart';
import 'package:baitapthuchanh/screens/cinema_showtimes_screen.dart';
import 'package:baitapthuchanh/screens/movies_by_cinema_screen.dart';
import 'package:baitapthuchanh/screens/seat_selection_screen.dart';
import 'package:baitapthuchanh/screens/payment_screen.dart';
import 'package:baitapthuchanh/screens/my_tickets_screen.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/showtime.dart';

/// File này quản lý toàn bộ navigation trong ứng dụng
/// Sử dụng GlobalKey để điều hướng mà không cần context
class AppNavigator {
  // GlobalKey để quản lý NavigatorState
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Lấy NavigatorState hiện tại
  static NavigatorState? get _navigator => navigatorKey.currentState;

  // ==================== NAVIGATION CƠ BẢN ====================

  /// Quay lại màn hình trước
  /// Ví dụ: AppNavigator.goBack();
  static void goBack<T>([T? result]) {
    if (_navigator?.canPop() ?? false) {
      _navigator?.pop(result);
    }
  }

  /// Kiểm tra có thể quay lại không
  static bool canGoBack() {
    return _navigator?.canPop() ?? false;
  }

  // ==================== NAVIGATION ĐẾN MÀN HÌNH CỤ THỂ ====================

  /// Điều hướng đến màn hình Welcome
  static void goToWelcome() {
    _navigator?.pushReplacement(
      AppPageRoute(child: const WelcomeScreen()),
    );
  }

  /// Điều hướng đến màn hình Sign In
  static void goToSignIn() {
    _navigator?.push(
      AppPageRoute(child: const SignInScreen()),
    );
  }

  /// Điều hướng đến màn hình Sign Up
  static void goToSignUp() {
    _navigator?.push(
      AppPageRoute(child: const SignUpScreen()),
    );
  }

  /// Điều hướng đến màn hình Dashboard
  /// replace: true = thay thế màn hình hiện tại (không thể quay lại)
  /// replace: false = push màn hình mới (có thể quay lại)
  static void goToDashboard({bool replace = false}) {
    final route = AppPageRoute(child: const DashboardScreen());
    if (replace) {
      _navigator?.pushReplacement(route);
    } else {
      _navigator?.push(route);
    }
  }

  /// Điều hướng đến màn hình Profile
  static void goToProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _navigator?.push(
        AppPageRoute(child: ProfileScreen(user: user)),
      );
    }
  }

  /// Điều hướng đến màn hình Forget Password
  static void goToForgetPassword() {
    _navigator?.push(
      AppPageRoute(child: const ForgetPasswordScreen()),
    );
  }

  // ==================== NAVIGATION PHIM VÀ RẠP ====================

  /// Điều hướng đến màn hình All Movies
  static void goToAllMovies() {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: AllMoviesScreen(firestoreService: firestoreService),
      ),
    );
  }

  /// Điều hướng đến màn hình Movie Detail
  static void goToMovieDetail(Movie movie) {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: MovieDetailScreen(
          movie: movie,
          firestoreService: firestoreService,
        ),
      ),
    );
  }

  /// Điều hướng đến màn hình Cinema Selection
  static void goToCinemaSelection() {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: CinemaSelectionScreen(firestoreService: firestoreService),
      ),
    );
  }

  /// Điều hướng đến màn hình Cinema Showtimes
  static void goToCinemaShowtimes(String cinemaId, String cinemaName) {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: CinemaShowtimesScreen(
          cinemaId: cinemaId,
          cinemaName: cinemaName,
          firestoreService: firestoreService,
        ),
      ),
    );
  }

  /// Điều hướng đến màn hình Movies By Cinema
  static void goToMoviesByCinema(String cinemaId, String cinemaName) {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: MoviesByCinemaScreen(
          cinemaId: cinemaId,
          cinemaName: cinemaName,
          firestoreService: firestoreService,
        ),
      ),
    );
  }

  // ==================== NAVIGATION ĐẶT VÉ ====================

  /// Điều hướng đến màn hình Seat Selection
  static void goToSeatSelection({
    required Movie movie,
    required Cinema cinema,
    required Showtime showtime,
  }) {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: SeatSelectionScreen(
          movie: movie,
          cinema: cinema,
          showtime: showtime,
          firestoreService: firestoreService,
        ),
      ),
    );
  }

  /// Điều hướng đến màn hình Payment
  static void goToPayment({
    required Movie movie,
    required Cinema cinema,
    required Showtime showtime,
    required List<String> selectedSeats,
    required int totalPrice,
  }) {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: PaymentScreen(
          movie: movie,
          cinema: cinema,
          showtime: showtime,
          selectedSeats: selectedSeats,
          totalPrice: totalPrice,
          firestoreService: firestoreService,
        ),
      ),
    );
  }

  /// Điều hướng đến màn hình My Tickets
  static void goToMyTickets() {
    final firestoreService = FirestoreService();
    _navigator?.push(
      AppPageRoute(
        child: MyTicketsScreen(firestoreService: firestoreService),
      ),
    );
  }

  // ==================== NAVIGATION ĐẶC BIỆT ====================

  /// Xóa tất cả màn hình trong stack và điều hướng đến Dashboard
  /// Dùng khi đăng nhập thành công hoặc đăng xuất
  static void replaceToDashboard() {
    _navigator?.pushAndRemoveUntil(
      AppPageRoute(child: const DashboardScreen()),
      (route) => false, // Xóa tất cả route cũ
    );
  }

  /// Xóa tất cả màn hình trong stack và điều hướng đến Welcome
  /// Dùng khi đăng xuất
  static void replaceToWelcome() {
    _navigator?.pushAndRemoveUntil(
      AppPageRoute(child: const WelcomeScreen()),
      (route) => false, // Xóa tất cả route cũ
    );
  }
}
