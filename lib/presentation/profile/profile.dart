import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Netflix-style App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Text(
                'POPCORNX',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            leadingWidth: 150,
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              if (kIsWeb)
                IconButton(
                  icon: const Icon(Icons.admin_panel_settings),
                  tooltip: 'Admin',
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.admin);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Padding(
                padding: EdgeInsets.only(right: 4.w),
                child: IconButton(
                  icon: const Icon(Icons.account_circle),
                  onPressed: () {},
                ),
              ),
            ],
          ),

          // Profile Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Profile Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Admin User',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'admin@popcornx.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Account Info Card
                  _buildInfoCard(
                    theme,
                    'Account Information',
                    [
                      {'label': 'Full Name', 'value': 'Admin User'},
                      {'label': 'Email', 'value': 'admin@popcornx.com'},
                      {'label': 'Role', 'value': 'Administrator'},
                      {'label': 'Member Since', 'value': 'January 2024'},
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Settings Card
                  _buildSettingsCard(context, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, String title, List<Map<String, String>> items) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 2.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      item['value']!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSettingItem(
            context,
            theme,
            Icons.settings,
            'Settings',
            'Manage your preferences',
            () {},
          ),
          Divider(color: Colors.white.withValues(alpha: 0.1), height: 2.h),
          _buildSettingItem(
            context,
            theme,
            Icons.logout,
            'Logout',
            'Sign out of your account',
            () {},
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? theme.colorScheme.error : Colors.white,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.white.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }
}
