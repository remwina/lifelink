import '../models/blood_supply.dart';
import '../models/booking.dart';
import '../models/donation_center.dart';

const List<BloodSupplyEntry> demoBloodSupply = [
  BloodSupplyEntry(type: 'A+', percentage: 72),
  BloodSupplyEntry(type: 'A−', percentage: 34),
  BloodSupplyEntry(type: 'B+', percentage: 58),
  BloodSupplyEntry(type: 'B−', percentage: 21),
  BloodSupplyEntry(type: 'AB+', percentage: 65),
  BloodSupplyEntry(type: 'AB−', percentage: 18),
  BloodSupplyEntry(type: 'O+', percentage: 47),
  BloodSupplyEntry(type: 'O−', percentage: 8),
];

const List<DemoCenter> demoCenters = [
  DemoCenter(
    id: 'demo-pgh',
    name: 'Philippine General Hospital',
    address: 'Taft Ave, Ermita',
    hours: 'Open until 8 PM',
    distanceKm: 1.2,
    slotStatus: SlotStatus.open,
    lat: 14.5794,
    lng: 120.9843,
  ),
  DemoCenter(
    id: 'demo-slmc',
    name: "St. Luke's Medical Center",
    address: 'E. Rodriguez Sr.',
    hours: 'Open until 6 PM',
    distanceKm: 3.8,
    slotStatus: SlotStatus.limited,
    lat: 14.6196,
    lng: 121.0090,
  ),
  DemoCenter(
    id: 'demo-red-cross',
    name: 'Red Cross — Manila Chapter',
    address: 'Port Area',
    hours: 'Open until 5 PM',
    distanceKm: 5.1,
    slotStatus: SlotStatus.open,
    lat: 14.5876,
    lng: 120.9739,
  ),
  DemoCenter(
    id: 'demo-ust',
    name: 'UST Hospital Blood Bank',
    address: 'España Blvd, Sampaloc',
    hours: 'Open until 7 PM',
    distanceKm: 2.4,
    slotStatus: SlotStatus.open,
    lat: 14.6110,
    lng: 120.9894,
  ),
  DemoCenter(
    id: 'demo-prchq',
    name: 'Philippine Red Cross HQ',
    address: 'Bonifacio Dr, Port Area',
    hours: 'Open until 6 PM',
    distanceKm: 4.7,
    slotStatus: SlotStatus.limited,
    lat: 14.5878,
    lng: 120.9738,
  ),
];

class DemoCenter {
  final String id;
  final String name;
  final String address;
  final String hours;
  final double distanceKm;
  final SlotStatus slotStatus;
  final double lat;
  final double lng;

  const DemoCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.distanceKm,
    required this.slotStatus,
    required this.lat,
    required this.lng,
  });

  DonationCenter toCenter() => DonationCenter(
        id: id,
        name: name,
        address: address,
        hours: hours,
        distanceKm: distanceKm,
        slotStatus: slotStatus,
        lat: lat,
        lng: lng,
      );
}

List<Map<String, dynamic>> get demoUsers => const [
      {'bloodType': 'O+'},
      {'bloodType': 'A+'},
      {'bloodType': 'B+'},
      {'bloodType': 'O+'},
      {'bloodType': 'AB+'},
      {'bloodType': 'A+'},
      {'bloodType': 'O−'},
      {'bloodType': 'B+'},
      {'bloodType': 'O+'},
      {'bloodType': 'A−'},
      {'bloodType': 'O+'},
      {'bloodType': 'AB+'},
    ];

List<Appointment> buildDemoAppointments(DateTime now) {
  const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  String fmt(DateTime d) =>
      '${dayNames[d.weekday - 1]}, ${monthNames[d.month - 1]} ${d.day}';

  final tomorrow = now.add(const Duration(days: 1));
  final dayAfter = now.add(const Duration(days: 2));
  final day3 = now.add(const Duration(days: 3));
  final day4 = now.add(const Duration(days: 4));

  return [
    Appointment(
      id: 'demo-1',
      userId: 'u1',
      centerName: 'Philippine General Hospital',
      centerAddress: 'Taft Ave, Ermita',
      centerId: 'demo-pgh',
      date: fmt(tomorrow),
      time: '9:00 AM',
      status: AppointmentStatus.upcoming,
      createdAt: now,
    ),
    Appointment(
      id: 'demo-2',
      userId: 'u2',
      centerName: 'Red Cross — Manila Chapter',
      centerAddress: 'Port Area',
      centerId: 'demo-red-cross',
      date: fmt(tomorrow),
      time: '10:00 AM',
      status: AppointmentStatus.upcoming,
      createdAt: now,
    ),
    Appointment(
      id: 'demo-3',
      userId: 'u3',
      centerName: "St. Luke's Medical Center",
      centerAddress: 'E. Rodriguez Sr.',
      centerId: 'demo-slmc',
      date: fmt(dayAfter),
      time: '8:00 AM',
      status: AppointmentStatus.upcoming,
      createdAt: now,
    ),
    Appointment(
      id: 'demo-4',
      userId: 'u1',
      centerName: 'UST Hospital Blood Bank',
      centerAddress: 'España Blvd, Sampaloc',
      centerId: 'demo-ust',
      date: fmt(day3),
      time: '1:00 PM',
      status: AppointmentStatus.completed,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Appointment(
      id: 'demo-5',
      userId: 'u4',
      centerName: 'Philippine Red Cross HQ',
      centerAddress: 'Bonifacio Dr, Port Area',
      centerId: 'demo-prchq',
      date: fmt(day4),
      time: '2:00 PM',
      status: AppointmentStatus.cancelled,
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    Appointment(
      id: 'demo-6',
      userId: 'u2',
      centerName: 'Philippine General Hospital',
      centerAddress: 'Taft Ave, Ermita',
      centerId: 'demo-pgh',
      date: fmt(dayAfter),
      time: '11:00 AM',
      status: AppointmentStatus.completed,
      createdAt: now.subtract(const Duration(days: 1)),
    ),
  ];
}
