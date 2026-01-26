import 'package:flutter/material.dart';

/// File này chứa animation chung cho toàn bộ ứng dụng
/// Animation: Fade + Slide từ phải sang trái
/// Duration: 250-300ms
class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  AppPageRoute({required this.child})
      : super(
          // Thời gian animation: 280ms (nằm trong khoảng 250-300ms)
          transitionDuration: const Duration(milliseconds: 280),
          
          // Thời gian reverse animation (khi quay lại màn hình trước)
          reverseTransitionDuration: const Duration(milliseconds: 280),
          
          // Hàm tạo màn hình đích
          pageBuilder: (context, animation, secondaryAnimation) => child,
          
          // Hàm tạo animation transition
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Animation fade (mờ dần)
            // Từ 0.0 (trong suốt) đến 1.0 (rõ ràng)
            final fadeAnimation = Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              ),
            );

            // Animation slide (trượt từ phải sang trái)
            // Từ 0.3 (dịch sang phải 30% màn hình) đến 0.0 (vị trí gốc)
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.3, 0.0), // Bắt đầu từ bên phải
              end: Offset.zero, // Kết thúc ở vị trí gốc
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            // Kết hợp fade và slide
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
        );
}
