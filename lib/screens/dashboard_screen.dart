import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/screens/profile_screen.dart';
import 'package:baitapthuchanh/screens/movie_detail_screen.dart';
import 'package:baitapthuchanh/screens/movies_by_cinema_screen.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/widgets/cinema_selection_bottom_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Popcornx',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // Nút "Chọn rạp"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => _showCinemaSelection(context, firestoreService),
              icon: const Icon(Icons.location_on, color: Colors.redAccent),
              label: const Text(
                'Chọn rạp',
                style: TextStyle(color: Colors.redAccent),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(user: user),
              const SizedBox(height: 16),
              _DebugInitButton(firestoreService: firestoreService),
              const SizedBox(height: 20),
              const _TrendingBanner(), // 🔥 AUTO SLIDE
              const SizedBox(height: 24),
              const _CategorySection(category: 'vietnam', title: 'Phim Việt Nam'),
              const SizedBox(height: 24),
              const _CategorySection(
                  category: 'international', title: 'Phim Quốc Tế'),
              const SizedBox(height: 24),
              const _CategorySection(category: 'horror', title: 'Phim Kinh Dị'),
              const SizedBox(height: 24),
              const _CategorySection(
                  category: 'anime', title: 'Anime'),
              const SizedBox(height: 24),
              const _CategorySection(
                  category: 'adventure', title: 'Phim Thám Hiểm'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Hiển thị BottomSheet để chọn rạp chiếu phim
  Future<void> _showCinemaSelection(
    BuildContext context,
    FirestoreService firestoreService,
  ) async {
    // Hiển thị BottomSheet và chờ kết quả
    final selectedCinemaId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CinemaSelectionBottomSheet(
        firestoreService: firestoreService,
      ),
    );

    // Nếu có rạp được chọn, điều hướng đến màn hình phim của rạp đó
    if (selectedCinemaId != null && context.mounted) {
      // Lấy thông tin rạp để lấy tên
      final cinemas = await firestoreService.getCinemas();
      final selectedCinema = cinemas.firstWhere(
        (cinema) => cinema.id == selectedCinemaId,
        orElse: () => Cinema(id: selectedCinemaId, name: 'Rạp chiếu phim'),
      );

      // Điều hướng đến màn hình phim theo rạp
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoviesByCinemaScreen(
            cinemaId: selectedCinemaId,
            cinemaName: selectedCinema.name,
            firestoreService: firestoreService,
          ),
        ),
      );
    }
  }
}

/* ================= HEADER ================= */

class _Header extends StatelessWidget {
  final User? user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final name =
        user?.displayName?.isNotEmpty == true ? user!.displayName! : 'User';

    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, $name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text('Location >',
                style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const Spacer(),
        _CircleIcon(icon: Icons.search, onTap: () {}),
        const SizedBox(width: 12),
        _CircleIcon(
          icon: Icons.person_outline,
          onTap: () {
            if (user != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(user: user!),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

/* ================= TRENDING AUTO SLIDE ================= */

class _TrendingBanner extends StatefulWidget {
  const _TrendingBanner();

  @override
  State<_TrendingBanner> createState() => _TrendingBannerState();
}

class _TrendingBannerState extends State<_TrendingBanner> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  void _startAutoSlide(int count) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (!mounted || count == 0) return;

      _currentPage = (_currentPage + 1) % count;
      _controller.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('movies')
          .where('trending', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _empty();
        }

        final movies = snapshot.data!.docs;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _startAutoSlide(movies.length);
        });

        return SizedBox(
          height: 240,
          child: PageView.builder(
            controller: _controller,
            itemCount: movies.length,
            itemBuilder: (_, index) {
              final movie = movies[index];
              return _BannerItem(
                movieDoc: movie,
              );
            },
          ),
        );
      },
    );
  }

  Widget _empty() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Text('No trending movies',
            style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

class _BannerItem extends StatelessWidget {
  final QueryDocumentSnapshot movieDoc;

  const _BannerItem({required this.movieDoc});

  void _navigateToDetail(BuildContext context) {
    final movie = Movie.fromFirestore(
      movieDoc.data() as Map<String, dynamic>,
      movieDoc.id,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = movieDoc['title'] ?? '';
    final image = movieDoc['image'] ?? '';
    
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Stack(
        children: [
          _MovieImage(
            image: image,
            height: 240,
            width: double.infinity,
            radius: 24,
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateToDetail(context),
                    child: const Text('Book'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= CATEGORY ================= */

class _CategorySection extends StatelessWidget {
  final String category;
  final String title;

  const _CategorySection({required this.category, required this.title});

  static const double cardHeight = 230;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Xem tất cả >',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: cardHeight,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movies')
                .where('category', isEqualTo: category)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child:
                      Text('Chưa có phim', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final movie = snapshot.data!.docs[index];
                  return _MovieCard(
                    movieDoc: movie,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/* ================= MOVIE CARD ================= */

class _MovieCard extends StatelessWidget {
  final QueryDocumentSnapshot movieDoc;

  const _MovieCard({required this.movieDoc});

  void _navigateToDetail(BuildContext context) {
    final movie = Movie.fromFirestore(
      movieDoc.data() as Map<String, dynamic>,
      movieDoc.id,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = movieDoc['title'] ?? '';
    final image = movieDoc['image'] ?? '';
    
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: SizedBox(
        width: 140,
        height: 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _MovieImage(
              image: image,
              height: 165,
              width: 140,
              radius: 18,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 36,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ================= IMAGE ================= */

class _MovieImage extends StatelessWidget {
  final String image;
  final double height;
  final double width;
  final double radius;

  const _MovieImage(
      {required this.image,
      required this.height,
      required this.width,
      required this.radius});

  bool get _isAsset => image.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (image.isEmpty) {
      child = _fallback();
    } else if (_isAsset) {
      child = Image.asset(image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback());
    } else {
      child = Image.network(image,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback());
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(height: height, width: width, child: child),
    );
  }

  Widget _fallback() {
    return Container(
      color: Colors.grey.shade800,
      child: const Icon(Icons.movie, size: 40, color: Colors.grey),
    );
  }
}

/* ================= BOTTOM NAV ================= */

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: const [
          _NavItem(icon: Icons.movie, active: true),
          _NavItem(icon: Icons.play_circle_outline),
          _NavItem(icon: Icons.confirmation_number_outlined),
          _NavItem(icon: Icons.more_horiz),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _NavItem({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: active ? Colors.redAccent : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: active ? Colors.white : Colors.grey),
    );
  }
}

/* ================= DEBUG ================= */

class _DebugInitButton extends StatefulWidget {
  final FirestoreService firestoreService;
  const _DebugInitButton({required this.firestoreService});

  @override
  State<_DebugInitButton> createState() => _DebugInitButtonState();
}

class _DebugInitButtonState extends State<_DebugInitButton> {
  bool _loading = false;

  Future<void> _init() async {
    setState(() => _loading = true);
    await widget.firestoreService.initializeMovies(force: true);
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khởi tạo phim thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _loading ? null : _init,
      child: _loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Khởi tạo lại phim (Debug)'),
    );
  }
}
