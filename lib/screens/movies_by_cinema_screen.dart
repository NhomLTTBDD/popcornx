import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/screens/movie_detail_screen.dart';

class MoviesByCinemaScreen extends StatelessWidget {
  final String cinemaId;
  final String cinemaName;
  final FirestoreService firestoreService;

  const MoviesByCinemaScreen({
    super.key,
    required this.cinemaId,
    required this.cinemaName,
    required this.firestoreService,
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
              'Phim Đang Chiếu',
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
        stream: firestoreService.getMoviesByCinemaStream(cinemaId),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
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

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.movie_outlined, color: Colors.grey, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có phim nào đang chiếu',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // List movies
          final movies = snapshot.data!.docs.map((doc) {
            return Movie.fromFirestore(doc.data(), doc.id);
          }).toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _MovieWithShowtimesCard(
                movie: movie,
                firestoreService: firestoreService,
              );
            },
          );
        },
      ),
    );
  }
}

/// Widget hiển thị một phim kèm danh sách khung giờ chiếu
class _MovieWithShowtimesCard extends StatelessWidget {
  final Movie movie;
  final FirestoreService firestoreService;

  const _MovieWithShowtimesCard({
    required this.movie,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to movie detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie info row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie poster
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _MovieImage(
                      image: movie.image,
                      width: 80,
                      height: 120,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Movie title and info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (movie.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
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
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Showtimes section
              const Text(
                'Khung Giờ Chiếu:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              // Showtimes list
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: firestoreService.getShowtimesByMovieStream(movie.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Chưa có khung giờ chiếu',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    );
                  }

                  final showtimes = snapshot.data!.docs.map((doc) {
                    return Showtime.fromFirestore(doc.data(), doc.id);
                  }).toList();

                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: showtimes.map((showtime) {
                      return _ShowtimeChip(
                        time: showtime.time,
                        onTap: () {
                          // Xử lý khi chọn khung giờ
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã chọn: ${movie.title} - ${showtime.time}',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
      ),
    );
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
