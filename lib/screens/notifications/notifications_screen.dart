import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/theme_extensions.dart';
import '../../models/notification_item.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart' as ap;

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final uid = context.read<ap.AuthProvider>().currentUid ?? '';
    final notifications = provider.notifications;
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Alerts',
          style: GoogleFonts.dmSerifDisplay(
              fontSize: 22, color: context.colorTextPrimary),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => provider.markAllRead(uid),
              child: Text(
                'Mark all read',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        onRefresh: () => provider.refreshNotifications(uid),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
              16, 4, 16, 24 + MediaQuery.of(context).padding.bottom),
          children: [
            _AlertsHeader(unreadCount: unread.length),
            if (notifications.isEmpty)
              const _EmptyNotifications()
            else ...[
              if (unread.isNotEmpty) ...[
                _GroupLabel(label: 'New · ${unread.length}'),
                const SizedBox(height: 8),
                ...unread.map((n) => _NotificationCard(item: n, uid: uid)),
                const SizedBox(height: 16),
              ],
              if (read.isNotEmpty) ...[
                _GroupLabel(label: 'Earlier'),
                const SizedBox(height: 8),
                ...read.map((n) => _NotificationCard(item: n, uid: uid)),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _AlertsHeader extends StatelessWidget {
  final int unreadCount;

  const _AlertsHeader({required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.dangerLightDark, AppColors.warningLightDark]
              : [const Color(0xFFFFE3E5), const Color(0xFFFFF4E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLightDark
                  : Colors.white.withValues(alpha: 0.75),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_rounded,
                color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              unreadCount == 0
                  ? 'You’re all caught up!'
                  : 'You have $unreadCount little reminder${unreadCount == 1 ? '' : 's'}',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(top: 72, left: 24, right: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: context.colorPrimaryLight.withValues(alpha: isDark ? 0.25 : 1.0),
              shape: BoxShape.circle,
            ),
            child: const Text('💌', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 18),
          Text('All quiet for now',
              style: GoogleFonts.dmSans(
                  fontSize: 18, fontWeight: FontWeight.w700, color: context.colorTextPrimary)),
          const SizedBox(height: 6),
          Text(
            'We’ll keep an eye out and let you know when something lovely comes up.',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
                fontSize: 13, color: context.colorTextSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;

  const _GroupLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: context.colorTextMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final String uid;

  const _NotificationCard({required this.item, required this.uid});

  Color get _typeColor {
    switch (item.type) {
      case NotificationType.urgent:
        return AppColors.danger;
      case NotificationType.reminder:
        return AppColors.primary;
      case NotificationType.achievement:
        return AppColors.accent;
      case NotificationType.update:
        return AppColors.success;
    }
  }

  Color _typeBg(BuildContext context) {
    final isDark = context.isDark;
    switch (item.type) {
      case NotificationType.urgent:
        return isDark ? AppColors.dangerLightDark : AppColors.dangerLight;
      case NotificationType.reminder:
        return context.colorPrimaryLight;
      case NotificationType.achievement:
        return isDark ? AppColors.warningLightDark : const Color(0xFFFFF3E0);
      case NotificationType.update:
        return isDark ? AppColors.successLightDark : AppColors.successLight;
    }
  }

  IconData get _typeIcon {
    switch (item.type) {
      case NotificationType.urgent:
        return Icons.warning_rounded;
      case NotificationType.reminder:
        return Icons.favorite_rounded;
      case NotificationType.achievement:
        return Icons.emoji_events_rounded;
      case NotificationType.update:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: isDark ? AppColors.dangerLightDark : AppColors.dangerLight,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_sweep_rounded, color: AppColors.danger),
      ),
      onDismissed: (_) => context.read<AppProvider>().deleteNotification(uid, item.id),
      child: GestureDetector(
        onTap: item.isRead
            ? null
            : () => context.read<AppProvider>().markNotificationRead(uid, item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isRead
                ? context.colorSurface
                : context.colorPrimaryLight.withValues(alpha: isDark ? 0.25 : 0.4),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isRead
                  ? context.colorBorder
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeBg(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.colorTextPrimary,
                        ),
                      ),
                    ),
                    Text(
                      item.timeAgo,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: context.colorTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: context.colorTextSecondary,
                    height: 1.4,
                  ),
                ),
                if (item.hasAction && item.actionLabel != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      if (item.actionLabel == 'Book Now' ||
                          item.actionLabel == 'Schedule') {
                        context.read<AppProvider>().setIndex(1);
                      }
                    },
                    child: Text(
                      item.actionLabel!,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _typeColor,
                        decoration: TextDecoration.underline,
                        decorationColor: _typeColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!item.isRead) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
            ],
          ),
        ),
      ),
    );
  }
}
