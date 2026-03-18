import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../models/app_info.dart';
import '../services/app_scanner.dart';
import '../services/framework_detector.dart';

class AppDetailsScreen extends StatefulWidget {
  final AppInfo app;

  const AppDetailsScreen({super.key, required this.app});

  @override
  State<AppDetailsScreen> createState() => _AppDetailsScreenState();
}

class _AppDetailsScreenState extends State<AppDetailsScreen> {
  final AppScanner _appScanner = AppScanner();
  final FrameworkDetector _frameworkDetector = FrameworkDetector();
  
  AppInfo? _detailedApp;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isUninstalling = false;
  bool _isLoaderVisible = false;

  @override
  void initState() {
    super.initState();
    _loadAppDetails();
  }

  Future<void> _loadAppDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final details = await _appScanner.getAppDetails(widget.app.packageName);
      final framework = await _frameworkDetector.detectFramework(details);
      
      setState(() {
        _detailedApp = details.copyWith(framework: framework);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load app details: $e';
        _isLoading = false;
        _detailedApp = widget.app; // Fallback to basic info
      });
    }
  }

  Future<void> _uninstallApp() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uninstall App'),
        content: Text('Are you sure you want to uninstall "${_detailedApp?.appName ?? widget.app.appName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _performUninstall();
    }
  }

  Future<void> _performUninstall() async {
    final packageName = _detailedApp?.packageName ?? widget.app.packageName;
    setState(() {
      _isUninstalling = true;
    });
    _showUninstallLoader();

    try {
      final success = await _appScanner.uninstallApp(packageName);

      if (!mounted) return;

      _hideUninstallLoader();
      setState(() {
        _isUninstalling = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uninstall request sent. Confirm in the system dialog.'),
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to start uninstall.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      _hideUninstallLoader();
      setState(() {
        _isUninstalling = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to uninstall app: $e')),
      );
    }
  }

  void _showUninstallLoader() {
    if (_isLoaderVisible || !mounted) return;
    _isLoaderVisible = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    ).then((_) {
      _isLoaderVisible = false;
    });
  }

  void _hideUninstallLoader() {
    if (!_isLoaderVisible || !mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return 'Unknown';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
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

  @override
  Widget build(BuildContext context) {
    final app = _detailedApp ?? widget.app;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('App Details'),
      ),
      body: _isLoading
          ? _buildShimmerLoader()
          : _errorMessage != null && _detailedApp == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAppDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // App Icon
                            app.icon != null
                                ? Image.memory(
                                    app.icon!,
                                    width: 96,
                                    height: 96,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.android, size: 96);
                                    },
                                  )
                                : const Icon(Icons.android, size: 96),
                            const SizedBox(height: 16),
                            // App Name
                            Text(
                              app.appName,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Package Name
                            Text(
                              app.packageName,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            // Framework Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _getFrameworkColor(app.framework).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _getFrameworkColor(app.framework),
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                _getFrameworkName(app.framework),
                                style: TextStyle(
                                  color: _getFrameworkColor(app.framework),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Details Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'App Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Version Name', app.versionName ?? 'Unknown'),
                            _buildDetailRow('Version Code', app.versionCode?.toString() ?? 'Unknown'),
                            _buildDetailRow('APK Size', _formatBytes(app.apkSize)),
                            _buildDetailRow('Install Date', app.installDate ?? 'Unknown'),
                            _buildDetailRow('APK Path', app.apkPath ?? 'Unknown'),
                            const SizedBox(height: 8),
                            Text(
                              'System Information',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildDetailRow('Target SDK', app.targetSdkVersion?.toString() ?? 'Unknown'),
                            _buildDetailRow('Min SDK', app.minSdkVersion?.toString() ?? 'Unknown'),
                            _buildDetailRow('System App', app.isSystemApp == true ? 'Yes' : 'No'),
                            _buildDetailRow('Updated System App', app.isUpdatedSystemApp == true ? 'Yes' : 'No'),
                            _buildDetailRow('Enabled', app.isEnabled == true ? 'Yes' : 'No'),
                            const SizedBox(height: 32),
                            // Uninstall Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: app.isSystemApp == true || _isUninstalling
                                    ? null
                                    : _uninstallApp,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Uninstall App'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            if (app.isSystemApp == true)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'System apps cannot be uninstalled',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildShimmerLoader() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerCard(
              child: Column(
                children: [
                  _shimmerCircle(96),
                  const SizedBox(height: 16),
                  _shimmerBar(width: 180, height: 20),
                  const SizedBox(height: 8),
                  _shimmerBar(width: 220, height: 14),
                  const SizedBox(height: 16),
                  _shimmerPill(width: 120, height: 32),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _shimmerBar(width: 160, height: 22),
            const SizedBox(height: 16),
            ...List.generate(
              5,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _shimmerBar(width: 120, height: 16),
                    const SizedBox(width: 16),
                    Expanded(child: _shimmerBar(height: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _shimmerBar(width: 180, height: 22),
            const SizedBox(height: 16),
            ...List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    _shimmerBar(width: 150, height: 16),
                    const SizedBox(width: 16),
                    Expanded(child: _shimmerBar(height: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            _shimmerBar(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
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

  Widget _shimmerPill({double? width, double height = 24}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

