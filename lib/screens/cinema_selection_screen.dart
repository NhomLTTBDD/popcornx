import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/screens/cinema_showtimes_screen.dart';

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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getCinemasStream(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error
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

          // Empty
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

          // Data
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CinemaShowtimesScreen(
                        cinemaId: cinema.id,
                        cinemaName: cinema.name,
                        firestoreService: firestoreService,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
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
            // Icon rạp
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

            // Tên rạp
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

            // Mũi tên
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