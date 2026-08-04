import 'package:cloud_firestore/cloud_firestore.dart';

// ── Time slot (used in the UI picker) ────────────────────────────────────────
class TimeSlot {
  final String id;
  final String time;
  final bool available;

  const TimeSlot({
    required this.id,
    required this.time,
    required this.available,
  });
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

/// Returns the next 6 booking dates starting from tomorrow.
List<String> get bookingDates {
  final result = <String>[];
  var d = DateTime.now().add(const Duration(days: 1));
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  while (result.length < 6) {
    result.add(
      '${dayNames[d.weekday - 1]}, ${monthNames[d.month - 1]} ${d.day}',
    );
    d = d.add(const Duration(days: 1));
  }
  return result;
}

// ── Screener questions ────────────────────────────────────────────────────────
class ScreenerQuestion {
  final String id;
  final String question;

  const ScreenerQuestion({required this.id, required this.question});
}

final List<ScreenerQuestion> screenerQuestions = const [
  ScreenerQuestion(
      id: 'q1', question: 'Are you feeling well today?'),
  ScreenerQuestion(
      id: 'q2',
      question: 'Have you eaten a full meal in the last 4 hours?'),
  ScreenerQuestion(
      id: 'q3',
      question: 'Are you free from any fever or cold in the past 7 days?'),
  ScreenerQuestion(
      id: 'q4',
      question: 'Have you avoided alcohol in the past 24 hours?'),
  ScreenerQuestion(
      id: 'q5',
      question:
          'Are you free from any recent tattoo or piercing in the past 6 months?'),
];

// ── Persisted appointment ─────────────────────────────────────────────────────
enum AppointmentStatus { upcoming, completed, cancelled }

class Appointment {
  final String id;
  final String userId;
  final String centerName;
  final String centerAddress;
  final String centerId;
  final String date;
  final String time;
  final AppointmentStatus status;
  final DateTime? createdAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.centerName,
    required this.centerAddress,
    required this.centerId,
    required this.date,
    required this.time,
    this.status = AppointmentStatus.upcoming,
    this.createdAt,
  });

  factory Appointment.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final ts = d['createdAt'] as Timestamp?;
    return Appointment(
      id: doc.id,
      userId: d['userId'] as String? ?? '',
      centerName: d['centerName'] as String? ?? '',
      centerAddress: d['centerAddress'] as String? ?? '',
      centerId: d['centerId'] as String? ?? '',
      date: d['date'] as String? ?? '',
      time: d['time'] as String? ?? '',
      status: _parseStatus(d['status'] as String?),
      createdAt: ts?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'centerName': centerName,
        'centerAddress': centerAddress,
        'centerId': centerId,
        'date': date,
        'time': time,
        'status': status.name,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static AppointmentStatus _parseStatus(String? raw) {
    switch (raw) {
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
        return AppointmentStatus.cancelled;
      default:
        return AppointmentStatus.upcoming;
    }
  }
}
