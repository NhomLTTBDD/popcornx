import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_dashboard.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<String?>(
            future: FirestoreService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data ?? 'user';

              if (role == 'admin') {
                return const AdminDashboard();
              } else {
                // Not admin, logout and show login
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  FirebaseAuth.instance.signOut();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bạn không có quyền truy cập. Chỉ admin mới được phép.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
                return const AdminLoginScreen();
              }
            },
          );
        }

        // Not logged in
        return const AdminLoginScreen();
      },
    );
  }
}
