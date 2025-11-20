import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../utils/framework_utils.dart';

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
        leading: app.icon != null
            ? Image.memory(
                app.icon!,
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.android, size: 48);
                },
              )
            : const Icon(Icons.android, size: 48),
        title: Text(
          app.appName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          app.packageName,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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

