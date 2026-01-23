import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_movie/services/firestore_service.dart';
import 'package:app_movie/screens/movie_admin_dashboard.dart';
import 'package:app_movie/screens/profile_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirestoreService _firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      bottomNavigationBar: const _BottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(user: user, firestoreService: _firestoreService),
              const SizedBox(height: 20),
              const _TrendingBanner(),
              const SizedBox(height: 24),
              const _RecommendedSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final User? user;
  final FirestoreService firestoreService;

  const _Header({required this.user, required this.firestoreService});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey, ${user?.displayName ?? 'User'}",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            const Text("Location >", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const Spacer(),
        _CircleIcon(
          icon: Icons.search,
          onTap: () {},
        ),
        const SizedBox(width: 12),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: user != null
              ? firestoreService.getUserStream(user!.uid)
              : null,
          builder: (context, snapshot) {
            final isAdmin = snapshot.data?.data()?['role'] == 'admin';
            return _CircleIcon(
              icon: isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
              onTap: () {
                if (isAdmin) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MovieAdminDashboard(),
                    ),
                  );
                } else {
                  if (user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileScreen(user: user!),
                      ),
                    );
                  }
                }
              },
            );
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

class _TrendingBanner extends StatelessWidget {
  const _TrendingBanner();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('movies')
          .where('trending', isEqualTo: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox(
            height: 240,
            child: Center(
              child: Text(
                'No trending movies',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final movie = snapshot.data!.docs.first;

        return Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                movie['image'],
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 240,
                    color: Colors.grey.shade800,
                    child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                  );
                },
              ),
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
                        movie['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text("Book"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  const _RecommendedSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              "Recommended Movies",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Spacer(),
            Text("See All >", style: TextStyle(color: Colors.redAccent)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('movies')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    'No movies available',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: snapshot.data!.docs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, index) {
                  final movie = snapshot.data!.docs[index];
                  return _MovieCard(
                    title: movie['title'],
                    image: movie['image'],
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

class _MovieCard extends StatelessWidget {
  final String title;
  final String image;

  const _MovieCard({
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              image,
              height: 180,
              width: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 180,
                  width: 140,
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.movie, size: 40, color: Colors.grey),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

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
