class Booking {
  final String id;
  final String userId;
  final String movieId;
  final String cinemaId;
  final String showtimeId;
  final List<String> seats;
  final int totalPrice;
  final String status;
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
