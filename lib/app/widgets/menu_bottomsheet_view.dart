// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import  'package:lucide_icons_flutter/lucide_icons.dart';
// import 'package:whoamie_app/core/constants/app_constants.dart';
// import 'package:whoamie_app/core/routes/route_names.dart';
// import 'package:whoamie_app/core/services/in_app_review_service.dart';
// import 'package:whoamie_app/core/services/package_info_service.dart';
// import 'package:whoamie_app/core/theme/app_color_theme.dart';
// import 'package:whoamie_app/core/theme/custom_text_theme.dart';
// import 'package:whoamie_app/core/utils/share_utils.dart';
// import 'package:whoamie_app/core/utils/url_launcher.dart';
// import 'package:whoamie_app/l10n/l10n.dart';
// import 'package:whoamie_app/src/presentation/pages/onboarding/onboarding_view.dart';
// import 'package:whoamie_app/src/presentation/pages/send_feedback_page.dart';
// import 'package:whoamie_app/src/presentation/widgets/cross_promo_card_widget.dart';
// import 'package:whoamie_app/src/presentation/widgets/subscription_card_widget.dart';

// class MenuBottomSheetView extends StatelessWidget {
//   const MenuBottomSheetView({super.key});

//   static Future<void> show(BuildContext context) {
//     return showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => const MenuBottomSheetView(),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final colors = Theme.of(context).extension<AppColorTheme>()!;
//     final texts = Theme.of(context).extension<AppTextTheme>()!;
//     final scheme = Theme.of(context).colorScheme;
//     final l10n = context.l10n;

//     return Material(
//       color: scheme.surface,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: SizedBox(
//         height: size.height * 0.9,
//         width: size.width,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),
//                 Stack(
//                   children: [
//                     GestureDetector(
//                         onTap: () {
//                           Navigator.of(context).pop();
//                         },
//                         child: const Icon(Icons.close, size: 24)),
//                     const SizedBox(width: 10),
//                     Center(
//                       child: Text(l10n.menuBottomSheetSettings,
//                           style: texts.textXlBold
//                               .copyWith(color: scheme.onSurface)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 ...[
//                   // Subscription banner or Hero card
//                   const SubscriptionCardWidget(),
//                   const SizedBox(height: 16),
//                   // Cross-promo card
//                   const CrossPromoCardWidget(),
//                 ],
//                 // App Section
//                 Text(l10n.menuBottomSheetApp,
//                     style: texts.textSmSemiBold
//                         .copyWith(color: colors.grey.shade400)),

//                 const SizedBox(height: 8),

//                 CustomRowTile(
//                   title: l10n.menuBottomSheetDataImportExport,
//                   iconName: LucideIcons.download,
//                   iconColor: Colors.purple,
//                   onTap: () {
//                     context.push(RouteNames.dataImportExport.path);
//                     // WatchRewardedAdService.showWatchAdDialog(context,
//                     //     featureName: context.l10n.themeTogglePageTitle,
//                     //     onFeatureUnlocked: () async {
//                     //   context.push(RouteNames.dataImportExport.path);
//                     // });
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.pdfReportPageTitle,
//                   iconName: LucideIcons.fileText,
//                   iconColor: Colors.blue,
//                   onTap: () {
//                     context.push(RouteNames.pdfReport.path);
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.menuBottomSheetSettings,
//                   iconName: LucideIcons.settings,
//                   iconColor: const Color(0xFF10B981), // Emerald
//                   onTap: () {
//                     context.push(RouteNames.settings.path);
//                   },
//                 ),
//                 // const SizedBox(height: 8),
//                 // CustomRowTile(
//                 //   title: l10n.menuBottomSheetDataBackup,
//                 //   iconName: LucideIcons.databaseBackup,
//                 //   iconColor: Colors.brown,
//                 //   onTap: () {
//                 //   },
//                 // ),
//                 const SizedBox(height: 24),
//                 // Help Section
//                 Text(l10n.menuBottomSheetHelp,
//                     style: texts.textSmSemiBold
//                         .copyWith(color: colors.grey.shade400)),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.menuBottomSheetShowOnboarding,
//                   iconName: LucideIcons.ship,
//                   iconColor: Colors.orange,
//                   onTap: () {
//                     context.pop();
//                     OnboardingView.show(context);
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 // CustomRowTile(
//                 //   title: l10n.menuBottomSheetWhatsNew,
//                 //   iconName: LucideIcons.newspaper,
//                 //   iconColor: Colors.blue,
//                 //   onTap: () {
//                 //     context.push(RouteNames.whatsNew.path);
//                 //   },
//                 // ),
//                 //                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.menuBottomSheetSendFeedback,
//                   iconName: LucideIcons.send,
//                   iconColor: Colors.pinkAccent,
//                   onTap: () {
//                     context.pop();
//                     SendFeedbackPage.show(context);
//                   },
//                 ),

