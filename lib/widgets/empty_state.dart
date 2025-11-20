import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const EmptyState({
    super.key,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSearchQuery = searchQuery != null && searchQuery!.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearchQuery ? Icons.search_off : Icons.apps,
            size: 64,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'No apps found matching "$searchQuery"'
                : 'No apps found',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (hasSearchQuery && onClearSearch != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: onClearSearch,
                child: const Text('Clear search'),
              ),
            ),
        ],
      ),
    );
  }
}

