/// Model class đại diện cho một booking (đặt vé)
class Booking {
  final String id;
  final String userId;
  final String movieId;
  final String cinemaId;
  final String showtimeId;
  final List<String> seats; // ["A1", "A2", "B3"]
  final int totalPrice;
  final String status; // "pending" | "paid"
  final DateTime? createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.cinemaId,
    required this.showtimeId,
    required this.seats,
    required this.totalPrice,
    this.status = 'pending',
    this.createdAt,
  });

  /// Factory constructor để tạo Booking từ Firestore document
  factory Booking.fromFirestore(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      movieId: data['movieId'] ?? '',
      cinemaId: data['cinemaId'] ?? '',
      showtimeId: data['showtimeId'] ?? '',
      seats: List<String>.from(data['seats'] ?? []),
      totalPrice: data['totalPrice'] ?? 0,
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt']?.toDate(),
    );
  }

  /// Convert Booking thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'movieId': movieId,
      'cinemaId': cinemaId,
      'showtimeId': showtimeId,
      'seats': seats,
      'totalPrice': totalPrice,
      'status': status,
    };
  }
}
