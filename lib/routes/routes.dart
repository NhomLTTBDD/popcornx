import 'package:flutter/material.dart';
import 'package:baitapthuchanh/screens/welcome_screen.dart';
import 'package:baitapthuchanh/screens/signin_screen.dart';
import 'package:baitapthuchanh/screens/signup_screen.dart';
import 'package:baitapthuchanh/screens/dashboard_screen.dart';
import 'package:baitapthuchanh/screens/movie_admin_dashboard.dart';
import 'package:baitapthuchanh/screens/profile_screen.dart';
import 'package:baitapthuchanh/screens/forget_password_screen.dart';

class AppRoutes {
  static const String welcome = '/';
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String dashboard = '/dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String profile = '/profile';
  static const String forgetPassword = '/forget-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case signIn:
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const MovieAdminDashboard());
      case forgetPassword:
        return MaterialPageRoute(builder: (_) => const ForgetPasswordScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
