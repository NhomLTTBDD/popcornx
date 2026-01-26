import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/screens/seat_selection_screen.dart';

/// Screen hiển thị lịch chiếu theo từng rạp
/// Luồng dữ liệu: Cinema → Showtimes (query theo cinemaId) → Group theo movieId → Load Movie info
class CinemaShowtimesScreen extends StatelessWidget {
  final String cinemaId;
  final String cinemaName;
  final FirestoreService firestoreService;
  final Cinema? cinema; // Optional: nếu có thì dùng, không thì tạo từ cinemaId và cinemaName

  const CinemaShowtimesScreen({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
    required this.firestoreService,
    this.cinema,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Query showtimes theo cinemaId
        stream: firestoreService.getShowtimesByCinemaStream(cinemaId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_outlined, color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có lịch chiếu',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // Parse showtimes từ Firestore
          final showtimes = snapshot.data!.docs.map((doc) {
            return Showtime.fromFirestore(doc.data(), doc.id);
          }).toList();

          // Group showtimes theo movieId ở client
          final Map<String, List<Showtime>> groupedShowtimes = {};
          for (final showtime in showtimes) {
            if (!groupedShowtimes.containsKey(showtime.movieId)) {
              groupedShowtimes[showtime.movieId] = [];
            }
            groupedShowtimes[showtime.movieId]!.add(showtime);
          }

          for (final movieId in groupedShowtimes.keys) {
            groupedShowtimes[movieId]!.sort((a, b) => a.time.compareTo(b.time));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedShowtimes.length,
            itemBuilder: (context, index) {
              final movieId = groupedShowtimes.keys.elementAt(index);
              final movieShowtimes = groupedShowtimes[movieId]!;

              return _MovieShowtimesCard(
                movieId: movieId,
                showtimes: movieShowtimes,
                firestoreService: firestoreService,
                cinemaId: cinemaId,
                cinemaName: cinemaName,
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget hiển thị một phim kèm danh sách khung giờ chiếu
/// Load thông tin Movie theo movieId và hiển thị tên phim + khung giờ
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
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          // Load thông tin Movie theo movieId
          stream: firestoreService.getMovieByIdStream(movieId),
          builder: (context, snapshot) {
            // Loading movie info
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            // Error hoặc không tìm thấy movie
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phim ID: $movieId',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Khung Giờ Chiếu:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: showtimes.map((showtime) {
                        return _ShowtimeChip(time: showtime.time);
                      }).toList(),
                    ),
                  ],
                ),
              );
            }

            // Parse movie từ Firestore
            final movie = Movie.fromFirestore(
              snapshot.data!.data()!,
              snapshot.data!.id,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Movie poster - centered
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _MovieImage(
                      image: movie.image,
                      width: 120,
                      height: 180,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Movie title and info - centered
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          movie.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (movie.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryName(movie.category),
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Showtimes section - centered
                const Text(
                  'Khung Giờ Chiếu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Showtimes list - centered
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: showtimes.map((showtime) {
                      return _ShowtimeChip(
                        time: showtime.time,
                        onTap: () {
                          // Navigate đến SeatSelectionScreen
                          final cinema = Cinema(id: cinemaId, name: cinemaName);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SeatSelectionScreen(
                                movie: movie,
                                cinema: cinema,
                                showtime: showtime,
                                firestoreService: firestoreService,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
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
        return 'Phim Kinh Dị';
      case 'anime':
        return 'Anime';
      case 'adventure':
        return 'Phim Thám Hiểm';
      case 'sci-fi':
        return 'Khoa Học Viễn Tưởng';
      default:
        return category;
    }
  }
}

/// Widget hiển thị một khung giờ chiếu dạng Chip
class _ShowtimeChip extends StatelessWidget {
  final String time;
  final VoidCallback? onTap;

  const _ShowtimeChip({
    required this.time,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final widget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        border: Border.all(color: Colors.redAccent, width: 1.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: widget,
      );
    }

    return widget;
  }
}

/// Widget hiển thị hình ảnh phim
class _MovieImage extends StatelessWidget {
  final String image;
  final double width;
  final double height;

  const _MovieImage({
    required this.image,
    required this.width,
    required this.height,
  });

  bool get _isAsset => image.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (image.isEmpty) {
      child = _fallback();
    } else if (_isAsset) {
      child = Image.asset(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    } else {
      child = Image.network(
        image,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, size: 40, color: Colors.grey),
    );
  }
}
