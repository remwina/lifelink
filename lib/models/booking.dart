class TimeSlot {
  final String id;
  final String time;
  final bool available;

  const TimeSlot({required this.id, required this.time, required this.available});
}

final List<TimeSlot> availableSlots = const [
  TimeSlot(id: 's1', time: '8:00 AM', available: true),
  TimeSlot(id: 's2', time: '9:00 AM', available: false),
  TimeSlot(id: 's3', time: '10:00 AM', available: true),
  TimeSlot(id: 's4', time: '11:00 AM', available: true),
  TimeSlot(id: 's5', time: '1:00 PM', available: false),
  TimeSlot(id: 's6', time: '2:00 PM', available: true),
  TimeSlot(id: 's7', time: '3:00 PM', available: true),
  TimeSlot(id: 's8', time: '4:00 PM', available: true),
];

final List<String> bookingDates = const [
  'Mon, May 20',
  'Tue, May 21',
  'Wed, May 22',
  'Thu, May 23',
  'Fri, May 24',
  'Sat, May 25',
];

// Screener questions
class ScreenerQuestion {
  final String id;
  final String question;

  const ScreenerQuestion({required this.id, required this.question});
}

final List<ScreenerQuestion> screenerQuestions = const [
  ScreenerQuestion(id: 'q1', question: 'Are you feeling well today?'),
  ScreenerQuestion(id: 'q2', question: 'Have you eaten a full meal in the last 4 hours?'),
  ScreenerQuestion(id: 'q3', question: 'Are you free from any fever or cold in the past 7 days?'),
  ScreenerQuestion(id: 'q4', question: 'Have you avoided alcohol in the past 24 hours?'),
  ScreenerQuestion(id: 'q5', question: 'Are you free from any recent tattoo or piercing in the past 6 months?'),
];
