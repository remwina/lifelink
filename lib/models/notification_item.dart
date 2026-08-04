import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { urgent, reminder, achievement, update }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String timeAgo;
  final bool isRead;
  final bool hasAction;
  final String? actionLabel;
  final DateTime? createdAt;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    this.hasAction = false,
    this.actionLabel,
    this.createdAt,
  });

  factory NotificationItem.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final ts = d['createdAt'] as Timestamp?;
    final created = ts?.toDate();

    return NotificationItem(
      id: doc.id,
      type: _parseType(d['type'] as String?),
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      timeAgo: _formatTimeAgo(created),
      isRead: d['isRead'] as bool? ?? false,
      hasAction: d['hasAction'] as bool? ?? false,
      actionLabel: d['actionLabel'] as String?,
      createdAt: created,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'type': type.name,
        'title': title,
        'body': body,
        'isRead': isRead,
        'hasAction': hasAction,
        if (actionLabel != null) 'actionLabel': actionLabel,
        'createdAt': FieldValue.serverTimestamp(),
      };

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        type: type,
        title: title,
        body: body,
        timeAgo: timeAgo,
        isRead: isRead ?? this.isRead,
        hasAction: hasAction,
        actionLabel: actionLabel,
        createdAt: createdAt,
      );

  static NotificationType _parseType(String? raw) {
    switch (raw) {
      case 'urgent':
        return NotificationType.urgent;
      case 'reminder':
        return NotificationType.reminder;
      case 'achievement':
        return NotificationType.achievement;
      default:
        return NotificationType.update;
    }
  }

  static String _formatTimeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

// ── Seed notifications for new users ─────────────────────────────────────────
final List<Map<String, dynamic>> seedNotifications = [
  {
    'type': 'urgent',
    'title': 'URGENT: O− Blood Needed',
    'body':
        'Philippine General Hospital needs O− donors immediately. Only 8% supply remaining.',
    'isRead': false,
    'hasAction': true,
    'actionLabel': 'Book Now',
    'createdAt': FieldValue.serverTimestamp(),
  },
  {
    'type': 'reminder',
    'title': 'Welcome to LifeLink!',
    'body':
        'Find nearby donation centers, book appointments, and track your donation impact.',
    'isRead': false,
    'hasAction': false,
    'createdAt': FieldValue.serverTimestamp(),
  },
];
