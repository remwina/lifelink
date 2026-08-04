import 'package:cloud_firestore/cloud_firestore.dart';

enum SlotStatus { open, limited, full }

class DonationCenter {
  final String id;
  final String name;
  final String address;
  final String hours;
  final double distanceKm;
  final SlotStatus slotStatus;
  final double lat;
  final double lng;

  const DonationCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.hours,
    required this.distanceKm,
    required this.slotStatus,
    required this.lat,
    required this.lng,
  });

  factory DonationCenter.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonationCenter(
      id: doc.id,
      name: d['name'] as String? ?? '',
      address: d['address'] as String? ?? '',
      hours: d['hours'] as String? ?? '',
      distanceKm: (d['distanceKm'] as num?)?.toDouble() ?? 0.0,
      slotStatus: _parseSlot(d['slotStatus'] as String?),
      lat: (d['lat'] as num?)?.toDouble() ?? 14.5995,
      lng: (d['lng'] as num?)?.toDouble() ?? 120.9842,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'address': address,
        'hours': hours,
        'distanceKm': distanceKm,
        'slotStatus': slotStatus.name,
        'lat': lat,
        'lng': lng,
      };

  String get slotLabel {
    switch (slotStatus) {
      case SlotStatus.open:
        return 'Slots open';
      case SlotStatus.limited:
        return '2 slots left';
      case SlotStatus.full:
        return 'Full';
    }
  }

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  static SlotStatus _parseSlot(String? raw) {
    switch (raw) {
      case 'limited':
        return SlotStatus.limited;
      case 'full':
        return SlotStatus.full;
      default:
        return SlotStatus.open;
    }
  }
}

// ── Seed data — written once to Firestore by FirestoreService.seedCenters() ──
final List<Map<String, dynamic>> seedCenters = [
  {
    'name': 'Philippine General Hospital',
    'address': 'Taft Ave, Ermita',
    'hours': 'Open until 8 PM',
    'distanceKm': 1.2,
    'slotStatus': 'open',
    'lat': 14.5794,
    'lng': 120.9843,
  },
  {
    'name': "St. Luke's Medical Center",
    'address': 'E. Rodriguez Sr.',
    'hours': 'Open until 6 PM',
    'distanceKm': 3.8,
    'slotStatus': 'limited',
    'lat': 14.6196,
    'lng': 121.0090,
  },
  {
    'name': 'Red Cross — Manila Chapter',
    'address': 'Port Area',
    'hours': 'Open until 5 PM',
    'distanceKm': 5.1,
    'slotStatus': 'open',
    'lat': 14.5876,
    'lng': 120.9739,
  },
  {
    'name': 'UST Hospital Blood Bank',
    'address': 'España Blvd, Sampaloc',
    'hours': 'Open until 7 PM',
    'distanceKm': 2.4,
    'slotStatus': 'open',
    'lat': 14.6110,
    'lng': 120.9894,
  },
  {
    'name': 'Philippine Red Cross HQ',
    'address': 'Bonifacio Dr, Port Area',
    'hours': 'Open until 6 PM',
    'distanceKm': 4.7,
    'slotStatus': 'limited',
    'lat': 14.5878,
    'lng': 120.9738,
  },
];
