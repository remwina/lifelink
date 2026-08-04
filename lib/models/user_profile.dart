import 'package:cloud_firestore/cloud_firestore.dart';

// ── Donation history entry ────────────────────────────────────────────────────
class DonationHistory {
  final String id;
  final String date;
  final String center;
  final String type;
  final double volumeL;

  const DonationHistory({
    this.id = '',
    required this.date,
    required this.center,
    required this.type,
    required this.volumeL,
  });

  factory DonationHistory.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return DonationHistory(
      id: doc.id,
      date: d['date'] as String? ?? '',
      center: d['center'] as String? ?? '',
      type: d['type'] as String? ?? 'Whole Blood',
      volumeL: (d['volumeL'] as num?)?.toDouble() ?? 0.45,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'date': date,
        'center': center,
        'type': type,
        'volumeL': volumeL,
      };
}

// ── Challenge ─────────────────────────────────────────────────────────────────
class Challenge {
  final String title;
  final String description;
  final int current;
  final int target;
  final String reward;
  final bool completed;

  const Challenge({
    required this.title,
    required this.description,
    required this.current,
    required this.target,
    required this.reward,
    this.completed = false,
  });

  double get progress => (current / target).clamp(0.0, 1.0);
}

// ── Donor badge ───────────────────────────────────────────────────────────────
class DonorBadge {
  final String emoji;
  final String label;
  final bool earned;

  const DonorBadge({
    required this.emoji,
    required this.label,
    required this.earned,
  });
}

// ── User profile ──────────────────────────────────────────────────────────────
class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String bloodType;
  final int donationsTotal;
  final int livesHelped;
  final double bloodGivenL;
  final int streakCount;
  final int daysUntilEligible;
  final String nextEligibleDate;
  final List<DonationHistory> history;
  final List<Challenge> challenges;
  final List<DonorBadge> badges;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.bloodType,
    this.donationsTotal = 0,
    this.livesHelped = 0,
    this.bloodGivenL = 0.0,
    this.streakCount = 0,
    this.daysUntilEligible = 0,
    this.nextEligibleDate = '—',
    this.history = const [],
    this.challenges = const [],
    this.badges = const [],
  });

  /// Creates a brand-new profile for a freshly registered user.
  factory UserProfile.newUser({
    required String uid,
    required String name,
    required String email,
    required String bloodType,
  }) {
    return UserProfile(
      uid: uid,
      name: name,
      email: email,
      bloodType: bloodType,
      donationsTotal: 0,
      livesHelped: 0,
      bloodGivenL: 0.0,
      streakCount: 0,
      daysUntilEligible: 0,
      nextEligibleDate: '—',
      history: const [],
      challenges: _defaultChallenges,
      badges: _defaultBadges,
    );
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    final rawChallenges = (d['challenges'] as List<dynamic>?) ?? [];
    final rawBadges = (d['badges'] as List<dynamic>?) ?? [];

    return UserProfile(
      uid: doc.id,
      name: d['name'] as String? ?? 'Donor',
      email: d['email'] as String? ?? '',
      bloodType: d['bloodType'] as String? ?? 'O+',
      donationsTotal: (d['donationsTotal'] as num?)?.toInt() ?? 0,
      livesHelped: (d['livesHelped'] as num?)?.toInt() ?? 0,
      bloodGivenL: (d['bloodGivenL'] as num?)?.toDouble() ?? 0.0,
      streakCount: (d['streakCount'] as num?)?.toInt() ?? 0,
      daysUntilEligible: (d['daysUntilEligible'] as num?)?.toInt() ?? 0,
      nextEligibleDate: d['nextEligibleDate'] as String? ?? '—',
      history: const [], // loaded separately from sub-collection
      challenges: rawChallenges
          .map((c) => Challenge(
                title: c['title'] as String? ?? '',
                description: c['description'] as String? ?? '',
                current: (c['current'] as num?)?.toInt() ?? 0,
                target: (c['target'] as num?)?.toInt() ?? 1,
                reward: c['reward'] as String? ?? '',
                completed: c['completed'] as bool? ?? false,
              ))
          .toList(),
      badges: rawBadges
          .map((b) => DonorBadge(
                emoji: b['emoji'] as String? ?? '🩸',
                label: b['label'] as String? ?? '',
                earned: b['earned'] as bool? ?? false,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'bloodType': bloodType,
        'donationsTotal': donationsTotal,
        'livesHelped': livesHelped,
        'bloodGivenL': bloodGivenL,
        'streakCount': streakCount,
        'daysUntilEligible': daysUntilEligible,
        'nextEligibleDate': nextEligibleDate,
        'challenges': challenges
            .map((c) => {
                  'title': c.title,
                  'description': c.description,
                  'current': c.current,
                  'target': c.target,
                  'reward': c.reward,
                  'completed': c.completed,
                })
            .toList(),
        'badges': badges
            .map((b) => {
                  'emoji': b.emoji,
                  'label': b.label,
                  'earned': b.earned,
                })
            .toList(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  UserProfile copyWith({
    String? name,
    String? email,
    String? bloodType,
    int? donationsTotal,
    int? livesHelped,
    double? bloodGivenL,
    int? streakCount,
    int? daysUntilEligible,
    String? nextEligibleDate,
    List<DonationHistory>? history,
    List<Challenge>? challenges,
    List<DonorBadge>? badges,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bloodType: bloodType ?? this.bloodType,
      donationsTotal: donationsTotal ?? this.donationsTotal,
      livesHelped: livesHelped ?? this.livesHelped,
      bloodGivenL: bloodGivenL ?? this.bloodGivenL,
      streakCount: streakCount ?? this.streakCount,
      daysUntilEligible: daysUntilEligible ?? this.daysUntilEligible,
      nextEligibleDate: nextEligibleDate ?? this.nextEligibleDate,
      history: history ?? this.history,
      challenges: challenges ?? this.challenges,
      badges: badges ?? this.badges,
    );
  }
}

// ── Default seed data for new users ──────────────────────────────────────────
const List<Challenge> _defaultChallenges = [
  Challenge(
    title: 'First Drop',
    description: 'Complete your first donation',
    current: 0,
    target: 1,
    reward: '🩸 First Drop Badge',
  ),
  Challenge(
    title: 'Frequent Donor',
    description: 'Donate 5 times in a year',
    current: 0,
    target: 5,
    reward: '🏆 Gold Badge',
  ),
  Challenge(
    title: 'Community Hero',
    description: 'Help 50 lives through donations',
    current: 0,
    target: 50,
    reward: '🌟 Hero Badge',
  ),
];

const List<DonorBadge> _defaultBadges = [
  DonorBadge(emoji: '🩸', label: 'First Drop', earned: false),
  DonorBadge(emoji: '🔥', label: '4-Streak', earned: false),
  DonorBadge(emoji: '⭐', label: '10 Donations', earned: false),
  DonorBadge(emoji: '🏆', label: 'Life Saver', earned: false),
  DonorBadge(emoji: '🌟', label: 'Hero', earned: false),
  DonorBadge(emoji: '💎', label: 'Elite', earned: false),
];
