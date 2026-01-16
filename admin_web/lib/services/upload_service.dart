import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<String> uploadImage(PlatformFile file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.name.split('.').last;
      final fileName = 'thumbnails/${user.uid}_$timestamp.$extension';

      final ref = _storage.ref().child(fileName);
      
      final blob = html.Blob([file.bytes]);
      final htmlFile = html.File([blob], file.name);
      
      final uploadTask = ref.putBlob(
        blob,
        SettableMetadata(
          contentType: _getContentType(extension),
        ),
      );

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Upload video file (mp4)
  /// Returns download URL
  Future<String> uploadVideo(PlatformFile file) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = file.name.split('.').last;
      final fileName = 'videos/${user.uid}_$timestamp.$extension';

      final ref = _storage.ref().child(fileName);
      
      // Convert PlatformFile to html.Blob for web
      final blob = html.Blob([file.bytes]);
      
      final uploadTask = ref.putBlob(
        blob,
        SettableMetadata(
          contentType: _getContentType(extension),
        ),
      );

      await uploadTask;

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading video: $e');
      rethrow;
    }
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      default:
        return 'application/octet-stream';
    }
  }

  /// Delete file from Storage
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }
}
