// File này chỉ chứa UI (giao diện) cho màn hình chọn ghế
// Logic xử lý được tách ra file seat_selection_logic.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/navigation/app_navigator.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/services/seat_selection.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;
  final FirestoreService firestoreService;

  const SeatSelectionScreen({
    super.key,
    required this.movie,
    required this.cinema,
    required this.showtime,
    required this.firestoreService,
  });

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final List<String> selectedSeats = [];
  List<String> bookedSeats = [];

  late SeatSelectionLogic logic;

  @override
  void initState() {
    super.initState();
    // Bước 1: Tạo object logic
    logic = SeatSelectionLogic(
      firestoreService: widget.firestoreService,
      showtimeId: widget.showtime.id,
    );
    // Bước 2: Load danh sách ghế đã bán
    loadBookedSeats();
  }

  Future<void> loadBookedSeats() async {
    final booked = await logic.loadBookedSeats();
    
    setState(() {
      bookedSeats = booked;
    });
  }

  void toggleSeat(String seatId) {
    final isBooked = logic.isSeatBooked(seatId, bookedSeats);
    if (isBooked) {
      return;
    }

    final isSelected = logic.isSeatSelected(seatId, selectedSeats);
    
    setState(() {
      if (isSelected) {
        logic.removeSeatFromList(seatId, selectedSeats);
      } else {
        logic.addSeatToList(seatId, selectedSeats);
      }
    });
  }

  void handleContinue() {
    final hasSeats = logic.hasSelectedSeats(selectedSeats);
    if (!hasSeats) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ghế'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final totalPrice = logic.calculateTotalPrice(selectedSeats.length);

    AppNavigator.goToPayment(
      movie: widget.movie,
      cinema: widget.cinema,
      showtime: widget.showtime,
      selectedSeats: selectedSeats,
      totalPrice: totalPrice,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Chọn Ghế',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: AppNavigator.goBack,
        ),
      ),
      body: Column(
        children: [
          BookingInfoWidget(
            movie: widget.movie,
            cinema: widget.cinema,
            showtime: widget.showtime,
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'MÀN HÌNH',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Phần hiển thị bản đồ ghế
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SeatMapWidget(
                    selectedSeats: selectedSeats,
                    bookedSeats: bookedSeats,
                    onSeatTap: toggleSeat,
                    logic: logic,
                  ),
                  const SizedBox(height: 24),
                  // Phần chú thích
                  SeatLegendWidget(),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng cộng',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            logic.formatPrice(logic.calculateTotalPrice(selectedSeats.length)),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: handleContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Tiếp tục',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Hiển thị danh sách ghế đã chọn
                  if (selectedSeats.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Đã chọn: ${selectedSeats.join(", ")}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingInfoWidget extends StatelessWidget {
  final Movie movie;
  final Cinema cinema;
  final Showtime showtime;

  const BookingInfoWidget({
    super.key,
    required this.movie,
    required this.cinema,
    required this.showtime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tên phim
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // Icon và tên rạp
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                cinema.name,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
              const SizedBox(width: 16),
              // Icon và khung giờ
              Icon(Icons.access_time, size: 16, color: Colors.grey.shade400),
              const SizedBox(width: 4),
              Text(
                showtime.time,
                style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SeatMapWidget extends StatelessWidget {
  final List<String> selectedSeats;
  final List<String> bookedSeats;
  final Function(String) onSeatTap;
  final SeatSelectionLogic logic;

  const SeatMapWidget({
    super.key,
    required this.selectedSeats,
    required this.bookedSeats,
    required this.onSeatTap,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Phần hiển thị số cột (1-10)
        Row(
          children: [
            const SizedBox(width: 40), // Khoảng trống cho nhãn hàng
            Expanded(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(6, (rowIndex) {
          final rowLetter = String.fromCharCode(65 + rowIndex);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      rowLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Các ghế trong hàng
                Expanded(
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 10,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1,
                    ),
                    itemCount: 10,
                    itemBuilder: (context, colIndex) {
                      final seatId = '$rowLetter${colIndex + 1}';
                      final isSelected = logic.isSeatSelected(seatId, selectedSeats);
                      final isBooked = logic.isSeatBooked(seatId, bookedSeats);

                      return SeatWidget(
                        seatId: seatId,
                        isSelected: isSelected,
                        isBooked: isBooked,
                        onTap: () {
                          onSeatTap(seatId);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// Widget hiển thị một ghế
class SeatWidget extends StatelessWidget {
  final String seatId;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback onTap;

  const SeatWidget({
    super.key,
    required this.seatId,
    required this.isSelected,
    required this.isBooked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isBooked) {
      backgroundColor = Colors.grey.shade800;
      borderColor = Colors.grey.shade700;
      textColor = Colors.grey.shade600;
    } else if (isSelected) {
      backgroundColor = Colors.redAccent;
      borderColor = Colors.redAccent;
      textColor = Colors.white;
    } else {
      backgroundColor = Colors.grey.shade900;
      borderColor = Colors.grey.shade700;
      textColor = Colors.white;
    }

    return GestureDetector(
      // Nếu ghế đã bán thì không cho nhấn
      onTap: isBooked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            seatId,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class SeatLegendWidget extends StatelessWidget {
  const SeatLegendWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LegendItemWidget(
          color: Colors.grey.shade900,
          borderColor: Colors.grey.shade700,
          label: 'Trống',
        ),
        const SizedBox(width: 16),
        LegendItemWidget(
          color: Colors.redAccent,
          borderColor: Colors.redAccent,
          label: 'Đã chọn',
        ),
        const SizedBox(width: 16),
        LegendItemWidget(
          color: Colors.grey.shade800,
          borderColor: Colors.grey.shade700,
          label: 'Đã bán',
        ),
      ],
    );
  }
}

class LegendItemWidget extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;

  const LegendItemWidget({
    super.key,
    required this.color,
    required this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
