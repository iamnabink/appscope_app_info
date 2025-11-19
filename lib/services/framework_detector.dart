import 'dart:io';
import 'package:archive/archive.dart';
import '../models/app_info.dart';

class FrameworkDetector {
  Future<FrameworkType> detectFramework(AppInfo app) async {
    if (app.apkPath == null || app.apkPath!.isEmpty) {
      return FrameworkType.native;
    }

    try {
      final apkFile = File(app.apkPath!);
      if (!await apkFile.exists()) {
        return FrameworkType.native;
      }

      // Read APK as ZIP
      final bytes = await apkFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Check for Flutter
      if (_hasFlutterAssets(archive)) {
        return FrameworkType.flutter;
      }

      // Check for React Native
      if (_hasReactNative(archive)) {
        return FrameworkType.reactNative;
      }

      // Check for Unity
      if (_hasUnity(archive)) {
        return FrameworkType.unity;
      }

      return FrameworkType.native;
    } catch (e) {
      // If detection fails, return native
      return FrameworkType.native;
    }
  }

  bool _hasFlutterAssets(Archive archive) {
    // Check for flutter_assets folder or libflutter.so
    for (var file in archive) {
      final fileName = file.name.toLowerCase();
      if (fileName.contains('flutter_assets/') || 
          fileName.contains('libflutter.so') ||
          fileName == 'flutter_assets') {
        return true;
      }
    }
    return false;
  }

  bool _hasReactNative(Archive archive) {
    // Check for libreactnativejni.so or assets/index.android.bundle
    for (var file in archive) {
      final fileName = file.name.toLowerCase();
      if (fileName.contains('libreactnativejni.so') ||
          fileName == 'assets/index.android.bundle' ||
          fileName.contains('index.android.bundle')) {
        return true;
      }
    }
    return false;
  }

  bool _hasUnity(Archive archive) {
    // Check for libunity.so or UnityPlayer classes
    for (var file in archive) {
      final fileName = file.name.toLowerCase();
      if (fileName.contains('libunity.so') ||
          fileName.contains('unityplayer') ||
          (fileName.contains('lib/') && fileName.contains('unity'))) {
        return true;
      }
    }
    return false;
  }
}

