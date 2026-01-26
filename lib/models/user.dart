/// Model class đại diện cho một user trong hệ thống
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl = '',
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromFirestore(Map<String, dynamic> data, String id) {
    return AppUser(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      role: data['role'] ?? 'user',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  /// Convert AppUser thành Map để lưu vào Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
    };
  }
}
