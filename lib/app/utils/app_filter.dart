import '../models/app_info.dart';
import '../models/app_list_filters.dart';
import 'framework_utils.dart';
import 'package:intl/intl.dart';

class AppFilter {
  static List<AppInfo> filterApps(List<AppInfo> apps, String query) {
    return filterAppsByCriteria(apps: apps, query: query);
  }

  static List<AppInfo> filterAppsByCriteria({
    required List<AppInfo> apps,
    required String query,
    Set<FrameworkType>? frameworkFilters,
    AppSizePreset appSizePreset = AppSizePreset.any,
    InstallTimePreset installTimePreset = InstallTimePreset.any,
  }) {
    final effectiveFrameworkFilters = frameworkFilters ?? const <FrameworkType>{};

    // Query matches name/package/framework text.
    final bool hasQuery = query.trim().isNotEmpty;
    final lowerQuery = query.toLowerCase().trim();

    // Size filter (bytes) derived from presets.
    const int mb = 1024 * 1024;
    int? minApkSizeBytes;
    int? maxApkSizeBytesExclusive;
    switch (appSizePreset) {
      case AppSizePreset.any:
        break;
      case AppSizePreset.lt10MB:
        maxApkSizeBytesExclusive = 10 * mb;
        break;
      case AppSizePreset.between10And50MB:
        minApkSizeBytes = 10 * mb;
        maxApkSizeBytesExclusive = 50 * mb;
        break;
      case AppSizePreset.between50And100MB:
        minApkSizeBytes = 50 * mb;
        maxApkSizeBytesExclusive = 100 * mb;
        break;
      case AppSizePreset.between100And500MB:
        minApkSizeBytes = 100 * mb;
        maxApkSizeBytesExclusive = 500 * mb;
        break;
      case AppSizePreset.gte500MB:
        minApkSizeBytes = 500 * mb;
        break;
    }

    // Install time filter (date range) derived from presets.
    final DateTime now = DateTime.now();
    DateTime? minInstallDate;
    DateTime? maxInstallDate;
    switch (installTimePreset) {
      case InstallTimePreset.any:
        break;
      case InstallTimePreset.last7Days:
        minInstallDate = now.subtract(const Duration(days: 7));
        break;
      case InstallTimePreset.last30Days:
        minInstallDate = now.subtract(const Duration(days: 30));
        break;
      case InstallTimePreset.last90Days:
        minInstallDate = now.subtract(const Duration(days: 90));
        break;
      case InstallTimePreset.last1Year:
        minInstallDate = now.subtract(const Duration(days: 365));
        break;
      case InstallTimePreset.olderThan1Year:
        maxInstallDate = now.subtract(const Duration(days: 365));
        break;
    }

    return apps.where((app) {
      // 1) Free-text query
      if (hasQuery) {
        final matchesQuery =
            app.appName.toLowerCase().contains(lowerQuery) ||
                app.packageName.toLowerCase().contains(lowerQuery) ||
                FrameworkUtils.getFrameworkName(app.framework)
                    .toLowerCase()
                    .contains(lowerQuery);
        if (!matchesQuery) return false;
      }

      // 2) Framework category selection
      if (effectiveFrameworkFilters.isNotEmpty) {
        bool matchesFramework = false;
        if (effectiveFrameworkFilters.contains(FrameworkType.flutter) &&
            app.framework == FrameworkType.flutter) {
          matchesFramework = true;
        }
        if (effectiveFrameworkFilters.contains(FrameworkType.reactNative) &&
            app.framework == FrameworkType.reactNative) {
          matchesFramework = true;
        }
        if (effectiveFrameworkFilters.contains(FrameworkType.native) &&
            (app.framework == FrameworkType.native ||
                app.framework == FrameworkType.unity)) {
          matchesFramework = true;
        }
        if (!matchesFramework) return false;
      }

      // 3) App size (apkSize in bytes)
      if (appSizePreset != AppSizePreset.any) {
        final apkSizeBytes = app.apkSize;
        if (apkSizeBytes == null) return false;
        if (minApkSizeBytes != null && apkSizeBytes < minApkSizeBytes) {
          return false;
        }
        if (maxApkSizeBytesExclusive != null &&
            apkSizeBytes >= maxApkSizeBytesExclusive) {
          return false;
        }
      }

      // 4) Install time
      if (installTimePreset != InstallTimePreset.any) {
        if (app.installDate == null) return false;

        final parsedDate = _tryParseInstallDate(app.installDate!);
        if (parsedDate == null) return false;

        if (minInstallDate != null && parsedDate.isBefore(minInstallDate)) {
          return false;
        }
        if (maxInstallDate != null && parsedDate.isAfter(maxInstallDate)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  static DateTime? _tryParseInstallDate(String input) {
    try {
      // Matches the Android implementation: "yyyy-MM-dd HH:mm:ss".
      final format = DateFormat('yyyy-MM-dd HH:mm:ss');
      return format.parseStrict(input);
    } catch (_) {
      return null;
    }
  }
}

