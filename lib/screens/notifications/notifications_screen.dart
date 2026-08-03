import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/notification_item.dart';
import '../../providers/app_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notifications = provider.notifications;
    final unread = notifications.where((n) => !n.isRead).toList();
    final read = notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Alerts',
          style: GoogleFonts.dmSerifDisplay(
              fontSize: 22, color: AppColors.textPrimary),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: provider.markAllRead,
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
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, 24 + MediaQuery.of(context).padding.bottom),
        children: [
          if (unread.isNotEmpty) ...[
            _GroupLabel(label: 'New · ${unread.length}'),
            const SizedBox(height: 8),
            ...unread.map((n) => _NotificationCard(item: n)),
            const SizedBox(height: 16),
          ],
          if (read.isNotEmpty) ...[
            _GroupLabel(label: 'Earlier'),
            const SizedBox(height: 8),
            ...read.map((n) => _NotificationCard(item: n)),
          ],
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
          color: AppColors.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

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

  Color get _typeBg {
    switch (item.type) {
      case NotificationType.urgent:
        return AppColors.dangerLight;
      case NotificationType.reminder:
        return AppColors.primaryLight;
      case NotificationType.achievement:
        return const Color(0xFFFFF3E0);
      case NotificationType.update:
        return AppColors.successLight;
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isRead ? AppColors.surface : AppColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
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
              color: _typeBg,
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
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      item.timeAgo,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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
    );
  }
}
