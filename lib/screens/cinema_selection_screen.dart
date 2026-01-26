import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

class CinemaSelectionScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const CinemaSelectionScreen({
    super.key,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      extendBody: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chọn Rạp Chiếu Phim',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: AppNavigator.goBack,
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getCinemasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 48),
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_outlined,
                      color: Colors.grey, size: 64),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có rạp chiếu phim',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          final cinemas = snapshot.data!.docs
              .map((doc) => Cinema.fromFirestore(doc.data(), doc.id))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cinemas.length,
            itemBuilder: (context, index) {
              final cinema = cinemas[index];
              return CinemaItem(
                cinema: cinema,
                onTap: () {
                  AppNavigator.goToCinemaShowtimes(cinema.id, cinema.name);
                },
              );
            },
          );
        },
      ),
      bottomNavigationBar: _BottomNav(
        firestoreService: firestoreService,
        user: FirebaseAuth.instance.currentUser,
      ),
    );
  }
}

class CinemaItem extends StatelessWidget {
  final Cinema cinema;
  final VoidCallback onTap;

  const CinemaItem({
    super.key,
    required this.cinema,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.movie,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                cinema.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final FirestoreService firestoreService;
  final User? user;

  const _BottomNav({
    required this.firestoreService,
    required this.user,
  });

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
            active: false,
            onTap: () => AppNavigator.goToDashboard(replace: true),
          ),
          _NavItem(
            icon: Icons.play_circle_outline,
            active: false,
            onTap: AppNavigator.goToAllMovies,
          ),
          _NavItem(
            icon: Icons.location_on,
            active: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.confirmation_number_outlined,
            active: false,
            onTap: AppNavigator.goToMyTickets,
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