# LifeLink

> A blood donation companion app built with Flutter — designed for donors in Metro Manila.

LifeLink helps you track your eligibility, find nearby donation centers, book appointments, and respond to urgent blood shortage alerts.

> This is a UI prototype with local mock data. No backend or Firebase integration.

---

## Features

### Home Dashboard
- Personalized greeting with blood type badge
- Eligibility card showing days until your next donation
- Blood supply grid for all 8 blood types with color-coded levels
- Personal impact stats — donations, lives helped, blood given
- Quick-access list of nearby donation centers

### Pulse Alert
- Full-screen urgent shortage overlay
- Shows blood type needed, supply percentage, and nearest open centers
- One-tap action to jump straight to booking

### Alerts
- Grouped notification feed (New / Earlier)
- Four notification types: urgent, reminder, achievement, update
- Mark all as read with inline action links

### Booking Wizard
A 4-step appointment flow:
1. Pick a date and time slot
2. Health screener questionnaire
3. Review your appointment details
4. Confirmation screen

### Map
- Interactive OpenStreetMap powered by `flutter_map`
- Donation center pins with slot-availability indicators (open / limited / full)
- Search by name or address, filter by "Slots open" or "Nearby"
- Bottom sheet with center cards and direct booking CTA

### Profile
- Collapsing header with avatar, blood type, and donation streak
- Three tabs: **History · Challenges · Badges**
- Progress bars for active challenges and earned/locked badge grid

---

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart SDK ^3.12.2) |
| State Management | Provider ^6.1.2 |
| Maps | flutter_map ^8.3.1 + latlong2 ^0.10.1 |
| Fonts | google_fonts ^6.2.1 (DM Serif Display + DM Sans) |
| Map Tiles | OpenStreetMap |

---

## Project Structure

```
lib/
├── main.dart                   # App entry point
├── shell.dart                  # AppShell — IndexedStack + bottom nav + overlay
├── core/
│   └── theme.dart              # AppColors + theme builder
├── models/
│   ├── user_profile.dart       # UserProfile, DonationHistory, Challenge, DonorBadge
│   ├── donation_center.dart
│   ├── notification_item.dart
│   ├── blood_supply.dart
│   └── booking.dart            # TimeSlot, ScreenerQuestion
├── providers/
│   └── app_provider.dart       # Single ChangeNotifier for all app state
├── screens/
│   ├── home/
│   ├── notifications/
│   ├── booking/
│   │   └── steps/              # SlotPicker, Screener, Review, Confirmed
│   ├── map/
│   ├── profile/
│   └── pulse_alert/
└── widgets/                    # Shared widgets (BloodDropIcon, etc.)
```

---

## Getting Started

**Prerequisites:** Flutter SDK 3.12+ · Dart SDK 3.12+

```bash
# Install dependencies
flutter pub get

# Run on a connected device or emulator
flutter run
```

The app is portrait-only and targets Android and iOS. It also runs on Flutter Web.

---

## Notes

- All donor and center data is hardcoded mock data — no API calls are made
- Map tiles load from OpenStreetMap; an internet connection is required to display them
- The app is locked to portrait orientation
