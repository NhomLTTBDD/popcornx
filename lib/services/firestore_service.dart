import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔐 Chỉ tạo user nếu CHƯA tồn tại
  /// ❌ KHÔNG ghi đè role
  Future<void> saveUserIfNotExists(User user, {String? name}) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': 'user', // chỉ set LẦN ĐẦU
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Chỉ update metadata, KHÔNG đụng role
      await docRef.update({
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Lắng nghe user realtime
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  /// Lấy role user
  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  /// ❗ CHỈ ADMIN / SERVER mới được gọi
  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
