/// Model class đại diện cho một rạp chiếu phim
class Cinema {
  final String id;
  final String name;

  Cinema({
    required this.id,
    required this.name,
  });

  /// Factory constructor để tạo Cinema từ Firestore document
  factory Cinema.fromFirestore(Map<String, dynamic> data, String id) {
    return Cinema(
      id: id,
      name: data['name'] ?? '',
    );
  }

  /// Convert Cinema thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}
