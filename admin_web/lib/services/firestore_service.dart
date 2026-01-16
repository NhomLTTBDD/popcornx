import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =======================
  // USER / AUTH
  // =======================

  Future<String?> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['role'] as String?;
    } catch (e) {
      debugPrint('Error getting user role: $e');
      return null;
    }
  }


  Future<void> saveUserIfNotExists(User user) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': 'user', // chỉ set LẦN ĐẦU
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      // chỉ update metadata, KHÔNG ĐỘNG ROLE
      await docRef.update({
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // =======================
  // MOVIES (ADMIN)
  // =======================

  Future<void> addMovie({
    required String title,
    required String description,
    required String thumbnailUrl,
    required String videoUrl,
    bool trending = false,
  }) async {
    await _firestore.collection('movies').add({
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'trending': trending,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMovies() {
    return _firestore
        .collection('movies')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> deleteMovie(String movieId) async {
    await _firestore.collection('movies').doc(movieId).delete();
  }

  Future<void> updateMovie(
    String movieId, {
    String? title,
    String? description,
    String? thumbnailUrl,
    String? videoUrl,
    bool? trending,
  }) async {
    final updateData = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (title != null) updateData['title'] = title;
    if (description != null) updateData['description'] = description;
    if (thumbnailUrl != null) updateData['thumbnailUrl'] = thumbnailUrl;
    if (videoUrl != null) updateData['videoUrl'] = videoUrl;
    if (trending != null) updateData['trending'] = trending;

    await _firestore.collection('movies').doc(movieId).update(updateData);
  }
}
