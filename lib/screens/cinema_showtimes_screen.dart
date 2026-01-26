import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

class CinemaShowtimesScreen extends StatelessWidget {
  final String cinemaId;
  final String cinemaName;
  final FirestoreService firestoreService;
  final Cinema? cinema;

  const CinemaShowtimesScreen({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
    required this.firestoreService,
    this.cinema,
  });

  String _todayText() {
    final now = DateTime.now();
    return DateFormat('EEEE, dd/MM/yyyy', 'vi').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: AppNavigator.goBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lịch Chiếu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              cinemaName,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lịch chiếu hôm nay',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _todayText(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // ===== SHOWTIMES LIST =====
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firestoreService.getShowtimesByCinemaStream(cinemaId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Có lỗi xảy ra',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.movie_outlined,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có lịch chiếu hôm nay',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final showtimes = snapshot.data!.docs
                    .map((doc) =>
                        Showtime.fromFirestore(doc.data(), doc.id))
                    .toList();

                final Map<String, List<Showtime>> grouped = {};
                for (final s in showtimes) {
                  grouped.putIfAbsent(s.movieId, () => []);
                  grouped[s.movieId]!.add(s);
                }

                for (final key in grouped.keys) {
                  grouped[key]!.sort((a, b) => a.time.compareTo(b.time));
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final movieId = grouped.keys.elementAt(index);
                    return _MovieShowtimesCard(
                      movieId: movieId,
                      showtimes: grouped[movieId]!,
                      firestoreService: firestoreService,
                      cinemaId: cinemaId,
                      cinemaName: cinemaName,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ================= CARD =================

class _MovieShowtimesCard extends StatelessWidget {
  final String movieId;
  final List<Showtime> showtimes;
  final FirestoreService firestoreService;
  final String cinemaId;
  final String cinemaName;

  const _MovieShowtimesCard({
    required this.movieId,
    required this.showtimes,
    required this.firestoreService,
    required this.cinemaId,
    required this.cinemaName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: firestoreService.getMovieByIdStream(movieId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                'Không tìm thấy phim',
                style: TextStyle(color: Colors.white),
              );
            }

            final movie = Movie.fromFirestore(
              snapshot.data!.data()!,
              snapshot.data!.id,
            );

            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: _MovieImage(
                    image: movie.image,
                    width: 120,
                    height: 180,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                if (movie.category.isNotEmpty)
                  Text(
                    _getCategoryName(movie.category),
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Khung giờ chiếu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: showtimes.map((s) {
                    return _ShowtimeChip(
                      time: s.time,
                      onTap: () {
                        AppNavigator.goToSeatSelection(
                          movie: movie,
                          cinema: Cinema(id: cinemaId, name: cinemaName),
                          showtime: s,
                        );
                      },
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _getCategoryName(String category) {
    switch (category) {
      case 'vietnam':
        return 'Phim Việt Nam';
      case 'international':
        return 'Phim Quốc Tế';
      case 'horror':
        return 'Kinh Dị';
      case 'anime':
        return 'Anime';
      case 'adventure':
        return 'Thám Hiểm';
      case 'sci-fi':
        return 'Khoa Học Viễn Tưởng';
      default:
        return category;
    }
  }
}

// ================= SMALL WIDGETS =================

class _ShowtimeChip extends StatelessWidget {
  final String time;
  final VoidCallback onTap;

  const _ShowtimeChip({
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.redAccent),
          color: Colors.redAccent.withOpacity(0.12),
        ),
        child: Text(
          time,
          style: const TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MovieImage extends StatelessWidget {
  final String image;
  final double width;
  final double height;

  const _MovieImage({
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (image.isEmpty) {
      return _fallback();
    }

    return SizedBox(
      width: width,
      height: height,
      child: image.startsWith('assets/')
          ? Image.asset(image, fit: BoxFit.cover)
          : Image.network(image, fit: BoxFit.cover),
    );
  }

  Widget _fallback() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, color: Colors.grey, size: 40),
    );
  }
}