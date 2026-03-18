import 'dart:typed_data';

enum FrameworkType {
  flutter,
  reactNative,
  unity,
  native,
}

class AppInfo {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final FrameworkType framework;
  final String? apkPath;
  
  // Additional details (optional, populated when viewing details)
  final String? versionName;
  final int? versionCode;
  final String? installDate;
  final int? apkSize;
  final bool? isSystemApp;
  final bool? isUpdatedSystemApp;
  final bool? isEnabled;
  final int? targetSdkVersion;
  final int? minSdkVersion;

  AppInfo({
    required this.packageName,
    required this.appName,
    this.icon,
    required this.framework,
    this.apkPath,
    this.versionName,
    this.versionCode,
    this.installDate,
    this.apkSize,
    this.isSystemApp,
    this.isUpdatedSystemApp,
    this.isEnabled,
    this.targetSdkVersion,
    this.minSdkVersion,
  });
  
  AppInfo copyWith({
    String? packageName,
    String? appName,
    Uint8List? icon,
    FrameworkType? framework,
    String? apkPath,
    String? versionName,
    int? versionCode,
    String? installDate,
    int? apkSize,
    bool? isSystemApp,
    bool? isUpdatedSystemApp,
    bool? isEnabled,
    int? targetSdkVersion,
    int? minSdkVersion,
  }) {
    return AppInfo(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      icon: icon ?? this.icon,
      framework: framework ?? this.framework,
      apkPath: apkPath ?? this.apkPath,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      installDate: installDate ?? this.installDate,
      apkSize: apkSize ?? this.apkSize,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isUpdatedSystemApp: isUpdatedSystemApp ?? this.isUpdatedSystemApp,
      isEnabled: isEnabled ?? this.isEnabled,
      targetSdkVersion: targetSdkVersion ?? this.targetSdkVersion,
      minSdkVersion: minSdkVersion ?? this.minSdkVersion,
    );
  }
}

