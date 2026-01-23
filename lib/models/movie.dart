/// Model class đại diện cho một bộ phim
class Movie {
  final String id;
  final String title;
  final String image;
  final bool trending;
  final String category;
  final String? cinemaId; // ID của rạp chiếu phim
  final DateTime? createdAt;

  Movie({
    required this.id,
    required this.title,
    required this.image,
    this.trending = false,
    this.category = 'international',
    this.cinemaId,
    this.createdAt,
  });

  /// Factory constructor để tạo Movie từ Firestore document
  factory Movie.fromFirestore(Map<String, dynamic> data, String id) {
    return Movie(
      id: id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      trending: data['trending'] ?? false,
      category: data['category'] ?? 'international',
      cinemaId: data['cinemaId'] as String?,
      createdAt: data['createdAt']?.toDate(),
    );
  }

  /// Convert Movie thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'image': image,
      'trending': trending,
      'category': category,
      if (cinemaId != null) 'cinemaId': cinemaId,
    };
  }
}
