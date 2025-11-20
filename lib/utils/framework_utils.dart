import 'package:flutter/material.dart';
import '../models/app_info.dart';

class FrameworkUtils {
  static Color getFrameworkColor(FrameworkType framework) {
    switch (framework) {
      case FrameworkType.flutter:
        return Colors.blue;
      case FrameworkType.reactNative:
        return Colors.green;
      case FrameworkType.unity:
        return Colors.orange;
      case FrameworkType.native:
        return Colors.grey;
    }
  }

  static String getFrameworkName(FrameworkType framework) {
    switch (framework) {
      case FrameworkType.flutter:
        return 'Flutter';
      case FrameworkType.reactNative:
        return 'React Native';
      case FrameworkType.unity:
        return 'Unity';
      case FrameworkType.native:
        return 'Native';
    }
  }
}

