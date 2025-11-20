import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/app_info.dart';
import 'services/app_scanner.dart';
import 'services/framework_detector.dart';
import 'screens/app_details_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Color _seed = Colors.blueAccent;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('theme_mode');
    
    if (themeModeString != null) {
      setState(() {
        switch (themeModeString) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
            break;
        }
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Toggle between light and dark
    final newThemeMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    
    setState(() {
      _themeMode = newThemeMode;
    });

    // Save to SharedPreferences
    String themeModeString;
    switch (newThemeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    await prefs.setString('theme_mode', themeModeString);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        title: 'AppScope',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: _seed),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _seed,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }

    return MaterialApp(
      title: 'AppScope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      home: AppScannerScreen(
        isDarkMode: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo or icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.android,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AppScope',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Framework Detector',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppScannerScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const AppScannerScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<AppScannerScreen> createState() => _AppScannerScreenState();
}

class _AppScannerScreenState extends State<AppScannerScreen> {
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
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredApps = List.from(_apps);
      } else {
        _filteredApps = _apps.where((app) {
          return app.appName.toLowerCase().contains(query) ||
              app.packageName.toLowerCase().contains(query) ||
              _getFrameworkName(app.framework).toLowerCase().contains(query);
        }).toList();
      }
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
        // Exclude system apps, but include updated system apps (apps that were system but user updated)
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
          _filteredApps = List.from(detectedApps);
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

  Color _getFrameworkColor(FrameworkType framework) {
    switch (framework) {
      case FrameworkType.flutter:
        return Colors.blue;
      case FrameworkType.reactNative:
        return Colors.green;
      case FrameworkType.unity:
        return Colors.orange;
      case FrameworkType.native:
        return Colors.grey;
    }
  }

  String _getFrameworkName(FrameworkType framework) {
    switch (framework) {
      case FrameworkType.flutter:
        return 'Flutter';
      case FrameworkType.reactNative:
        return 'React Native';
      case FrameworkType.unity:
        return 'Unity';
      case FrameworkType.native:
        return 'Native';
    }
  }

  Widget _buildSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search apps by name, package, or framework...',
          hintStyle: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalApps = _apps.length;
    final entries = _frameworkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            scheme.primary.withOpacity(0.15),
            scheme.secondary.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Framework Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Insights for detected apps',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$totalApps apps',
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...entries.map((entry) {
            final percent =
                totalApps == 0 ? 0.0 : entry.value / totalApps.toDouble();
            final color = _getFrameworkColor(entry.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getFrameworkName(entry.key),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(0)}% (${entry.value})',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 6,
                      valueColor: AlwaysStoppedAnimation(color),
                      backgroundColor:
                          scheme.onSurface.withOpacity(0.08),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
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
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
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
          if (!_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = true;
                });
              },
              tooltip: 'Search apps',
            ),
          if (_isSearchExpanded)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearchExpanded = false;
                  _searchController.clear();
                });
              },
              tooltip: 'Close search',
            ),
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'info') {
                _showDeveloperInfo();
              } else if (value == 'refresh') {
                if (!_isScanning) {
                  _scanApps();
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'refresh',
                enabled: !_isScanning,
                child: Row(
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 20,
                      color: _isScanning
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
      ),
      body: _isScanning
          ? _buildLoadingShimmer()
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
                        child: _buildSearchBar(context),
                      ),
                    // Statistics Card
                    if (_frameworkCounts.isNotEmpty && !_isSearchExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: _buildStatsCard(context),
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
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchController.text.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.apps,
                                    size: 64,
                                    color: colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'No apps found matching "${_searchController.text}"'
                                        : 'No apps found',
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (_searchController.text.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _searchController.clear();
                                          });
                                        },
                                        child: const Text('Clear search'),
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredApps.length,
                              itemBuilder: (context, index) {
                                final app = _filteredApps[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    leading: app.icon != null
                                        ? Image.memory(
                                            app.icon!,
                                            width: 48,
                                            height: 48,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.android, size: 48);
                                            },
                                          )
                                        : const Icon(Icons.android, size: 48),
                                    title: Text(
                                      app.appName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      app.packageName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getFrameworkColor(app.framework)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _getFrameworkColor(app.framework),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Text(
                                        _getFrameworkName(app.framework),
                                        style: TextStyle(
                                          color: _getFrameworkColor(app.framework),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => AppDetailsScreen(app: app),
                                        ),
                                      );
                                      // If app was uninstalled, refresh the list
                                      if (result == true) {
                                        _scanApps();
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: _shimmerCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBar(width: 180, height: 22),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: List.generate(
                    3,
                    (index) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _shimmerCircle(12),
                        const SizedBox(width: 6),
                        _shimmerBar(width: 80, height: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _shimmerBar(width: 140, height: 18),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 8,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _shimmerCard(
                child: Row(
                  children: [
                    _shimmerCircle(48),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _shimmerBar(height: 16),
                          const SizedBox(height: 8),
                          _shimmerBar(width: 180, height: 12),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    _shimmerPill(width: 80, height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _shimmerBar({double? width, double height = 12}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _shimmerCircle(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _shimmerPill({double? width, double height = 24}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  void _showDeveloperInfo() {
    showDialog(
      context: context,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;
        return AlertDialog(
          title: const Text('About AppScope'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Developer',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text('Nabraj Khadka'),
              const SizedBox(height: 12),
              Text(
                'Website',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'https://www.whoamie.com/',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'GitHub',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'https://github.com/iamnabink',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'LinkedIn',
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              SelectableText(
                'https://www.linkedin.com/in/iamnabink/',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Version 1.0.0+1',
                style: textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
