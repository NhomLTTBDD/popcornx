import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/screens/profile_screen.dart';
import 'package:baitapthuchanh/screens/movie_detail_screen.dart';
import 'package:baitapthuchanh/screens/movies_by_cinema_screen.dart';
import 'package:baitapthuchanh/screens/cinema_showtimes_screen.dart';
import 'package:baitapthuchanh/screens/cinema_selection_screen.dart';
import 'package:baitapthuchanh/screens/my_tickets_screen.dart';
import 'package:baitapthuchanh/screens/all_movies_screen.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: _currentIndex == 0
          ? AppBar(
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
            )
          : null,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        firestoreService: _firestoreService,
        user: user,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          // Tab 0: Home (Movies)
          _HomeTab(user: user, firestoreService: _firestoreService),
          // Tab 1: All Movies
          AllMoviesScreen(firestoreService: _firestoreService),
          // Tab 2: My Tickets
          MyTicketsScreen(firestoreService: _firestoreService),
          // Tab 3: More (placeholder)
          _MoreTab(),
        ],
      ),
    );
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
  final FirestoreService firestoreService;

  const _TrendingBanner({required this.firestoreService});

  @override
  State<_TrendingBanner> createState() => _TrendingBannerState();
}

class _TrendingBannerState extends State<_TrendingBanner> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _currentPage = 0;

  FirestoreService get _firestoreService => widget.firestoreService;

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

        return Column(
          children: [
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _controller,
                itemCount: movies.length,
                onPageChanged: (index) {
                  if (mounted) {
                    setState(() {
                      _currentPage = index;
                    });
                  }
                },
                itemBuilder: (_, index) {
                  final movie = movies[index];
                  return _BannerItem(
                    movieDoc: movie,
                    firestoreService: widget.firestoreService,
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                movies.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.redAccent
                        : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
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
  final FirestoreService firestoreService;

  const _BannerItem({
    required this.movieDoc,
    required this.firestoreService,
  });

  void _navigateToDetail(BuildContext context) {
    final movie = Movie.fromFirestore(
      movieDoc.data() as Map<String, dynamic>,
      movieDoc.id,
    );
    AppNavigator.goToMovieDetail(movie);
  }

  void _navigateToCinemaSelection(BuildContext context) {
    AppNavigator.goToCinemaSelection();
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
                    onPressed: () => _navigateToCinemaSelection(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                    ),
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
  final FirestoreService firestoreService;

  const _CategorySection({
    required this.category,
    required this.title,
    required this.firestoreService,
  });

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
                    firestoreService: firestoreService,
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
  final FirestoreService firestoreService;

  const _MovieCard({required this.movieDoc, required this.firestoreService});

  void _navigateToDetail(BuildContext context) {
    final movie = Movie.fromFirestore(
      movieDoc.data() as Map<String, dynamic>,
      movieDoc.id,
    );
    AppNavigator.goToMovieDetail(movie);
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

/* ================= HOME TAB ================= */

class _HomeTab extends StatelessWidget {
  final User? user;
  final FirestoreService firestoreService;

  const _HomeTab({
    required this.user,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(user: user),
            const SizedBox(height: 20),
            _TrendingBanner(firestoreService: firestoreService), // 🔥 AUTO SLIDE
            const SizedBox(height: 24),
            _CategorySection(
                category: 'vietnam',
                title: 'Phim Việt Nam',
                firestoreService: firestoreService,
            ),
            const SizedBox(height: 24),
            _CategorySection(
                category: 'international',
                title: 'Phim Quốc Tế',
                firestoreService: firestoreService,
            ),
            const SizedBox(height: 24),
            _CategorySection(
                category: 'horror',
                title: 'Phim Kinh Dị',
                firestoreService: firestoreService,
            ),
            const SizedBox(height: 24),
            _CategorySection(
                category: 'anime',
                title: 'Anime',
                firestoreService: firestoreService,
            ),
            const SizedBox(height: 24),
            _CategorySection(
                category: 'adventure',
                title: 'Phim Thám Hiểm',
                firestoreService: firestoreService,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/* ================= COMING SOON TAB ================= */

class _ComingSoonTab extends StatelessWidget {
  const _ComingSoonTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Sắp ra mắt',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

/* ================= MORE TAB ================= */

class _MoreTab extends StatelessWidget {
  const _MoreTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Thêm',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }
}

/* ================= BOTTOM NAV ================= */

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final FirestoreService firestoreService;
  final User? user;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.firestoreService,
    required this.user,
  });

  void _navigateToCinemaSelection(BuildContext context) {
    AppNavigator.goToCinemaSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavItem(
            icon: Icons.movie,
            active: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.play_circle_outline,
            active: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavItem(
            icon: Icons.location_on,
            active: false,
            onTap: () => _navigateToCinemaSelection(context),
          ),
          _NavItem(
            icon: Icons.confirmation_number_outlined,
            active: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: Icons.person_outline,
            active: false,
            onTap: AppNavigator.goToProfile,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: active ? Colors.redAccent : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: active ? Colors.white : Colors.grey),
      ),
    );
  }
}

