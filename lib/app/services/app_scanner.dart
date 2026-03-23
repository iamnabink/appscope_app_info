import 'package:flutter/services.dart';
import '../models/app_info.dart';

class AppScanner {
  static const MethodChannel _channel = MethodChannel('app_scanner');

  Future<List<AppInfo>> scanInstalledApps() async {
    try {
      final List<dynamic> apps = await _channel.invokeMethod('getInstalledApps');
      return apps.map((app) {
        return AppInfo(
          packageName: app['packageName'] ?? '',
          appName: app['appName'] ?? 'Unknown',
          icon: null, // Icons are now loaded lazily
          framework: FrameworkType.native, // Will be detected later
          apkPath: app['apkPath'],
          apkSize: app['apkSize'] != null ? (app['apkSize'] as num).toInt() : null,
          installDate: app['installDate'],
          isSystemApp: app['isSystemApp'] ?? false,
          isUpdatedSystemApp: app['isUpdatedSystemApp'] ?? false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to scan apps: $e');
    }
  }

  Future<Uint8List?> getAppIcon(String packageName) async {
    try {
      final dynamic iconData = await _channel.invokeMethod('getAppIcon', {'packageName': packageName});
      if (iconData == null) return null;
      return Uint8List.fromList(List<int>.from(iconData));
    } catch (e) {
      return null;
    }
  }

  Future<AppInfo> getAppDetails(String packageName) async {
    try {
      final Map<dynamic, dynamic>? details = await _channel.invokeMethod(
        'getAppDetails',
        {'packageName': packageName},
      );
      
      if (details == null) {
        throw Exception('App details not found');
      }
      
      return AppInfo(
        packageName: details['packageName'] ?? '',
        appName: details['appName'] ?? 'Unknown',
        icon: null, // Icons are now loaded lazily or via getAppIcon
        framework: FrameworkType.native, // Will be detected later if needed
        apkPath: details['apkPath'],
        versionName: details['versionName'],
        versionCode: details['versionCode'] != null 
            ? (details['versionCode'] as num).toInt() 
            : null,
        installDate: details['installDate'],
        apkSize: details['apkSize'] != null 
            ? (details['apkSize'] as num).toInt() 
            : null,
        isSystemApp: details['isSystemApp'],
        isUpdatedSystemApp: details['isUpdatedSystemApp'],
        isEnabled: details['isEnabled'],
        targetSdkVersion: details['targetSdkVersion'],
        minSdkVersion: details['minSdkVersion'],
      );
    } catch (e) {
      throw Exception('Failed to get app details: $e');
    }
  }

  Future<bool> uninstallApp(String packageName) async {
    try {
      final result = await _channel.invokeMethod('uninstallApp', {'packageName': packageName});
      return result == true;
    } on PlatformException catch (e) {
      throw Exception('Failed to uninstall app: ${e.message}');
    } catch (e) {
      throw Exception('Failed to uninstall app: $e');
    }
  }
}

