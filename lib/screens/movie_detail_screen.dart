import 'package:flutter/material.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final FirestoreService? firestoreService;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    this.firestoreService,
  });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // App Bar với poster
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => AppNavigator.goBack(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _MovieImage(
                image: movie.image,
                height: 400,
                width: double.infinity,
                radius: 0,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Thông tin phim
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.category,
                        label: _getCategoryName(movie.category),
                      ),
                      const SizedBox(width: 12),
                      if (movie.trending)
                        _InfoChip(
                          icon: Icons.local_fire_department,
                          label: 'Đang Hot',
                          color: Colors.orange,
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Mô tả (placeholder)
                  const Text(
                    'Mô tả phim',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Đây là một bộ phim hấp dẫn với cốt truyện thú vị và diễn xuất xuất sắc. Phim mang đến những trải nghiệm điện ảnh đáng nhớ cho khán giả.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Thông tin chi tiết
                  _DetailRow(
                    icon: Icons.access_time,
                    label: 'Thời lượng',
                    value: '120 phút',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.star,
                    label: 'Đánh giá',
                    value: '8.5/10',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Ngày khởi chiếu',
                    value: movie.createdAt != null
                        ? '${movie.createdAt!.day}/${movie.createdAt!.month}/${movie.createdAt!.year}'
                        : 'Sắp ra mắt',
                  ),
                  const SizedBox(height: 40),
                  // Button Đặt vé
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (firestoreService != null) {
                          AppNavigator.goToCinemaSelection();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể đặt vé. Vui lòng thử lại.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đặt Vé',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: (color ?? Colors.redAccent).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color ?? Colors.redAccent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color ?? Colors.redAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.redAccent, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _MovieImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final double radius;

  const _MovieImage({
    required this.image,
    required this.height,
    required this.width,
    required this.radius,
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

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(height: height, width: width, child: child),
        ),
        // Gradient overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, size: 60, color: Colors.grey),
    );
  }
}
