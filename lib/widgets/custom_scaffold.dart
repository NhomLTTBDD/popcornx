import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Cần thêm import này để chỉnh status bar

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    // Cấu hình thanh trạng thái trong suốt cho mọi màn hình sử dụng Scaffold này
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Làm trong suốt thanh trạng thái
      statusBarIconBrightness: Brightness.light, // Các icon pin, sóng sẽ màu trắng
    ));

    return Scaffold(
      // Cho phép nội dung body tràn ra phía sau AppBar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent, // Trong suốt để thấy hình nền
        elevation: 0, // Xóa bóng đổ (tránh tạo đường kẻ)
      ),
      body: Stack(
        children: <Widget>[
          Image.asset(
            'assets/images/bg1.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          SafeArea(
            // TẮT SafeArea ở phía trên để hình nền và màu sắc tràn lên status bar
            top: false,
            child: child!,
          ),
        ],
      ),
    );
  }
}