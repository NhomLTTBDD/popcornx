import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import '../services/upload_service.dart';
import '../services/firestore_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _uploadService = UploadService();
  final _firestoreService = FirestoreService();
  final _auth = FirebaseAuth.instance;

  PlatformFile? _thumbnailFile;
  PlatformFile? _videoFile;
  bool _isUploading = false;
  bool _trending = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _thumbnailFile = result.files.single;
      });
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowedExtensions: ['mp4'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _videoFile = result.files.single;
      });
    }
  }

  Future<void> _uploadMovie() async {
    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh thumbnail'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn file video'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Upload thumbnail
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang upload ảnh thumbnail...'),
          duration: Duration(seconds: 2),
        ),
      );

      final thumbnailUrl = await _uploadService.uploadImage(_thumbnailFile!);
      setState(() => _uploadProgress = 0.3);

      // Upload video
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đang upload video (có thể mất vài phút)...'),
          duration: Duration(seconds: 2),
        ),
      );

      final videoUrl = await _uploadService.uploadVideo(_videoFile!);
      setState(() => _uploadProgress = 0.8);

      // Save to Firestore
      await _firestoreService.addMovie(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        thumbnailUrl: thumbnailUrl,
        videoUrl: videoUrl,
        trending: _trending,
      );

      setState(() => _uploadProgress = 1.0);

      // Reset form
      _titleController.clear();
      _descriptionController.clear();
      setState(() {
        _thumbnailFile = null;
        _videoFile = null;
        _trending = false;
        _uploadProgress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload phim thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _auth.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left panel - Upload form
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Thêm phim mới',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tên phim *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập tên phim';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Thumbnail picker
                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickThumbnail,
                        icon: const Icon(Icons.image),
                        label: Text(
                          _thumbnailFile != null
                              ? _thumbnailFile!.name
                              : 'Chọn ảnh thumbnail (JPG/PNG)',
                        ),
                      ),
                      if (_thumbnailFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Đã chọn: ${_thumbnailFile!.name} (${(_thumbnailFile!.size / 1024).toStringAsFixed(2)} KB)',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Video picker
                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickVideo,
                        icon: const Icon(Icons.video_library),
                        label: Text(
                          _videoFile != null
                              ? _videoFile!.name
                              : 'Chọn file video (MP4)',
                        ),
                      ),
                      if (_videoFile != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Đã chọn: ${_videoFile!.name} (${(_videoFile!.size / 1024 / 1024).toStringAsFixed(2)} MB)',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      CheckboxListTile(
                        title: const Text('Phim trending'),
                        value: _trending,
                        onChanged: _isUploading
                            ? null
                            : (value) {
                                setState(() {
                                  _trending = value ?? false;
                                });
                              },
                      ),
                      const SizedBox(height: 24),
                      if (_isUploading) ...[
                        LinearProgressIndicator(value: _uploadProgress),
                        const SizedBox(height: 8),
                        Text(
                          'Đang upload... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                      ],
                      ElevatedButton(
                        onPressed: _isUploading ? null : _uploadMovie,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Upload phim',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Right panel - Movies list
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh sách phim',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: StreamBuilder(
                      stream: _firestoreService.getMovies(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text('Chưa có phim nào'),
                          );
                        }

                        final movies = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: movies.length,
                          itemBuilder: (context, index) {
                            final movie = movies[index];
                            final data = movie.data() as Map<String, dynamic>;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                leading: data['thumbnailUrl'] != null
                                    ? Image.network(
                                        data['thumbnailUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.movie);
                                        },
                                      )
                                    : const Icon(Icons.movie),
                                title: Text(
                                  data['title'] ?? 'No title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data['description'] != null)
                                      Text(
                                        data['description'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (data['trending'] == true)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'TRENDING',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Xóa phim'),
                                        content: const Text(
                                          'Bạn có chắc chắn muốn xóa phim này?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Hủy'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _firestoreService.deleteMovie(
                                        movie.id,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('Đã xóa phim'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
