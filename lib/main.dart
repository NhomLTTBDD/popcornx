import 'package:app_movie/screens/welcom_screen.dart';
import 'package:app_movie/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Làm thanh trạng thái trong suốt
    statusBarIconBrightness: Brightness.light, // Chữ trên thanh trạng thái màu trắng
  ));
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