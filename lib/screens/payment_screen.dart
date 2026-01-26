import 'package:flutter/material.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import '../models/movie.dart';
import '../models/cinema.dart';
import '../models/showtime.dart';
import '../services/firestore_service.dart';
import '../services/payment.dart';

class PaymentScreen extends StatefulWidget {
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final List<String> selectedSeats;
  final int totalPrice;
  final FirestoreService firestoreService;

  const PaymentScreen({
    super.key,
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.selectedSeats,
    required this.totalPrice,
    required this.firestoreService,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool isProcessing = false;

  late final PaymentLogic logic;

  @override
  void initState() {
    super.initState();
    logic = PaymentLogic(
      firestoreService: widget.firestoreService,
      movie: widget.movie,
      cinema: widget.cinema,
      showtime: widget.showtime,
      selectedSeats: widget.selectedSeats,
      totalPrice: widget.totalPrice,
    );
  }

  Future<void> onPayPressed() async {
    setState(() => isProcessing = true);

    final result = await logic.processPayment();

    if (!mounted) return;

    setState(() => isProcessing = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Lỗi không xác định'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Thanh toán thành công!',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phim: ${widget.movie.title}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text('Ghế: ${widget.selectedSeats.join(", ")}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              'Tổng tiền: ${logic.formatPrice(widget.totalPrice)}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppNavigator.replaceToDashboard();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Thanh Toán')),
      body: Center(
        child: ElevatedButton(
          onPressed: isProcessing ? null : onPayPressed,
          child: isProcessing
              ? const CircularProgressIndicator()
              : const Text('Thanh Toán'),
        ),
      ),
    );
  }
}