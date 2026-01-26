import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/models/booking.dart';
import 'package:baitapthuchanh/models/movie.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/models/showtime.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:baitapthuchanh/services/my_tickets.dart';

class MyTicketsScreen extends StatelessWidget {
  final FirestoreService firestoreService;

  const MyTicketsScreen({
    super.key,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    final logic = MyTicketsLogic(firestoreService: firestoreService);

    final isLoggedIn = logic.checkUserLoggedIn();

    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F0F),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Vé Đã Mua',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(
          child: Text(
            'Vui lòng đăng nhập để xem vé',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vé Đã Mua',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<List<Booking>>(
        stream: logic.getUserBookingsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return buildEmptyState();
          }

          final bookingList = snapshot.data!;

          if (bookingList.isEmpty) {
            return buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookingList.length,
            itemBuilder: (context, index) {
              // Lấy từng booking trong danh sách
              final booking = bookingList[index];
              // Hiển thị card cho mỗi booking
              return TicketCardWidget(
                booking: booking,
                firestoreService: firestoreService,
                logic: logic,
              );
            },
          );
        },
      ),
    );
  }

  Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.grey,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có vé nào',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy đặt vé để xem phim nhé!',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class TicketCardWidget extends StatelessWidget {
  final Booking booking;
  final FirestoreService firestoreService;
  final MyTicketsLogic logic;

  const TicketCardWidget({
    super.key,
    required this.booking,
    required this.firestoreService,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: firestoreService.getMovieByIdStream(booking.movieId),
        builder: (context, movieSnapshot) {
          Movie? movie;
          if (movieSnapshot.hasData && movieSnapshot.data!.exists) {
            final movieData = movieSnapshot.data!.data()!;
            final movieId = movieSnapshot.data!.id;
            movie = Movie.fromFirestore(movieData, movieId);
          } else {
            movie = null;
          }

          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: firestoreService.getCinemaByIdStream(booking.cinemaId),
            builder: (context, cinemaSnapshot) {
              // Kiểm tra có dữ liệu rạp không
              Cinema? cinema;
              if (cinemaSnapshot.hasData && cinemaSnapshot.data!.exists) {
                // Có dữ liệu thì chuyển đổi thành Cinema object
                final cinemaData = cinemaSnapshot.data!.data()!;
                final cinemaId = cinemaSnapshot.data!.id;
                cinema = Cinema.fromFirestore(cinemaData, cinemaId);
              } else {
                // Không có dữ liệu thì để null
                cinema = null;
              }

              // Bước 3: Lấy thông tin showtime từ Firestore
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: firestoreService.getShowtimeByIdStream(booking.showtimeId),
                builder: (context, showtimeSnapshot) {
                  // Kiểm tra có dữ liệu showtime không
                  Showtime? showtime;
                  if (showtimeSnapshot.hasData && showtimeSnapshot.data!.exists) {
                    // Có dữ liệu thì chuyển đổi thành Showtime object
                    final showtimeData = showtimeSnapshot.data!.data()!;
                    final showtimeId = showtimeSnapshot.data!.id;
                    showtime = Showtime.fromFirestore(showtimeData, showtimeId);
                  } else {
                    // Không có dữ liệu thì để null
                    showtime = null;
                  }

                  // Bước 4: Hiển thị thông tin vé
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Phần header với tên phim và icon QR
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Hiển thị tên phim
                                  Text(
                                    movie?.title ?? 'Đang tải...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  // Hiển thị tên rạp nếu có
                                  if (cinema != null)
                                    Row(
                                      children: [
                                        Icon(Icons.location_on,
                                            size: 14, color: Colors.grey.shade400),
                                        const SizedBox(width: 4),
                                        Text(
                                          cinema.name,
                                          style: TextStyle(
                                            color: Colors.grey.shade400,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            // Icon QR code
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.qr_code,
                                color: Colors.redAccent,
                                size: 32,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: Colors.grey, height: 1),
                        const SizedBox(height: 16),
                        // Thông tin chi tiết
                        InfoRowWidget(
                          icon: Icons.access_time,
                          label: 'Khung giờ',
                          value: showtime?.time ?? 'Đang tải...',
                        ),
                        const SizedBox(height: 12),
                        InfoRowWidget(
                          icon: Icons.event_seat,
                          label: 'Ghế',
                          value: booking.seats.join(', '),
                        ),
                        const SizedBox(height: 12),
                        InfoRowWidget(
                          icon: Icons.calendar_today,
                          label: 'Ngày đặt',
                          value: logic.formatDate(booking.createdAt),
                        ),
                        const SizedBox(height: 16),
                        // Tổng tiền
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng tiền',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),                        
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// Widget hiển thị một dòng thông tin (tách ra để dùng lại)
class InfoRowWidget extends StatelessWidget {
  // Icon hiển thị
  final IconData icon;
  // Nhãn (label)
  final String label;
  // Giá trị (value)
  final String value;

  const InfoRowWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        // Nhãn
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        ),
        const SizedBox(width: 8),
        // Giá trị (căn phải)
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
