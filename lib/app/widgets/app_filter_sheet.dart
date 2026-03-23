import 'package:flutter/material.dart';

import '../models/app_info.dart';
import '../models/app_list_filters.dart';

class AppFilterSheet extends StatefulWidget {
  final AppListFilters initialFilters;

  const AppFilterSheet({
    super.key,
    required this.initialFilters,
  });

  @override
  State<AppFilterSheet> createState() => _AppFilterSheetState();
}

class _AppFilterSheetState extends State<AppFilterSheet> {
  late Set<FrameworkType> _frameworks;
  late AppSizePreset _appSizePreset;
  late InstallTimePreset _installTimePreset;

  @override
  void initState() {
    super.initState();
    _frameworks = Set<FrameworkType>.from(widget.initialFilters.frameworks);
    _appSizePreset = widget.initialFilters.appSizePreset;
    _installTimePreset = widget.initialFilters.installTimePreset;
  }

  void _toggleFramework(FrameworkType type, bool enabled) {
    setState(() {
      if (enabled) {
        _frameworks.add(type);
      } else {
        _frameworks.remove(type);
      }
    });
  }

  void _reset() {
    setState(() {
      _frameworks = const {};
      _appSizePreset = AppSizePreset.any;
      _installTimePreset = InstallTimePreset.any;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      AppListFilters(
        frameworks: _frameworks,
        appSizePreset: _appSizePreset,
        installTimePreset: _installTimePreset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(null),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              'By Frameworks',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),

            Card(
              margin: EdgeInsets.zero,
              color: scheme.surfaceContainerHighest.withOpacity(0.45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  children: [
                    CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text('React Native'),
                      value: _frameworks.contains(FrameworkType.reactNative),
                      onChanged: (v) =>
                          _toggleFramework(FrameworkType.reactNative, v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text('Flutter'),
                      value: _frameworks.contains(FrameworkType.flutter),
                      onChanged: (v) =>
                          _toggleFramework(FrameworkType.flutter, v ?? false),
                    ),
                    CheckboxListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      title: const Text('Native'),
                      value: _frameworks.contains(FrameworkType.native),
                      onChanged: (v) =>
                          _toggleFramework(FrameworkType.native, v ?? false),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'App size',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<AppSizePreset>(
              value: _appSizePreset,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withOpacity(0.45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              items: AppSizePreset.values
                  .map(
                    (preset) => DropdownMenuItem<AppSizePreset>(
                      value: preset,
                      child: Text(preset.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _appSizePreset = v;
                });
              },
            ),

            const SizedBox(height: 16),

            Text(
              'Install time',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<InstallTimePreset>(
              value: _installTimePreset,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: scheme.surfaceContainerHighest.withOpacity(0.45),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: scheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              items: InstallTimePreset.values
                  .map(
                    (preset) => DropdownMenuItem<InstallTimePreset>(
                      value: preset,
                      child: Text(preset.label),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _installTimePreset = v;
                });
              },
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _reset,
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _apply,
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

