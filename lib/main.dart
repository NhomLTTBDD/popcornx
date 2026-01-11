import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:app_movie/screens/welcom_screen.dart';
import 'package:app_movie/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Làm thanh trạng thái trong suốt
    statusBarIconBrightness: Brightness.light, // Chữ trên thanh trạng thái màu trắng
  ));
  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Popcornx',
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}