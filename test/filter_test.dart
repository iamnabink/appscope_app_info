import 'package:flutter_test/flutter_test.dart';
import 'package:whoamie_app/app/models/app_info.dart';
import 'package:whoamie_app/app/models/app_list_filters.dart';
import 'package:whoamie_app/app/utils/app_filter.dart';

void main() {
  final now = DateTime.now();
  final last7Days = now.subtract(const Duration(days: 5)).toString().substring(0, 19);
  final olderThan1Year = now.subtract(const Duration(days: 400)).toString().substring(0, 19);

  final List<AppInfo> testApps = [
    AppInfo(
      packageName: 'com.example.flutter',
      appName: 'Flutter App',
      framework: FrameworkType.flutter,
      apkSize: 5 * 1024 * 1024, // 5 MB
      installDate: last7Days,
    ),
    AppInfo(
      packageName: 'com.example.rn',
      appName: 'RN App',
      framework: FrameworkType.reactNative,
      apkSize: 25 * 1024 * 1024, // 25 MB
      installDate: last7Days,
    ),
    AppInfo(
      packageName: 'com.example.unity',
      appName: 'Unity Game',
      framework: FrameworkType.unity,
      apkSize: 150 * 1024 * 1024, // 150 MB
      installDate: olderThan1Year,
    ),
    AppInfo(
      packageName: 'com.example.native',
      appName: 'Native App',
      framework: FrameworkType.native,
      apkSize: 2 * 1024 * 1024, // 2 MB
      installDate: olderThan1Year,
    ),
  ];

  group('AppFilter Tests', () {
    test('Filter by query', () {
      final results = AppFilter.filterAppsByCriteria(apps: testApps, query: 'Unity');
      expect(results.length, 1);
      expect(results.first.appName, 'Unity Game');
    });

    test('Filter by framework - Flutter', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        frameworkFilters: {FrameworkType.flutter},
      );
      expect(results.length, 1);
      expect(results.first.framework, FrameworkType.flutter);
    });

    test('Filter by framework - Unity (Separation from Native)', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        frameworkFilters: {FrameworkType.unity},
      );
      expect(results.length, 1);
      expect(results.first.framework, FrameworkType.unity);

      final nativeResults = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        frameworkFilters: {FrameworkType.native},
      );
      expect(nativeResults.length, 1);
      expect(nativeResults.first.framework, FrameworkType.native);
    });

    test('Filter by size - LT 10MB', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        appSizePreset: AppSizePreset.lt10MB,
      );
      expect(results.length, 2); // Flutter (5MB) and Native (2MB)
    });

    test('Filter by size - Between 100 and 500 MB', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        appSizePreset: AppSizePreset.between100And500MB,
      );
      expect(results.length, 1); // Unity (150MB)
    });

    test('Filter by install time - Last 7 days', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        installTimePreset: InstallTimePreset.last7Days,
      );
      expect(results.length, 2); // Flutter and RN
    });

    test('Filter by install time - Older than 1 year', () {
      final results = AppFilter.filterAppsByCriteria(
        apps: testApps,
        query: '',
        installTimePreset: InstallTimePreset.olderThan1Year,
      );
      expect(results.length, 2); // Unity and Native
    });
  });
}
