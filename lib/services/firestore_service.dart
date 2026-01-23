import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/showtime.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserIfNotExists(User user, {String? name}) async {
    final docRef = _firestore.collection('users').doc(user.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'role': 'user', 
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.update({
        'email': user.email ?? '',
        'photoUrl': user.photoURL ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  Future<void> setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({
      'role': role,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Khởi tạo phim Việt Nam vào Firestore
  Future<void> initializeMovies({bool force = false}) async {
    try {
      final moviesRef = _firestore.collection('movies');
      
      if (!force) {
        final snapshot = await moviesRef.limit(1).get();
        if (snapshot.docs.isNotEmpty) {
          print('Phim đã tồn tại trong Firestore, bỏ qua khởi tạo');
          return;
        }
      } else {
        final snapshot = await moviesRef.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        print('da xoa phim cu trong firestore');
      }
      
      print('khoi tao phim');
      final movies = [
        // Phim Việt Nam
        {
          'title': 'Lật Mặt: 48H',
          'image': 'assets/images/lat_mat.jpg',
          'trending': true,
          'category': 'vietnam',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Bố Già',
          'image': 'assets/images/bo_gia.jpg',
          'trending': false,
          'category': 'vietnam',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Harry Potter và Bảo Bối Tử Thần',
          'image': 'assets/images/harrypotter.jpg',
          'trending': false,
          'category': 'international',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Doraemon và Quân đoàn Robot',
          'image': 'assets/images/Doraemon.jpg',
          'trending': true,
          'category': 'anime',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Gã hề ma quái phần 2',
          'image': 'assets/images/ga_he_ma_quai.jpg',
          'trending': false,
          'category': 'horror',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'World War Z',
          'image': 'assets/images/world_war_z.jpg',
          'trending': true,
          'category': 'horror',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Vùng Đất Câm Lặng',
          'image': 'assets/images/vung_dat_cam_lang.jpg',
          'trending': true,
          'category': 'horror',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Interstellar',
          'image': 'assets/images/interstellar.jpg',
          'trending': false,
          'category': 'sci-fi',
          'createdAt': FieldValue.serverTimestamp(),
        }
      ];

      for (final movie in movies) {
        await moviesRef.add(movie);
      }
      print('them ${movies.length} phim vao firebase!');
    } catch (e) {
      print('loi khoi tao phim: $e');
    }
  }

  // ==================== CINEMA METHODS ====================

  /// Lấy Stream danh sách tất cả các rạp chiếu phim
  Stream<QuerySnapshot<Map<String, dynamic>>> getCinemasStream() {
    return _firestore
        .collection('cinemas')
        .orderBy('name')
        .snapshots();
  }

  /// Lấy danh sách tất cả các rạp chiếu phim (Future)
  Future<List<Cinema>> getCinemas() async {
    final snapshot = await _firestore
        .collection('cinemas')
        .orderBy('name')
        .get();
    
    return snapshot.docs.map((doc) {
      return Cinema.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  // ==================== MOVIE METHODS ====================

  /// Lấy Stream danh sách phim theo cinemaId
  Stream<QuerySnapshot<Map<String, dynamic>>> getMoviesByCinemaStream(String cinemaId) {
    return _firestore
        .collection('movies')
        .where('cinemaId', isEqualTo: cinemaId)
        .snapshots();
  }

  /// Lấy danh sách phim theo cinemaId (Future)
  Future<List<Movie>> getMoviesByCinema(String cinemaId) async {
    final snapshot = await _firestore
        .collection('movies')
        .where('cinemaId', isEqualTo: cinemaId)
        .get();
    
    return snapshot.docs.map((doc) {
      return Movie.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  // ==================== SHOWTIME METHODS ====================

  /// Lấy Stream danh sách khung giờ chiếu theo movieId
  Stream<QuerySnapshot<Map<String, dynamic>>> getShowtimesByMovieStream(String movieId) {
    return _firestore
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .orderBy('time')
        .snapshots();
  }

  /// Lấy danh sách khung giờ chiếu theo movieId (Future)
  Future<List<Showtime>> getShowtimesByMovie(String movieId) async {
    final snapshot = await _firestore
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .orderBy('time')
        .get();
    
    return snapshot.docs.map((doc) {
      return Showtime.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  // ==================== INITIALIZE DATA ====================

  /// Khởi tạo dữ liệu mẫu cho cinemas, movies và showtimes
  Future<void> initializeCinemaData({bool force = false}) async {
    try {
      // Kiểm tra xem đã có dữ liệu chưa
      if (!force) {
        final cinemasSnapshot = await _firestore.collection('cinemas').limit(1).get();
        if (cinemasSnapshot.docs.isNotEmpty) {
          print('Dữ liệu rạp chiếu đã tồn tại, bỏ qua khởi tạo');
          return;
        }
      } else {
        // Xóa dữ liệu cũ nếu force = true
        final cinemasSnapshot = await _firestore.collection('cinemas').get();
        for (var doc in cinemasSnapshot.docs) {
          await doc.reference.delete();
        }
        final showtimesSnapshot = await _firestore.collection('showtimes').get();
        for (var doc in showtimesSnapshot.docs) {
          await doc.reference.delete();
        }
        print('Đã xóa dữ liệu rạp chiếu cũ');
      }

      // Tạo các rạp chiếu phim
      final cinemas = [
        {'name': 'CGV Vincom'},
        {'name': 'Lotte Cinema'},
        {'name': 'Galaxy Cinema'},
        {'name': 'BHD Star'},
      ];

      final cinemaIds = <String>[];
      for (final cinema in cinemas) {
        final docRef = await _firestore.collection('cinemas').add(cinema);
        cinemaIds.add(docRef.id);
      }
      print('Đã tạo ${cinemas.length} rạp chiếu phim');

      // Tạo phim cho mỗi rạp (lấy từ movies collection hiện có hoặc tạo mới)
      final existingMovies = await _firestore.collection('movies').limit(4).get();
      final movieIds = <String>[];

      if (existingMovies.docs.isNotEmpty) {
        // Cập nhật movies hiện có với cinemaId
        for (int i = 0; i < existingMovies.docs.length && i < cinemaIds.length; i++) {
          await existingMovies.docs[i].reference.update({
            'cinemaId': cinemaIds[i],
          });
          movieIds.add(existingMovies.docs[i].id);
        }
      } else {
        // Tạo movies mới nếu chưa có
        final newMovies = [
          {'title': 'Lật Mặt: 48H', 'image': 'assets/images/lat_mat.jpg', 'cinemaId': cinemaIds[0]},
          {'title': 'Bố Già', 'image': 'assets/images/bo_gia.jpg', 'cinemaId': cinemaIds[1]},
          {'title': 'Harry Potter', 'image': 'assets/images/harrypotter.jpg', 'cinemaId': cinemaIds[2]},
          {'title': 'Doraemon', 'image': 'assets/images/Doraemon.jpg', 'cinemaId': cinemaIds[3]},
        ];

        for (final movie in newMovies) {
          final docRef = await _firestore.collection('movies').add(movie);
          movieIds.add(docRef.id);
        }
      }

      // Tạo khung giờ chiếu cho mỗi phim
      final showtimes = [
        ['10:00', '13:30', '16:00', '18:30', '21:00'],
        ['09:30', '12:00', '14:30', '17:00', '19:30', '22:00'],
        ['10:30', '13:00', '15:30', '18:00', '20:30'],
        ['11:00', '14:00', '17:30', '20:00'],
      ];

      int showtimeCount = 0;
      for (int i = 0; i < movieIds.length; i++) {
        final times = showtimes[i % showtimes.length];
        for (final time in times) {
          await _firestore.collection('showtimes').add({
            'movieId': movieIds[i],
            'time': time,
          });
          showtimeCount++;
        }
      }
      print('Đã tạo $showtimeCount khung giờ chiếu');
    } catch (e) {
      print('Lỗi khởi tạo dữ liệu rạp chiếu: $e');
    }
  }
}
