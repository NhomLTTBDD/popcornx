import 'package:baitapthuchanh/models/booking.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyTicketsLogic {
  final FirestoreService firestoreService;

  MyTicketsLogic({
    required this.firestoreService,
  });

  bool checkUserLoggedIn() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }

  String? getUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return null;
    }
  }

  Stream<List<Booking>> getUserBookingsStream() {
    final userId = getUserId();
    
    if (userId == null) {
      return Stream.value([]);
    }

    return firestoreService.getUserBookingsStream(userId);
  }

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }
    
    final day = date.day;
    final month = date.month;
    final year = date.year;
    
    return '$day/$month/$year';
  }
}
