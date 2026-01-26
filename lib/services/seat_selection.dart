import 'package:baitapthuchanh/services/firestore_service.dart';

class SeatSelectionLogic {
  final FirestoreService firestoreService;
  final String showtimeId;
  static const int ticketPrice = 60000;

  SeatSelectionLogic({
    required this.firestoreService,
    required this.showtimeId,
  });

  Future<List<String>> loadBookedSeats() async {
    final booked = await firestoreService.getBookedSeats(showtimeId);
    
    final bookedList = booked.toList();
    
    return bookedList;
  }

  bool isSeatBooked(String seatId, List<String> bookedSeats) {
    if (bookedSeats.contains(seatId)) {
      return true;
    } else {
      return false;
    }
  }

  bool isSeatSelected(String seatId, List<String> selectedSeats) {
    if (selectedSeats.contains(seatId)) {
      return true;
    } else {
      return false;
    }
  }

  void addSeatToList(String seatId, List<String> selectedSeats) {
    selectedSeats.add(seatId);
  }

  void removeSeatFromList(String seatId, List<String> selectedSeats) {
    selectedSeats.remove(seatId);
  }

  int calculateTotalPrice(int seatCount) {
    return seatCount * ticketPrice;
  }

  bool hasSelectedSeats(List<String> selectedSeats) {
    if (selectedSeats.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  List<String> generateSeatList() {
    final seats = <String>[];
    
    for (int row = 0; row < 6; row++) {
      final rowLetter = String.fromCharCode(65 + row);
      
      for (int col = 1; col <= 10; col++) {
        final seatId = '$rowLetter$col';
        seats.add(seatId);
      }
    }
    
    return seats;
  }

  String formatPrice(int price) {
    final priceString = price.toStringAsFixed(0);
    
    final formattedPrice = priceString.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) {
        return '${m[1]},';
      },
    );
    
    return '$formattedPriceđ';
  }
}
