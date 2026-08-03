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

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timeAgo,
    this.isRead = false,
    this.hasAction = false,
    this.actionLabel,
  });
}

final List<NotificationItem> notificationsData = const [
  NotificationItem(
    id: 'n1',
    type: NotificationType.urgent,
    title: 'URGENT: O− Blood Needed',
    body: 'Philippine General Hospital needs O− donors immediately. Only 8% supply remaining.',
    timeAgo: '2 min ago',
    isRead: false,
    hasAction: true,
    actionLabel: 'Book Now',
  ),
  NotificationItem(
    id: 'n2',
    type: NotificationType.reminder,
    title: 'You\'re eligible to donate!',
    body: 'It\'s been 56 days since your last donation. You can donate again at any time.',
    timeAgo: '1 hour ago',
    isRead: false,
    hasAction: true,
    actionLabel: 'Schedule',
  ),
  NotificationItem(
    id: 'n3',
    type: NotificationType.achievement,
    title: '🏆 Achievement Unlocked!',
    body: 'You\'ve earned the "Life Saver" badge for your 10th donation.',
    timeAgo: '2 days ago',
    isRead: true,
  ),
  NotificationItem(
    id: 'n4',
    type: NotificationType.update,
    title: 'Appointment Confirmed',
    body: 'Your donation appointment at St. Luke\'s is confirmed for May 24 at 10:00 AM.',
    timeAgo: '3 days ago',
    isRead: true,
    hasAction: true,
    actionLabel: 'View Details',
  ),
  NotificationItem(
    id: 'n5',
    type: NotificationType.urgent,
    title: 'AB− Supply Critical',
    body: 'Metro Manila blood banks report critically low AB− supply at 18%. Rare donors needed.',
    timeAgo: '5 days ago',
    isRead: true,
    hasAction: true,
    actionLabel: 'Respond',
  ),
];
