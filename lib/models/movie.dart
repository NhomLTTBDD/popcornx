class Movie {
  final String id;
  final String title;
  final String image;
  final bool trending;
  final String category;
  final DateTime? createdAt;

  Movie({
    required this.id,
    required this.title,
    required this.image,
    this.trending = false,
    this.category = 'international',
    this.createdAt,
  });

  factory Movie.fromFirestore(Map<String, dynamic> data, String id) {
    return Movie(
      id: id,
      title: data['title'] ?? '',
      image: data['image'] ?? '',
      trending: data['trending'] ?? false,
      category: data['category'] ?? 'international',
      createdAt: data['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'image': image,
      'trending': trending,
      'category': category,
    };
  }
}
