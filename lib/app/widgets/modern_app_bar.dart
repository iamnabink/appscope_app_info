import 'package:flutter/material.dart';

class ModernAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearchExpanded;
  final TextEditingController? searchController;
  final VoidCallback? onSearchToggle;
  final VoidCallback? onSearchClose;
  final VoidCallback? onThemeToggle;
  final VoidCallback? onRefresh;
  final VoidCallback? onAbout;
  final bool isDarkMode;
  final bool isScanning;

  const ModernAppBar({
    super.key,
    required this.isSearchExpanded,
    this.searchController,
    this.onSearchToggle,
    this.onSearchClose,
    this.onThemeToggle,
    this.onRefresh,
    this.onAbout,
    required this.isDarkMode,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 4,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: colorScheme.surfaceTint,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
          ),
        ),
      ),
      title: isSearchExpanded && searchController != null
          ? TextField(
              controller: searchController,
              autofocus: true,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Search apps...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withOpacity(0.5),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            )
          : Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.android,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AppScope',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Framework Detector',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.6),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      actions: [
        if (!isSearchExpanded)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearchToggle,
            tooltip: 'Search apps',
          ),
        if (isSearchExpanded)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onSearchClose,
            tooltip: 'Close search',
          ),
        IconButton(
          icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: onThemeToggle,
          tooltip: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'info' && onAbout != null) {
              onAbout!();
            } else if (value == 'refresh' && onRefresh != null && !isScanning) {
              onRefresh!();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'refresh',
              enabled: !isScanning,
              child: Row(
                children: [
                  Icon(
                    Icons.refresh,
                    size: 20,
                    color: isScanning
                        ? colorScheme.onSurface.withOpacity(0.38)
                        : colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  const Text('Refresh'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: colorScheme.onSurface),
                  const SizedBox(width: 12),
                  const Text('About'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

