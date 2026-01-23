import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:baitapthuchanh/models/cinema.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

/// BottomSheet widget để chọn rạp chiếu phim
class CinemaSelectionBottomSheet extends StatelessWidget {
  final FirestoreService firestoreService;

  const CinemaSelectionBottomSheet({
    super.key,
    required this.firestoreService,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header với nút đóng
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Chọn Rạp Chiếu Phim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // Danh sách rạp chiếu phim
          Flexible(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: firestoreService.getCinemasStream(),
              builder: (context, snapshot) {
                // Loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                // Error state
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Lỗi: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                // Empty state
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'Chưa có rạp chiếu phim',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                // List cinemas
                final cinemas = snapshot.data!.docs.map((doc) {
                  return Cinema.fromFirestore(doc.data(), doc.id);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: cinemas.length,
                  itemBuilder: (context, index) {
                    final cinema = cinemas[index];
                    return _CinemaItem(
                      cinema: cinema,
                      onTap: () {
                        // Trả về cinemaId khi chọn
                        Navigator.pop(context, cinema.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget hiển thị một item rạp chiếu phim trong danh sách
class _CinemaItem extends StatelessWidget {
  final Cinema cinema;
  final VoidCallback onTap;

  const _CinemaItem({
    required this.cinema,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.3),
          ),
        ),
        child: Row(
          children: [
            // Icon rạp chiếu
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.movie,
                color: Colors.redAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Tên rạp
            Expanded(
              child: Text(
                cinema.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            // Icon mũi tên
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
