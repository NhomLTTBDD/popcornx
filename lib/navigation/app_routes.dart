/// File này chứa tất cả các tên route trong ứng dụng
/// Mục đích: Quản lý tập trung tên route, dễ bảo trì và tránh lỗi typo
class AppRoutes {
  // Route chính
  static const String welcome = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String forgetPassword = '/forget-password';
  
  // Route phim và rạp
  static const String allMovies = '/all-movies';
  static const String movieDetail = '/movie-detail';
  static const String cinemaSelection = '/cinema-selection';
  static const String cinemaShowtimes = '/cinema-showtimes';
  static const String moviesByCinema = '/movies-by-cinema';
  
  // Route đặt vé
  static const String seatSelection = '/seat-selection';
  static const String payment = '/payment';
  static const String myTickets = '/my-tickets';
}
