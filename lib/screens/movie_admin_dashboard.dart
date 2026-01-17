import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/services/firestore_service.dart';

class MovieAdminDashboard extends StatefulWidget {
  const MovieAdminDashboard({super.key});

  @override
  State<MovieAdminDashboard> createState() => _MovieAdminDashboardState();
}

class _MovieAdminDashboardState extends State<MovieAdminDashboard> {
  final _titleController = TextEditingController();
  final _imageController = TextEditingController();
  bool _trending = false;
  final _moviesRef = FirebaseFirestore.instance.collection('movies');
  final FirestoreService _firestoreService = FirestoreService();
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAdminRole();
  }

  Future<void> _checkAdminRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await _firestoreService.getUserRole(user.uid);
      setState(() {
        _userRole = role;
        _isLoading = false;
      });

      if (role != 'admin') {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn không có quyền truy cập trang này'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _addMovie() async {
    if (_titleController.text.isEmpty || _imageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _moviesRef.add({
        'title': _titleController.text.trim(),
        'image': _imageController.text.trim(),
        'trending': _trending,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _imageController.clear();
      setState(() => _trending = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm phim thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editMovie(String docId, String currentTitle, String currentImage, bool currentTrending) async {
    _titleController.text = currentTitle;
    _imageController.text = currentImage;
    _trending = currentTrending;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa phim'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Tên phim',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageController,
                decoration: const InputDecoration(
                  labelText: 'URL ảnh',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: _trending,
                    onChanged: (v) => setState(() => _trending = v!),
                  ),
                  const Text('Trending'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _imageController.clear();
              Navigator.pop(context, false);
            },
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isEmpty || _imageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vui lòng điền đầy đủ thông tin'),
                  ),
                );
                return;
              }

              try {
                await _moviesRef.doc(docId).update({
                  'title': _titleController.text.trim(),
                  'image': _imageController.text.trim(),
                  'trending': _trending,
                });

                _titleController.clear();
                _imageController.clear();
                setState(() => _trending = false);

                if (mounted) {
                  Navigator.pop(context, true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật phim thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_userRole != 'admin') {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F0F),
        body: Center(
          child: Text(
            'Bạn không có quyền truy cập',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text('Movie Admin'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildAddMovieForm(),
          const Divider(color: Colors.grey),
          Expanded(child: _buildMovieList()),
        ],
      ),
    );
  }

  Widget _buildAddMovieForm() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _input(
            controller: _titleController,
            hint: 'Movie title',
          ),
          const SizedBox(height: 12),
          _input(
            controller: _imageController,
            hint: 'Image URL',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _trending,
                activeColor: Colors.redAccent,
                onChanged: (v) => setState(() => _trending = v!),
              ),
              const Text(
                'Trending',
                style: TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: _addMovie,
                child: const Text('Add Movie'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovieList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _moviesRef.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = snapshot.data!.docs;

        if (movies.isEmpty) {
          return const Center(
            child: Text(
              'No movies',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (_, index) {
            final movie = movies[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  movie['image'],
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie, color: Colors.grey),
                    );
                  },
                ),
              ),
              title: Text(
                movie['title'],
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                movie['trending'] ? 'Trending' : 'Normal',
                style: TextStyle(
                  color: movie['trending']
                      ? Colors.redAccent
                      : Colors.grey,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _editMovie(
                      movie.id,
                      movie['title'],
                      movie['image'],
                      movie['trending'],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận xóa'),
                          content: const Text('Bạn có chắc chắn muốn xóa phim này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await movie.reference.delete();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã xóa phim'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
