import 'app_info.dart';

enum AppSizePreset {
  any,
  lt10MB,
  between10And50MB,
  between50And100MB,
  between100And500MB,
  gte500MB,
}

extension AppSizePresetX on AppSizePreset {
  String get label {
    switch (this) {
      case AppSizePreset.any:
        return 'Any size';
      case AppSizePreset.lt10MB:
        return '< 10 MB';
      case AppSizePreset.between10And50MB:
        return '10 - 50 MB';
      case AppSizePreset.between50And100MB:
        return '50 - 100 MB';
      case AppSizePreset.between100And500MB:
        return '100 - 500 MB';
      case AppSizePreset.gte500MB:
        return '500+ MB';
    }
  }
}

enum InstallTimePreset {
  any,
  last7Days,
  last30Days,
  last90Days,
  last1Year,
  olderThan1Year,
}

extension InstallTimePresetX on InstallTimePreset {
  String get label {
    switch (this) {
      case InstallTimePreset.any:
        return 'Any time';
      case InstallTimePreset.last7Days:
        return 'Last 7 days';
      case InstallTimePreset.last30Days:
        return 'Last 30 days';
      case InstallTimePreset.last90Days:
        return 'Last 90 days';
      case InstallTimePreset.last1Year:
        return 'Last year';
      case InstallTimePreset.olderThan1Year:
        return 'Older than 1 year';
    }
  }
}

class AppListFilters {
  final Set<FrameworkType> frameworks;
  final AppSizePreset appSizePreset;
  final InstallTimePreset installTimePreset;

  const AppListFilters({
    this.frameworks = const {},
    this.appSizePreset = AppSizePreset.any,
    this.installTimePreset = InstallTimePreset.any,
  });

  AppListFilters copyWith({
    Set<FrameworkType>? frameworks,
    AppSizePreset? appSizePreset,
    InstallTimePreset? installTimePreset,
  }) {
    return AppListFilters(
      frameworks: frameworks ?? this.frameworks,
      appSizePreset: appSizePreset ?? this.appSizePreset,
      installTimePreset: installTimePreset ?? this.installTimePreset,
    );
  }

  bool get hasAnyFilter =>
      frameworks.isNotEmpty ||
      appSizePreset != AppSizePreset.any ||
      installTimePreset != InstallTimePreset.any;
}

