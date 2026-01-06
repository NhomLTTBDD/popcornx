import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/bottom_bar.dart';
import '../dashboard/dashboard.dart';
import '../movies/movies.dart';
import '../profile/profile.dart';
import '../admin/admin.dart';

class Navigation extends StatefulWidget {
  final int initialIndex;

  const Navigation({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _pages = [
    const Movies(),
    const Dashboard(),
    const Profile(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

