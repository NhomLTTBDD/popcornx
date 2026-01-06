import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar for streaming platform analytics.
/// Implements clean, executive-level sophistication with minimal visual noise.
///
/// Variants:
/// - standard: Default app bar with title and optional actions
/// - search: App bar with integrated search field
/// - detail: App bar for detail screens with back button
enum CustomAppBarVariant { standard, search, detail }

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// App bar title
  final String? title;

  /// App bar variant
  final CustomAppBarVariant variant;

  /// Leading widget (optional, defaults to back button for detail variant)
  final Widget? leading;

  /// Action widgets (optional)
  final List<Widget>? actions;

  /// Search controller for search variant
  final TextEditingController? searchController;

  /// Search hint text
  final String searchHint;

  /// Search callback
  final Function(String)? onSearchChanged;

  /// Whether to show elevation
  final bool showElevation;

  const CustomAppBar({
    Key? key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.leading,
    this.actions,
    this.searchController,
    this.searchHint = 'Search movies...',
    this.onSearchChanged,
    this.showElevation = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, isDark);
      case CustomAppBarVariant.detail:
        return _buildDetailAppBar(context, theme, isDark);
      case CustomAppBarVariant.standard:
      default:
        return _buildStandardAppBar(context, theme, isDark);
    }
  }

  Widget _buildStandardAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: showElevation ? 2.0 : 0,
      centerTitle: false,
      leading: leading,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.appBarTheme.foregroundColor,
                letterSpacing: 0.15,
              ),
            )
          : null,
      actions: actions,
    );
  }

  Widget _buildSearchAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: showElevation ? 2.0 : 0,
      centerTitle: false,
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: searchHint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF666666) : const Color(0xFF999999),
            ),
            prefixIcon: Icon(
              Icons.search,
              size: 20,
              color: isDark ? const Color(0xFFB3B3B3) : const Color(0xFF666666),
            ),
            suffixIcon: searchController?.text.isNotEmpty ?? false
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      size: 20,
                      color: isDark
                          ? const Color(0xFFB3B3B3)
                          : const Color(0xFF666666),
                    ),
                    onPressed: () {
                      searchController?.clear();
                      onSearchChanged?.call('');
                    },
                    tooltip: 'Clear',
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
      ),
      actions: actions,
    );
  }

  Widget _buildDetailAppBar(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      elevation: showElevation ? 2.0 : 0,
      centerTitle: false,
      leading:
          leading ??
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: theme.appBarTheme.foregroundColor,
                letterSpacing: 0.15,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      actions: actions,
    );
  }
}
