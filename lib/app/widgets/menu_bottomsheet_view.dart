import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import '../utils/app_constants.dart';

class MenuBottomSheetView extends StatelessWidget {
  final VoidCallback? onRefresh;

  const MenuBottomSheetView({super.key, this.onRefresh});

  static Future<void> show(BuildContext context, {VoidCallback? onRefresh}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MenuBottomSheetView(onRefresh: onRefresh),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: scheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Menu',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Promo Section
                  const Text(
                    'Try Our Other Apps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _PromoCard(
                          title: 'TearLog',
                          subtitle: 'Cry Tracker',
                          color: Colors.blue.shade100,
                          iconColor: Colors.blue,
                          icon: LucideIcons.droplets,
                          onTap: () => _launchStore(
                            AppConstants.tearLogPlayStoreUrl,
                            AppConstants.tearLogAppStoreUrl,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PromoCard(
                          title: 'Couple Tale',
                          subtitle: 'Couple App',
                          color: Colors.pink.shade100,
                          iconColor: Colors.pink,
                          icon: LucideIcons.heart,
                          onTap: () => _launchStore(
                            AppConstants.coupleTalePlayStoreUrl,
                            AppConstants.coupleTaleAppStoreUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Help Section
                  const Text(
                    'Help & Support',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'Send Feedback',
                    iconName: LucideIcons.send,
                    iconColor: Colors.amber,
                    onTap: _sendFeedback,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // About Section
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'Check for Update',
                    iconName: LucideIcons.refreshCw,
                    iconColor: Colors.green,
                    onTap: () => _launchStore(
                      AppConstants.playStoreUrl,
                      AppConstants.appStoreUrl,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'Rate App',
                    iconName: LucideIcons.star,
                    iconColor: Colors.orange,
                    onTap: _rateApp,
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'Share App',
                    iconName: LucideIcons.share2,
                    iconColor: Colors.blue,
                    onTap: _shareApp,
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'Refresh Scan',
                    iconName: LucideIcons.rotateCw,
                    iconColor: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      if (onRefresh != null) {
                        onRefresh!();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  CustomRowTile(
                    title: 'App Information',
                    iconName: LucideIcons.info,
                    iconColor: Colors.grey,
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.android, size: 48),
                        applicationLegalese: '© 2026 ${AppConstants.developerName}',
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Footer
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(LucideIcons.heart, color: Colors.red, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Made with love by ${AppConstants.developerName}',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FutureBuilder<PackageInfo>(
                          future: PackageInfo.fromPlatform(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                'Version ${snapshot.data!.version}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: scheme.onSurface.withOpacity(0.4),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialIcon(
                              icon: LucideIcons.globe,
                              onTap: () => _launchUrl(AppConstants.web),
                            ),
                            const SizedBox(width: 20),
                            _SocialIcon(
                              icon: LucideIcons.linkedin,
                              onTap: () => _launchUrl(AppConstants.linkedin),
                            ),
                            const SizedBox(width: 20),
                            _SocialIcon(
                              icon: LucideIcons.mail,
                              onTap: _sendFeedback,
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _launchStore(String playUrl, String appUrl) async {
    final url = Platform.isAndroid ? playUrl : appUrl;
    _launchUrl(url);
  }

  void _sendFeedback() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: AppConstants.email,
      query: 'subject=AppScope Feedback&body=Hi ${AppConstants.developerName},',
    );
    if (await canLaunchUrl(params)) {
      await launchUrl(params);
    }
  }

  void _rateApp() async {
    final InAppReview inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    } else {
      _launchStore(AppConstants.playStoreUrl, AppConstants.appStoreUrl);
    }
  }

  void _shareApp() {
    Share.share(
      'Check out AppScope Framework Detector! Find out what frameworks your favorite apps use.\n\nPlay Store: ${AppConstants.playStoreUrl}',
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  const _PromoCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomRowTile extends StatelessWidget {
  final String title;
  final IconData iconName;
  final Color iconColor;
  final VoidCallback onTap;

  const CustomRowTile({
    super.key,
    required this.title,
    required this.iconName,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(iconName, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: scheme.onSurface.withOpacity(0.2),
        size: 20,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: scheme.onSurface.withOpacity(0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: scheme.onSurface.withOpacity(0.6),
        ),
      ),
    );
  }
}
