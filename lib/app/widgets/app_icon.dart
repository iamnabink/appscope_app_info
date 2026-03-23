import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/app_scanner.dart';

class AppIcon extends StatefulWidget {
  final String packageName;
  final double size;

  const AppIcon({
    super.key,
    required this.packageName,
    this.size = 48,
  });

  @override
  State<AppIcon> createState() => _AppIconState();
}

class _AppIconState extends State<AppIcon> {
  final AppScanner _appScanner = AppScanner();
  Uint8List? _iconData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIcon();
  }

  Future<void> _loadIcon() async {
    final data = await _appScanner.getAppIcon(widget.packageName);
    if (mounted) {
      setState(() {
        _iconData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_iconData == null) {
      return Icon(Icons.android, size: widget.size);
    }

    return Image.memory(
      _iconData!,
      width: widget.size,
      height: widget.size,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.android, size: widget.size);
      },
    );
  }
}
