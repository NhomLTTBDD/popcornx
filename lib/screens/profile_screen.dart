import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:baitapthuchanh/services/remote_config_service.dart';
import 'package:baitapthuchanh/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String slogan = 'Loading...';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Login successful 🎉'),
          content: Text('Welcome ${widget.user.displayName ?? ''}!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });

    _loadRemoteConfig();
  }

  Future<void> _loadRemoteConfig() async {
    await RemoteConfigService().init();
    setState(() {
      slogan = RemoteConfigService().slogan;
    });
  }

  Future<void> _handleSignOut() async {
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
      await _authService.signOut();
      // Navigation will be handled by auth state listener in main.dart
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(
                    widget.user.photoURL ?? 'https://i.pravatar.cc/300',
                  ),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              slogan,
              style: const TextStyle(
                fontSize: 14,
                color: Color.fromARGB(255, 0, 183, 255),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'Name',
              initialValue: widget.user.displayName ?? '',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Email',
              initialValue: widget.user.email ?? '',
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Date of Birth',
              initialValue: '23/05/1995',
              suffixIcon: Icons.keyboard_arrow_down,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    bool readOnly = false,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
