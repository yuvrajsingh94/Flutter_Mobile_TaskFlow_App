import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:taskflow_flutter/core/theme/app_colors.dart';
import 'package:taskflow_flutter/core/widgets/empty_state.dart';
import 'package:taskflow_flutter/core/widgets/screen_wrapper.dart';
import 'package:taskflow_flutter/features/notifications/data/models/notification_model.dart';
import 'package:taskflow_flutter/features/notifications/presentation/providers/notification_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.darkBgCard : AppColors.lightBgCard;
    final cardBorder = isDark ? AppColors.darkBorderSubtle : AppColors.lightBorderInput;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary = isDark ? AppColors.darkTextDisabled : AppColors.lightTextDisabled;
    final accentColor = isDark ? AppColors.darkAccentPrimary : AppColors.primary;

    final notifState = ref.watch(notificationsNotifierProvider);

    return ScreenWrapper(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifState.notifications.isNotEmpty) ...[
            TextButton(
              onPressed: () {
                ref.read(notificationsNotifierProvider.notifier).markAllRead();
              },
              child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
            ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              onPressed: () {
                ref.read(notificationsNotifierProvider.notifier).clearAll();
              },
            ),
          ],
        ],
      ),
      onRefresh: () => ref.read(notificationsNotifierProvider.notifier).loadNotifications(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notifState.isLoading && notifState.notifications.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (notifState.notifications.isEmpty)
            const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No notifications',
              description: 'You are all caught up! No new notifications or task alerts.',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifState.notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifState.notifications[index];
                return _buildNotificationTile(
                  notif,
                  isDark: isDark,
                  cardBg: cardBg,
                  cardBorder: cardBorder,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                  textTertiary: textTertiary,
                  accentColor: accentColor,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    NotificationModel notif, {
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color accentColor,
  }) {
    final timeStr = DateFormat('MMM d, h:mm a').format(notif.createdAt);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notif.isRead ? cardBg : (isDark ? AppColors.darkBgInput : AppColors.surfaceStone),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notif.isRead ? cardBorder : accentColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: notif.isRead
                  ? (isDark ? AppColors.darkBgSidebar : AppColors.surfaceSubtle)
                  : accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 18,
              color: notif.isRead ? textTertiary : accentColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notif.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 11, color: textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notif.message,
                  style: TextStyle(fontSize: 13, color: textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
