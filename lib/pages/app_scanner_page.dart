import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/app_scanner.dart';
import '../services/framework_detector.dart';
import '../utils/app_filter.dart';
import '../widgets/modern_app_bar.dart';
import '../widgets/search_bar.dart';
import '../widgets/stats_card.dart';
import '../widgets/app_list_item.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/empty_state.dart';
import '../widgets/about_dialog.dart';
import '../screens/app_details_screen.dart';

class AppScannerPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AppScannerPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AppScannerPage> createState() => _AppScannerPageState();
}

class _AppScannerPageState extends State<AppScannerPage> {
  final AppScanner _appScanner = AppScanner();
  final FrameworkDetector _frameworkDetector = FrameworkDetector();
  final TextEditingController _searchController = TextEditingController();

  List<AppInfo> _apps = [];
  List<AppInfo> _filteredApps = [];
  bool _isScanning = false;
  String _errorMessage = '';
  Map<FrameworkType, int> _frameworkCounts = {};
  bool _isSearchExpanded = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterApps);
    _scanApps();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApps);
    _searchController.dispose();
    super.dispose();
  }

  void _filterApps() {
    final query = _searchController.text;
    setState(() {
      _filteredApps = AppFilter.filterApps(_apps, query);
    });
  }

  Future<void> _scanApps() async {
    setState(() {
      _isScanning = true;
      _errorMessage = '';
      _apps = [];
      _frameworkCounts = {};
    });

    try {
      final apps = await _appScanner.scanInstalledApps();

      // Filter out system apps (but keep updated system apps that users can interact with)
      final userApps = apps.where((app) {
        return app.isSystemApp != true || app.isUpdatedSystemApp == true;
      }).toList();

      final List<AppInfo> detectedApps = [];

      // Process apps in batches to avoid blocking UI
      const batchSize = 10;
      for (int i = 0; i < userApps.length; i += batchSize) {
        final batch = userApps.skip(i).take(batchSize).toList();

        await Future.wait(
          batch.map((app) async {
            try {
              final framework = await _frameworkDetector.detectFramework(app);
              return AppInfo(
                packageName: app.packageName,
                appName: app.appName,
                icon: app.icon,
                framework: framework,
                apkPath: app.apkPath,
                isSystemApp: app.isSystemApp,
                isUpdatedSystemApp: app.isUpdatedSystemApp,
              );
            } catch (e) {
              // If detection fails, mark as Native
              return AppInfo(
                packageName: app.packageName,
                appName: app.appName,
                icon: app.icon,
                framework: FrameworkType.native,
                apkPath: app.apkPath,
                isSystemApp: app.isSystemApp,
                isUpdatedSystemApp: app.isUpdatedSystemApp,
              );
            }
          }),
        ).then((results) {
          detectedApps.addAll(results);
        });

        // Update UI periodically during scan
        if (mounted) {
          setState(() {
            _apps = List.from(detectedApps);
            _filteredApps = AppFilter.filterApps(_apps, _searchController.text);
          });
        }
      }

      // Calculate framework counts
      final counts = <FrameworkType, int>{};
      for (var app in detectedApps) {
        counts[app.framework] = (counts[app.framework] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _apps = detectedApps;
          _filteredApps = AppFilter.filterApps(detectedApps, _searchController.text);
          _frameworkCounts = counts;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error scanning apps: $e';
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: ModernAppBar(
        isSearchExpanded: _isSearchExpanded,
        searchController: _isSearchExpanded ? _searchController : null,
        onSearchToggle: () {
          setState(() {
            _isSearchExpanded = true;
          });
        },
        onSearchClose: () {
          setState(() {
            _isSearchExpanded = false;
            _searchController.clear();
          });
        },
        onThemeToggle: widget.onToggleTheme,
        onRefresh: _scanApps,
        onAbout: () => AboutDialogWidget.show(context),
        isDarkMode: widget.isDarkMode,
        isScanning: _isScanning,
      ),
      body: _isScanning
          ? const LoadingShimmer()
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _scanApps,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search Bar (when not expanded in AppBar)
                    if (!_isSearchExpanded && _apps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: SearchBarWidget(
                          controller: _searchController,
                          onClear: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                    // Statistics Card
                    if (_frameworkCounts.isNotEmpty && !_isSearchExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: StatsCard(
                          frameworkCounts: _frameworkCounts,
                          totalApps: _apps.length,
                        ),
                      ),
                    // Search results count
                    if (_isSearchExpanded && _searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              '${_filteredApps.length} result${_filteredApps.length != 1 ? 's' : ''} found',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    // Apps List
                    Expanded(
                      child: _filteredApps.isEmpty
                          ? EmptyState(
                              searchQuery: _searchController.text.isNotEmpty
                                  ? _searchController.text
                                  : null,
                              onClearSearch: _searchController.text.isNotEmpty
                                  ? () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    }
                                  : null,
                            )
                          : ListView.builder(
                              itemCount: _filteredApps.length,
                              itemBuilder: (context, index) {
                                final app = _filteredApps[index];
                                return AppListItem(
                                  app: app,
                                  onTap: () async {
                                    final result = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => AppDetailsScreen(app: app),
                                      ),
                                    );
                                    // If app was uninstalled, refresh the list
                                    if (result == true && mounted) {
                                      _scanApps();
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

