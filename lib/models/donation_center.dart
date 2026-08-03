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
}

final List<DonationCenter> centersData = const [
  DonationCenter(
    id: 'pgh',
    name: 'Philippine General Hospital',
    address: 'Taft Ave, Ermita',
    hours: 'Open until 8 PM',
    distanceKm: 1.2,
    slotStatus: SlotStatus.open,
    lat: 14.5794,
    lng: 120.9843,
  ),
  DonationCenter(
    id: 'stlukes',
    name: "St. Luke's Medical Center",
    address: 'E. Rodriguez Sr.',
    hours: 'Open until 6 PM',
    distanceKm: 3.8,
    slotStatus: SlotStatus.limited,
    lat: 14.6196,
    lng: 121.0090,
  ),
  DonationCenter(
    id: 'redcross',
    name: 'Red Cross — Manila Chapter',
    address: 'Port Area',
    hours: 'Open until 5 PM',
    distanceKm: 5.1,
    slotStatus: SlotStatus.open,
    lat: 14.5876,
    lng: 120.9739,
  ),
  DonationCenter(
    id: 'usth',
    name: 'UST Hospital Blood Bank',
    address: 'España Blvd, Sampaloc',
    hours: 'Open until 7 PM',
    distanceKm: 2.4,
    slotStatus: SlotStatus.open,
    lat: 14.6110,
    lng: 120.9894,
  ),
  DonationCenter(
    id: 'prc',
    name: 'Philippine Red Cross HQ',
    address: 'Bonifacio Dr, Port Area',
    hours: 'Open until 6 PM',
    distanceKm: 4.7,
    slotStatus: SlotStatus.limited,
    lat: 14.5878,
    lng: 120.9738,
  ),
];
