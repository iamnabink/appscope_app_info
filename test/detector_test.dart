import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:whoamie_app/app/models/app_info.dart';
import 'package:whoamie_app/app/services/framework_detector.dart';

void main() {
  late FrameworkDetector detector;
  late String tempDir;

  setUp(() {
    detector = FrameworkDetector();
    tempDir = Directory.systemTemp.createTempSync('detector_test').path;
  });

  tearDown(() {
    Directory(tempDir).deleteSync(recursive: true);
  });

  Future<String> createMockApk(String name, List<String> files) async {
    final archive = Archive();
    for (final filePath in files) {
      final file = ArchiveFile(filePath, 0, <int>[]);
      archive.addFile(file);
    }
    
    final apkPath = '$tempDir/$name.apk';
    final bytes = ZipEncoder().encode(archive);
    if (bytes != null) {
      await File(apkPath).writeAsBytes(bytes);
    }
    return apkPath;
  }

  test('Detect Flutter', () async {
    final apkPath = await createMockApk('flutter_app', ['lib/arm64-v8a/libflutter.so']);
    final app = AppInfo(
      packageName: 'com.example.flutter',
      appName: 'Flutter App',
      framework: FrameworkType.native,
      apkPath: apkPath,
    );
    
    final result = await detector.detectFramework(app);
    expect(result, FrameworkType.flutter);
  });

  test('Detect React Native', () async {
    final apkPath = await createMockApk('rn_app', ['lib/arm64-v8a/libreactnativejni.so']);
    final app = AppInfo(
      packageName: 'com.example.rn',
      appName: 'RN App',
      framework: FrameworkType.native,
      apkPath: apkPath,
    );
    
    final result = await detector.detectFramework(app);
    expect(result, FrameworkType.reactNative);
  });

  test('Detect Unity', () async {
    final apkPath = await createMockApk('unity_app', ['lib/arm64-v8a/libunity.so']);
    final app = AppInfo(
      packageName: 'com.example.unity',
      appName: 'Unity App',
      framework: FrameworkType.native,
      apkPath: apkPath,
    );
    
    final result = await detector.detectFramework(app);
    expect(result, FrameworkType.unity);
  });

  test('Detect Native (Fallback)', () async {
    final apkPath = await createMockApk('native_app', ['classes.dex']);
    final app = AppInfo(
      packageName: 'com.example.native',
      appName: 'Native App',
      framework: FrameworkType.flutter, // Should reset to native
      apkPath: apkPath,
    );
    
    final result = await detector.detectFramework(app);
    expect(result, FrameworkType.native);
  });
}
