import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow_flutter/core/navigation/navigator_service.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/logout_confirmation_sheet.dart';
import 'package:taskflow_flutter/core/widgets/profile_avatar.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/auth/data/models/user_model.dart';
import 'package:taskflow_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:taskflow_flutter/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:taskflow_flutter/features/profile/presentation/screens/profile_screen.dart';
import 'package:taskflow_flutter/features/reports/presentation/screens/reports_screen.dart';
import 'package:taskflow_flutter/features/settings/presentation/screens/settings_screen.dart';

class AdminMoreScreen extends ConsumerWidget {
  const AdminMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.surfaceElevated;
    final borderCol = isDark ? AppColors.darkBorderSubtle : AppColors.borderHairline;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final iconBg = isDark ? AppColors.darkBgInput : AppColors.surfaceStone;
    final linkColor = isDark ? AppColors.darkAccentPrimary : AppColors.primary;

    final menuItems = [
      _MoreMenuItem(
        title: 'Performance & Reports',
        desc: 'Completion rates and analytics',
        icon: Icons.bar_chart_rounded,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(builder: (_) => const ReportsScreen()),
          );
        },
      ),
      _MoreMenuItem(
        title: 'Notifications & Alerts',
        desc: 'System and task activity updates',
        icon: Icons.notifications_outlined,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
      ),
      _MoreMenuItem(
        title: 'Settings & Connection',
        desc: 'Dark theme and API connection',
        icon: Icons.settings_outlined,
        onTap: () {
          Navigator.push(
            context,
            SlidePageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];

    return ScreenWrapper(
      title: 'More',
      subtitle: user?.role.preferencesSubtitle ?? 'Admin preferences & tools',
      scrollable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── User Card ───────────────────────────────────────────────────────
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                SlidePageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderCol),
              ),
              child: Row(
                children: [
                  ProfileAvatar(
                    imageUrl: user?.profilePicture,
                    name: user?.fullName,
                    radius: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName.isNotEmpty == true
                              ? user!.fullName
                              : 'Workspace Administrator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'admin@taskflow.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Admin Profile • Edit Details →',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: linkColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 22, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Menu List Card ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderCol),
            ),
            child: Column(
              children: [
                for (int i = 0; i < menuItems.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 60,
                      color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderSubtle,
                    ),
                  InkWell(
                    onTap: menuItems[i].onTap,
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(16) : Radius.zero,
                      bottom: i == menuItems.length - 1
                          ? const Radius.circular(16)
                          : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(menuItems[i].icon,
                                size: 20, color: textPrimary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  menuItems[i].title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  menuItems[i].desc,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded,
                              size: 20, color: AppColors.textTertiary),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 28),

          // ── Logout Button ───────────────────────────────────────────────────
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              showLogoutConfirmationSheet(
                context: context,
                role: user?.role,
                onConfirmLogout: () async {
                  await ref.read(authNotifierProvider.notifier).logout();
                  if (context.mounted) {
                    popToRoot();
                  }
                },
              );
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(
              user?.role != null
                  ? 'Log Out of ${user!.role.portalLabel}'
                  : 'Log Out',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MoreMenuItem {
  final String title;
  final String desc;
  final IconData icon;
  final VoidCallback onTap;

  _MoreMenuItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.onTap,
  });
}
