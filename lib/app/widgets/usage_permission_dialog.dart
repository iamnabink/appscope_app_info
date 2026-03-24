import 'package:flutter/material.dart';

class UsagePermissionDialog extends StatelessWidget {
  final VoidCallback onGranted;

  const UsagePermissionDialog({super.key, required this.onGranted});

  static Future<void> show(BuildContext context, {required VoidCallback onGranted}) async {
    return showDialog<void>(
      context: context,
      builder: (context) => UsagePermissionDialog(onGranted: onGranted),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.privacy_tip_outlined, color: Colors.blue),
          SizedBox(width: 8),
          Text('Privacy & Usage'),
        ],
      ),
      content: const Text(
        'This app is completely offline. The usage permission is strictly used to show you how much time you spend on each app. We do not collect, store, or share any of your usage data.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onGranted();
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
