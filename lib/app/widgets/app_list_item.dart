import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../utils/framework_utils.dart';
import '../utils/format_utils.dart';
import 'app_icon.dart';

class AppListItem extends StatelessWidget {
  final AppInfo app;
  final VoidCallback? onTap;

  const AppListItem({
    super.key,
    required this.app,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final frameworkColor = FrameworkUtils.getFrameworkColor(app.framework);
    final frameworkName = FrameworkUtils.getFrameworkName(app.framework);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        leading: AppIcon(packageName: app.packageName),
        title: Text(
          app.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.packageName,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (app.lastUsedDate != null || (app.appUsage != null && app.appUsage! > 0))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    if (app.lastUsedDate != null)
                      Expanded(
                        child: Text(
                          'Last used: ${app.lastUsedDate}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    if (app.appUsage != null && app.appUsage! > 0)
                      Text(
                        'Usage: ${FormatUtils.formatUsage(app.appUsage)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: frameworkColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: frameworkColor,
              width: 1.5,
            ),
          ),
          child: Text(
            frameworkName,
            style: TextStyle(
              color: frameworkColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}

