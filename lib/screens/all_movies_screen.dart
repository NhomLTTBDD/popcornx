import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

class AllMoviesScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const AllMoviesScreen({
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
          'Tất Cả Phim',
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
        stream: firestoreService.getAllMoviesStream(),
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
                    'Chưa có phim nào',
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

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _MovieGridCard(
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

class _MovieGridCard extends StatelessWidget {
  final Movie movie;
  final FirestoreService firestoreService;

  const _MovieGridCard({
    required this.movie,
    required this.firestoreService,
  });

  void _navigateToDetail(BuildContext context) {
    AppNavigator.goToMovieDetail(movie);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: movie.image.isNotEmpty
                ? Image.asset(
                    movie.image,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.movie_outlined,
                          color: Colors.grey,
                          size: 48,
                        ),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: 220,
                    color: Colors.grey.shade800,
                    child: const Icon(
                      Icons.movie_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