//                 const SizedBox(height: 24),
//                 // About Section
//                 Text(l10n.menuBottomSheetAbout,
//                     style: texts.textSmSemiBold
//                         .copyWith(color: colors.grey.shade400)),

//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.checkForUpdate,
//                   iconName: LucideIcons.check,
//                   iconColor: const Color.fromARGB(255, 95, 47, 254), // Green
//                   onTap: () {
//                     if (Platform.isIOS) {
//                       UrlLauncher.launchWebsite(
//                           context: context, url: AppConstants.appStoreUrl);
//                     } else {
//                       UrlLauncher.launchWebsite(
//                           context: context, url: AppConstants.playStoreUrl);
//                     }
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.rateApp,
//                   iconName: LucideIcons.star,
//                   iconColor: const Color.fromARGB(255, 235, 3, 192), // Green
//                   onTap: InAppReviewService.openStoreListing,
//                 ),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.menuBottomSheetShareApp,
//                   iconName: LucideIcons.share2,
//                   iconColor: const Color(0xFF8B5CF6), // Purple
//                   onTap: ShareUtils.shareApp,
//                 ),
//                 const SizedBox(height: 8),

//                 CustomRowTile(
//                   title: l10n.menuBottomSheetWebsite,
//                   iconName: LucideIcons.globe,
//                   iconColor: const Color(0xFF059669), // Green
//                   onTap: () {
//                     UrlLauncher.launchWebsite(
//                         context: context, url: AppConstants.web);
//                   },
//                 ),

