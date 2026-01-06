import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sizer/sizer.dart';

import '../../widgets/app_bar.dart';
import '../../routes/app_routes.dart';

class Movies extends StatelessWidget {
  const Movies({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Netflix-style App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                'POPCORNX',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            leadingWidth: 150,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              if (kIsWeb)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.admin);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
              ),
            ],
          ),

          // Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'All Movies',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Movies Grid
          SliverPadding(
            padding: EdgeInsets.all(4.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 2.w,
                mainAxisSpacing: 2.h,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final movie = _getAllMovies()[index];
                  return _buildMovieCard(context, theme, movie);
                },
                childCount: _getAllMovies().length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> movie,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.6),
            theme.colorScheme.primary.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showMovieDetails(context, theme, movie),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(2.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.movie,
                      size: 40,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  movie['title'] as String,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 14,
                    ),
                    SizedBox(width: 0.5.w),
                    Text(
                      movie['rating'] as String,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  '${movie['genre']} • ${movie['rating']}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMovieDetails(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> movie,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                movie['title'] as String,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 20),
                  SizedBox(width: 1.w),
                  Text(
                    movie['rating'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    '${movie['genre']} • ${movie['rating']}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                movie['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 2.h),
              Wrap(
                spacing: 2.w,
                runSpacing: 1.h,
                children: [
                  _buildDetailChip(theme, 'Views', movie['views'] as String),
                  _buildDetailChip(theme, 'Revenue', movie['revenue'] as String),
                  _buildDetailChip(theme, 'Booking', movie['bookingRate'] as String),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(ThemeData theme, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllMovies() {
    return [
      {'title': 'The Dark Knight', 'rating': '9.0', 'genre': 'Action', 'views': '2.5M', 'revenue': '\$1B', 'bookingRate': '95%', 'description': 'Batman faces the Joker in this epic crime thriller.'},
      {'title': 'Inception', 'rating': '8.8', 'genre': 'Sci-Fi', 'views': '2.0M', 'revenue': '\$800M', 'bookingRate': '92%', 'description': 'A mind-bending sci-fi thriller about dreams and reality.'},
      {'title': 'Interstellar', 'rating': '8.6', 'genre': 'Sci-Fi', 'views': '1.8M', 'revenue': '\$700M', 'bookingRate': '90%', 'description': 'Astronauts search for a new home for humanity.'},
      {'title': 'The Matrix', 'rating': '8.7', 'genre': 'Action', 'views': '1.9M', 'revenue': '\$750M', 'bookingRate': '91%', 'description': 'A computer hacker discovers the truth about reality.'},
      {'title': 'Pulp Fiction', 'rating': '8.9', 'genre': 'Crime', 'views': '2.1M', 'revenue': '\$850M', 'bookingRate': '93%', 'description': 'Interconnected stories of crime in Los Angeles.'},
      {'title': 'Avengers: Endgame', 'rating': '8.4', 'genre': 'Action', 'views': '3.0M', 'revenue': '\$2.8B', 'bookingRate': '98%', 'description': 'The epic conclusion to the Infinity Saga.'},
      {'title': 'Titanic', 'rating': '7.8', 'genre': 'Romance', 'views': '2.2M', 'revenue': '\$2.2B', 'bookingRate': '96%', 'description': 'A timeless love story aboard the ill-fated ship.'},
      {'title': 'Avatar', 'rating': '7.8', 'genre': 'Sci-Fi', 'views': '2.0M', 'revenue': '\$2.9B', 'bookingRate': '97%', 'description': 'A marine on an alien planet.'},
    ];
  }
}
