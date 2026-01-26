import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/models/booking.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _generateIdFromTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
        .replaceAll(RegExp(r'[đ]'), 'd')
        .replaceAll(RegExp(r'[^a-z0-9]'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

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

  Future<String?> getUserRole(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getCinemasStream() {
    return _firestore
        .collection('cinemas')
        .orderBy('name')
        .snapshots();
  }

  Future<List<Cinema>> getCinemas() async {
    final snapshot = await _firestore
        .collection('cinemas')
        .orderBy('name')
        .get();
    
    return snapshot.docs.map((doc) {
      return Cinema.fromFirestore(doc.data(), doc.id);
    }).toList();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllMoviesStream() {
    return _firestore
        .collection('movies')
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getMovieByIdStream(String movieId) {
    return _firestore.collection('movies').doc(movieId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCinemaByIdStream(String cinemaId) {
    return _firestore.collection('cinemas').doc(cinemaId).snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getShowtimeByIdStream(String showtimeId) {
    return _firestore.collection('showtimes').doc(showtimeId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getShowtimesByCinemaStream(
    String cinemaId,
  ) {
    return _firestore
        .collection('showtimes')
        .where('cinemaId', isEqualTo: cinemaId)
        .orderBy('time')
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getShowtimesByMovieAndCinemaStream(
    String movieId,
    String cinemaId,
  ) {
    return _firestore
        .collection('showtimes')
        .where('movieId', isEqualTo: movieId)
        .where('cinemaId', isEqualTo: cinemaId)
        .orderBy('time')
        .snapshots();
  }

  Future<List<String>> getBookedSeats(String showtimeId) async {
    try {
      final snapshot = await _firestore
          .collection('bookings')
          .where('showtimeId', isEqualTo: showtimeId)
          .where('status', isEqualTo: 'paid')
          .get();

      final bookedSeats = <String>[];
      for (var doc in snapshot.docs) {
        final seats = doc.data()['seats'] as List<dynamic>?;
        if (seats != null) {
          bookedSeats.addAll(seats.map((e) => e.toString()));
        }
      }
      return bookedSeats;
    } catch (e) {
      print('Lỗi khi lấy danh sách ghế đã bán: $e');
      return [];
    }
  }

  Future<String> createBooking({
    required String userId,
    required String movieId,
    required String cinemaId,
    required String showtimeId,
    required List<String> seats,
    required int totalPrice,
    String status = 'pending',
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final bookingId = '${userId}_${movieId}_${cinemaId}_${showtimeId}_$timestamp';
      
      await _firestore.collection('bookings').doc(bookingId).set({
        'userId': userId,
        'movieId': movieId,
        'cinemaId': cinemaId,
        'showtimeId': showtimeId,
        'seats': seats,
        'totalPrice': totalPrice,
        'status': status,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return bookingId;
    } catch (e) {
      print('Lỗi khi tạo booking: $e');
      rethrow;
    }
  }

  Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'paid')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> initializeCinemaData({bool force = false}) async {
    try {
      if (!force) {
        final cinemasSnapshot = await _firestore.collection('cinemas').limit(1).get();
        if (cinemasSnapshot.docs.isNotEmpty) {
          print('Dữ liệu rạp chiếu đã tồn tại, bỏ qua khởi tạo');
          return;
        }
      } else {
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

      final cinemas = [
        {'name': 'CGV Vincom'},
        {'name': 'Lotte Cinema'},
        {'name': 'Galaxy Cinema'},
        {'name': 'BHD Star'},
      ];

      final cinemaIds = <String>[];
      for (final cinema in cinemas) {
        final cinemaId = _generateIdFromTitle(cinema['name'] as String);
        await _firestore.collection('cinemas').doc(cinemaId).set(cinema);
        cinemaIds.add(cinemaId);
      }
      print('Đã tạo ${cinemas.length} rạp chiếu phim');

      final existingMovies = await _firestore.collection('movies').limit(4).get();
      final movieIds = <String>[];

      if (existingMovies.docs.isNotEmpty) {
        for (var doc in existingMovies.docs) {
          movieIds.add(doc.id);
        }
      } else {
        final newMovies = [
          {'title': 'Lật Mặt: 48H', 'image': 'assets/images/lat_mat.jpg', 'category': 'vietnam'},
          {'title': 'Bố Già', 'image': 'assets/images/bo_gia.jpg', 'category': 'vietnam'},
          {'title': 'Harry Potter', 'image': 'assets/images/harrypotter.jpg', 'category': 'international'},
          {'title': 'Doraemon', 'image': 'assets/images/Doraemon.jpg', 'category': 'anime'},
        ];

        for (final movie in newMovies) {
          final movieId = _generateIdFromTitle(movie['title'] as String);
          await _firestore.collection('movies').doc(movieId).set(movie);
          movieIds.add(movieId);
        }
      }

      final showtimes = [
        ['10:00', '13:30', '16:00', '18:30', '21:00'],
        ['09:30', '12:00', '14:30', '17:00', '19:30', '22:00'],
        ['10:30', '13:00', '15:30', '18:00', '20:30'],
        ['11:00', '14:00', '17:30', '20:00'],
      ];

      int showtimeCount = 0;
      for (int movieIndex = 0; movieIndex < movieIds.length; movieIndex++) {
        final movieId = movieIds[movieIndex];
        final times = showtimes[movieIndex % showtimes.length];
        
        for (final cinemaId in cinemaIds) {
          for (final time in times) {
            final showtimeId = '${movieId}_${cinemaId}_${time.replaceAll(':', '')}';
            await _firestore.collection('showtimes').doc(showtimeId).set({
              'movieId': movieId,
              'cinemaId': cinemaId,
              'time': time,
            });
            showtimeCount++;
          }
        }
      }
      print('Đã tạo $showtimeCount khung giờ chiếu cho ${movieIds.length} phim ở ${cinemaIds.length} rạp');
    } catch (e) {
      print('Lỗi khởi tạo dữ liệu rạp chiếu: $e');
    }
  }
}
