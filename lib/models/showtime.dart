class Showtime {
  final String id;
  final String movieId;
  final String cinemaId; 
  final String time; 
  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.time,
  });

  factory Showtime.fromFirestore(Map<String, dynamic> data, String id) {
    return Showtime(
      id: id,
      movieId: data['movieId'] ?? '',
      cinemaId: data['cinemaId'] ?? '',
      time: data['time'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'movieId': movieId,
      'cinemaId': cinemaId,
      'time': time,
    };
  }
}
