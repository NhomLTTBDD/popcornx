import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
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

  void _openVNPayWebView(String paymentUrl) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Lắng nghe mã phản hồi từ VNPay trong URL
            if (request.url.contains('vnp_ResponseCode=00')) {
              Navigator.of(context).pop(); // Đóng WebView
              _handleSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains('vnp_ResponseCode=')) {
              Navigator.of(context).pop();
              _handleFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Thanh toán VNPay")),
          body: WebViewWidget(controller: controller),
        ),
      ),
    );
  }

  void _handleSuccess() async {
    setState(() => isProcessing = true);
    try {
      await widget.firestoreService.saveTicket(
        movie: widget.movie,
        cinema: widget.cinema,
        showtime: widget.showtime,
        seats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _handleFailure();
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Thành công!', style: TextStyle(color: Colors.white)),
        content: const Text('Vé đã được lưu vào mục "Vé đã mua".', style: TextStyle(color: Colors.grey)),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              AppNavigator.replaceToDashboard();
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  void _handleFailure() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Giao dịch thất bại. Vui lòng thử lại!'), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(title: const Text('Xác nhận thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildSummaryCard(),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: isProcessing ? null : () async {
                  setState(() => isProcessing = true);
                  final url = await logic.createVNPayUrl();
                  setState(() => isProcessing = false);
                  if (url != null) _openVNPayWebView(url);
                },
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('THANH TOÁN QUA VNPAY', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(widget.movie.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const Divider(color: Colors.grey, height: 30),
          _rowInfo('Rạp', widget.cinema.name),
          _rowInfo('Suất chiếu', widget.showtime.time),
          _rowInfo('Ghế', widget.selectedSeats.join(', ')),
          _rowInfo('Tổng tiền', logic.formatPrice(widget.totalPrice), isTotal: true),
        ],
      ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(color: isTotal ? Colors.redAccent : Colors.white, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}