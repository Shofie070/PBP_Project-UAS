import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import '../../../shared/services/localization_service.dart';
import '../../../shared/services/theme_service.dart';
import '../../../shared/routes/app_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth > 900;
      double responsiveSize(double mobileSp, double desktopPx) =>
          isDesktop ? desktopPx : mobileSp.sp;

      return ValueListenableBuilder<String>(
        valueListenable: ThemeService.languageNotifier,
        builder: (context, currentLang, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(
                LocalizationService.get(currentLang, 'settings'),
                style: TextStyle(
                    fontSize: responsiveSize(14, 20),
                    fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, size: responsiveSize(16, 20)),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.home, size: responsiveSize(16, 20)),
                  tooltip: 'Home',
                  onPressed: () => context.go(AppRoutes.dashboard),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(isDesktop ? 20 : 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      context,
                      LocalizationService.get(currentLang, 'appearance'),
                      responsiveSize),
                  SizedBox(height: isDesktop ? 10 : 1.h),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        // Dark Mode Toggle
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: ThemeService.themeModeNotifier,
                          builder: (context, mode, _) {
                            return SwitchListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: isDesktop ? 20 : 4.w,
                                  vertical: isDesktop ? 10 : 1.h),
                              title: Text(
                                LocalizationService.get(
                                    currentLang, 'darkMode'),
                                style:
                                    TextStyle(fontSize: responsiveSize(10, 14)),
                              ),
                              secondary: Icon(Icons.dark_mode,
                                  size: responsiveSize(16, 20)),
                              value: mode == ThemeMode.dark,
                              onChanged: (v) async =>
                                  await ThemeService().setThemeMode(v),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isDesktop ? 30 : 3.h),
                  _buildSectionHeader(
                      context,
                      LocalizationService.get(currentLang, 'general'),
                      responsiveSize),
                  SizedBox(height: isDesktop ? 10 : 1.h),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        // Language Selector
                        ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: isDesktop ? 20 : 4.w,
                              vertical: isDesktop ? 10 : 1.h),
                          leading: Icon(Icons.language,
                              size: responsiveSize(16, 20)),
                          title: Text(
                            LocalizationService.get(currentLang, 'language'),
                            style: TextStyle(fontSize: responsiveSize(10, 14)),
                          ),
                          subtitle: Text(
                            currentLang == 'id' ? 'Indonesia' : 'English',
                            style: TextStyle(fontSize: responsiveSize(9, 12)),
                          ),
                          trailing: Icon(Icons.chevron_right,
                              size: responsiveSize(16, 20)),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => SimpleDialog(
                                title: Text(
                                  LocalizationService.get(
                                      currentLang, 'language'),
                                  style: TextStyle(
                                      fontSize: responsiveSize(12, 16)),
                                ),
                                children: [
                                  SimpleDialogOption(
                                    padding: EdgeInsets.symmetric(
                                        vertical: isDesktop ? 15 : 1.5.h,
                                        horizontal: isDesktop ? 30 : 6.w),
                                    child: Text('Indonesia (ID)',
                                        style: TextStyle(
                                            fontSize: responsiveSize(10, 14))),
                                    onPressed: () async {
                                      await ThemeService().setLanguage('id');
                                      if (context.mounted) context.pop();
                                    },
                                  ),
                                  SimpleDialogOption(
                                    padding: EdgeInsets.symmetric(
                                        vertical: isDesktop ? 15 : 1.5.h,
                                        horizontal: isDesktop ? 30 : 6.w),
                                    child: Text('English (EN)',
                                        style: TextStyle(
                                            fontSize: responsiveSize(10, 14))),
                                    onPressed: () async {
                                      await ThemeService().setLanguage('en');
                                      if (context.mounted) context.pop();
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, Function responsiveSize) {
    return Padding(
      padding: EdgeInsets.only(left: 2.w, bottom: 0.5.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: responsiveSize(12, 16),
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
