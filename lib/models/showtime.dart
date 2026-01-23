/// Model class đại diện cho một khung giờ chiếu phim
class Showtime {
  final String id;
  final String movieId;
  final String time; // Format: "HH:mm" (ví dụ: "18:30")

  Showtime({
    required this.id,
    required this.movieId,
    required this.time,
  });

  /// Factory constructor để tạo Showtime từ Firestore document
  factory Showtime.fromFirestore(Map<String, dynamic> data, String id) {
    return Showtime(
      id: id,
      movieId: data['movieId'] ?? '',
      time: data['time'] ?? '',
    );
  }

  /// Convert Showtime thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'time': time,
    };
  }
}