//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.menuBottomSheetFollowOnLinkedin,
//                   iconName: LucideIcons.linkedin,
//                   iconColor: Colors.lightBlue,
//                   onTap: () {
//                     UrlLauncher.launchWebsite(
//                         context: context, url: AppConstants.linkedin);
//                   },
//                 ),
//                 // const SizedBox(height: 8),
//                 // CustomRowTile(
//                 //   title: l10n.menuBottomSheetPrivacyPolicy,
//                 //   iconName: LucideIcons.shield,
//                 //   iconColor: Colors.grey,
//                 //   onTap: () {
//                 //     launchUrl(Uri.parse(AppConstants.appName));
//                 //   },
//                 // ),
//                 const SizedBox(height: 8),
//                 CustomRowTile(
//                   title: l10n.aboutDeveloperPageAppInformation,
//                   iconName: LucideIcons.info,
//                   iconColor: Colors.grey,
//                   onTap: () {
//                     context.push(RouteNames.aboutDeveloper.path);
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 // Version and developer info
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//                   margin: const EdgeInsets.symmetric(horizontal: 5),
//                   decoration: BoxDecoration(
//                     color: scheme.surface.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(
//                       color: scheme.outline.withOpacity(0.1),
//                       width: 0.5,
//                     ),
//                   ),
//                   child: Column(
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             LucideIcons.heart,
//                             color: Colors.red,
//                             size: 16,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             l10n.menuBottomSheetMadeWithLove(
//                                 AppConstants.developerName),
//                             style: texts.textXsMedium.copyWith(
//                               color: colors.grey.shade600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(
//                         l10n.menuBottomSheetVersion(PackageInfoService.version),
//                         style: texts.textXsMedium.copyWith(
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class CustomRowTile extends StatefulWidget {
//   const CustomRowTile({
//     super.key,
//     required this.title,
//     this.onTap,
//     required this.iconName,
//     this.titleColor,
//     this.iconColor,
//     this.trailing,
//   });

//   final String title;
//   final VoidCallback? onTap;
//   final IconData iconName;
//   final Widget? trailing;
//   final Color? titleColor;
//   final Color? iconColor;

//   @override
//   State<CustomRowTile> createState() => _CustomRowTileState();
// }

// class _CustomRowTileState extends State<CustomRowTile>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   bool _isPressed = false;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 150),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: 0.95,
//     ).animate(CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeInOut,
//     ));
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onTapDown(TapDownDetails details) {
//     setState(() {
//       _isPressed = true;
//     });
//     _animationController.forward();
//   }

//   void _onTapUp(TapUpDetails details) {
//     setState(() {
//       _isPressed = false;
//     });
//     _animationController.reverse();
//   }

//   void _onTapCancel() {
//     setState(() {
//       _isPressed = false;
//     });
//     _animationController.reverse();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final scheme = Theme.of(context).colorScheme;
//     final texts = Theme.of(context).extension<AppTextTheme>()!;

//     return GestureDetector(
//       onTapDown: _onTapDown,
//       onTapUp: _onTapUp,
//       onTapCancel: _onTapCancel,
//       onTap: widget.onTap,
//       child: AnimatedBuilder(
//         animation: _animationController,
//         builder: (context, child) {
//           return Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//               margin: const EdgeInsets.symmetric(horizontal: 5),
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(12),
//                 gradient: _isPressed
//                     ? LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           (widget.iconColor ?? scheme.primary).withAlpha(15),
//                           (widget.iconColor ?? scheme.primary).withAlpha(5),
//                         ],
//                       )
//                     : null,
//                 color: _isPressed ? null : scheme.surface.withAlpha(20),
//                 border: Border.all(
//                   color: _isPressed
//                       ? (widget.iconColor ?? scheme.primary).withAlpha(30)
//                       : scheme.outline.withAlpha(10),
//                   width: _isPressed ? 1.0 : 0.5,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: _isPressed
//                         ? (widget.iconColor ?? scheme.primary).withAlpha(20)
//                         : scheme.shadow.withAlpha(5),
//                     blurRadius: _isPressed ? 8 : 2,
//                     offset: Offset(0, _isPressed ? 4 : 1),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   // Leading icon with enhanced gamified decoration
//                   Container(
//                     width: 36,
//                     height: 36,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                         colors: [
//                           (widget.iconColor ?? scheme.primary).withAlpha(20),
//                           (widget.iconColor ?? scheme.primary).withAlpha(5),
//                         ],
//                       ),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(
//                         color:
//                             (widget.iconColor ?? scheme.primary).withAlpha(30),
//                         width: 0.5,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: (widget.iconColor ?? scheme.primary)
//                               .withAlpha(10),
//                           blurRadius: 4,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Stack(
//                       children: [
//                         Center(
//                           child: Icon(
//                             widget.iconName,
//                             color: widget.iconColor ?? scheme.primary,
//                             size: 18,
//                           ),
//                         ),
//                         // Subtle sparkle effect
//                         if (_isPressed)
//                           Positioned(
//                             top: 2,
//                             right: 2,
//                             child: Container(
//                               width: 6,
//                               height: 6,
//                               decoration: BoxDecoration(
//                                 color: Colors.white.withAlpha(150),
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(width: 14),

//                   // Title with enhanced typography
//                   Expanded(
//                     child: Text(
//                       widget.title,
//                       style: texts.textlgMedium.copyWith(
//                         color: _isPressed
//                             ? (widget.iconColor ?? scheme.primary)
//                             : scheme.onSurface,
//                         fontWeight:
//                             _isPressed ? FontWeight.w600 : FontWeight.w500,
//                       ),
//                     ),
//                   ),

//                   // Enhanced trailing icon
//                   Container(
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       color: scheme.outline.withAlpha(10),
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: widget.trailing ??
//                         Icon(
//                           Icons.chevron_right,
//                           color: scheme.outline.withAlpha(120),
//                           size: 16,
//                         ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
