import '../models/app_info.dart';
import 'framework_utils.dart';

class AppFilter {
  static List<AppInfo> filterApps(List<AppInfo> apps, String query) {
    if (query.isEmpty) {
      return List.from(apps);
    }

    final lowerQuery = query.toLowerCase().trim();
    return apps.where((app) {
      return app.appName.toLowerCase().contains(lowerQuery) ||
          app.packageName.toLowerCase().contains(lowerQuery) ||
          FrameworkUtils.getFrameworkName(app.framework)
              .toLowerCase()
              .contains(lowerQuery);
    }).toList();
  }
}

