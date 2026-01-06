import 'package:flutter/material.dart';
import '../presentation/navigation/navigation.dart';
import '../presentation/movies/movies.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/profile/profile.dart';
import '../presentation/admin/admin.dart';

class AppRoutes {
  static const String initial = '/';
  static const String movies = '/movies';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const Navigation(initialIndex: 1), // Dashboard as default
    movies: (context) => const Navigation(initialIndex: 0),
    dashboard: (context) => const Navigation(initialIndex: 1),
    profile: (context) => const Navigation(initialIndex: 2),
    admin: (context) => const Admin(),
  };
}
