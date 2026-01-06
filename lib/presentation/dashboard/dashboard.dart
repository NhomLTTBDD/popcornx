import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_bar.dart';
import '../../routes/app_routes.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Netflix-style Top Navigation
          _buildNetflixAppBar(context, theme),
          
          // Hero Banner
          SliverToBoxAdapter(
            child: _buildHeroBanner(context, theme),
          ),
          
          // Content Lists
          _buildContentList(context, theme, 'Trending Now', _getTrendingMovies()),
          _buildContentList(context, theme, 'Popular Movies', _getPopularMovies()),
          _buildContentList(context, theme, 'Top Rated', _getTopRatedMovies()),
          _buildContentList(context, theme, 'Action & Adventure', _getActionMovies()),
          _buildContentList(context, theme, 'Comedies', _getComedyMovies()),
        ],
      ),
    );
  }

  Widget _buildNetflixAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
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
    );
  }

  Widget _buildHeroBanner(BuildContext context, ThemeData theme) {
    return Container(
      height: 60.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background image placeholder
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 0,
            left: 4.w,
            right: 4.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'POPCORNX',
                  style: TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Your Ultimate Movie Analytics Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Explore'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.info_outline),
                      label: const Text('More Info'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentList(
    BuildContext context,
    ThemeData theme,
    String title,
    List<Map<String, dynamic>> movies,
  ) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(
            height: 25.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return _buildMovieCard(context, theme, movies[index]);
              },
            ),
          ),
          SizedBox(height: 2.h),
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
      width: 35.w,
      margin: EdgeInsets.only(right: 2.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
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
          onTap: () {
            _showMovieDetails(context, theme, movie);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie['title'] as String,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
                        size: 16,
                      ),
                      SizedBox(width: 0.5.w),
                      Text(
                        movie['rating'] as String,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                movie['title'] as String,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                movie['description'] as String,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  _buildDetailChip(theme, 'Views', movie['views'] as String),
                  SizedBox(width: 2.w),
                  _buildDetailChip(theme, 'Revenue', movie['revenue'] as String),
                  SizedBox(width: 2.w),
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

  DecorationImage _getGradientImage() {
    // Placeholder gradient - in real app, use actual movie posters
    return DecorationImage(
      image: AssetImage('assets/images/img_app_logo.svg'),
      fit: BoxFit.cover,
      onError: (exception, stackTrace) {
        // Fallback to gradient if image not found
      },
    );
  }

  List<Map<String, dynamic>> _getTrendingMovies() {
    return [
      {'title': 'The Dark Knight', 'rating': '9.0', 'views': '2.5M', 'revenue': '\$1B', 'bookingRate': '95%', 'description': 'Batman faces the Joker in this epic crime thriller.'},
      {'title': 'Inception', 'rating': '8.8', 'views': '2.0M', 'revenue': '\$800M', 'bookingRate': '92%', 'description': 'A mind-bending sci-fi thriller about dreams and reality.'},
      {'title': 'Interstellar', 'rating': '8.6', 'views': '1.8M', 'revenue': '\$700M', 'bookingRate': '90%', 'description': 'Astronauts search for a new home for humanity.'},
      {'title': 'The Matrix', 'rating': '8.7', 'views': '1.9M', 'revenue': '\$750M', 'bookingRate': '91%', 'description': 'A computer hacker discovers the truth about reality.'},
      {'title': 'Pulp Fiction', 'rating': '8.9', 'views': '2.1M', 'revenue': '\$850M', 'bookingRate': '93%', 'description': 'Interconnected stories of crime in Los Angeles.'},
    ];
  }

  List<Map<String, dynamic>> _getPopularMovies() {
    return [
      {'title': 'Avengers: Endgame', 'rating': '8.4', 'views': '3.0M', 'revenue': '\$2.8B', 'bookingRate': '98%', 'description': 'The epic conclusion to the Infinity Saga.'},
      {'title': 'Titanic', 'rating': '7.8', 'views': '2.2M', 'revenue': '\$2.2B', 'bookingRate': '96%', 'description': 'A timeless love story aboard the ill-fated ship.'},
      {'title': 'Avatar', 'rating': '7.8', 'views': '2.0M', 'revenue': '\$2.9B', 'bookingRate': '97%', 'description': 'A marine on an alien planet.'},
    ];
  }

  List<Map<String, dynamic>> _getTopRatedMovies() {
    return [
      {'title': 'The Shawshank Redemption', 'rating': '9.3', 'views': '1.5M', 'revenue': '\$600M', 'bookingRate': '99%', 'description': 'Two imprisoned men bond over years.'},
      {'title': 'The Godfather', 'rating': '9.2', 'views': '1.4M', 'revenue': '\$550M', 'bookingRate': '98%', 'description': 'The aging patriarch of a crime dynasty.'},
    ];
  }

  List<Map<String, dynamic>> _getActionMovies() {
    return [
      {'title': 'John Wick', 'rating': '7.4', 'views': '1.2M', 'revenue': '\$400M', 'bookingRate': '88%', 'description': 'An ex-hit-man seeks revenge.'},
      {'title': 'Mad Max: Fury Road', 'rating': '8.1', 'views': '1.1M', 'revenue': '\$380M', 'bookingRate': '87%', 'description': 'A post-apocalyptic action film.'},
    ];
  }

  List<Map<String, dynamic>> _getComedyMovies() {
    return [
      {'title': 'The Hangover', 'rating': '7.7', 'views': '1.0M', 'revenue': '\$350M', 'bookingRate': '85%', 'description': 'Three friends search for their missing friend.'},
      {'title': 'Superbad', 'rating': '7.6', 'views': '950K', 'revenue': '\$320M', 'bookingRate': '84%', 'description': 'Two high school friends prepare for a party.'},
    ];
  }
}
