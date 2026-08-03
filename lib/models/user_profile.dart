class DonationHistory {
  final String date;
  final String center;
  final String type;
  final double volumeL;

  const DonationHistory({
    required this.date,
    required this.center,
    required this.type,
    required this.volumeL,
  });
}

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

class DonorBadge {
  final String emoji;
  final String label;
  final bool earned;

  const DonorBadge({required this.emoji, required this.label, required this.earned});
}

class UserProfile {
  final String name;
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
    required this.name,
    required this.bloodType,
    required this.donationsTotal,
    required this.livesHelped,
    required this.bloodGivenL,
    required this.streakCount,
    required this.daysUntilEligible,
    required this.nextEligibleDate,
    required this.history,
    required this.challenges,
    required this.badges,
  });
}

final UserProfile mockUser = UserProfile(
  name: 'Maria Santos',
  bloodType: 'O−',
  donationsTotal: 12,
  livesHelped: 36,
  bloodGivenL: 5.4,
  streakCount: 4,
  daysUntilEligible: 12,
  nextEligibleDate: 'May 24',
  history: const [
    DonationHistory(date: 'Mar 15, 2025', center: 'Philippine General Hospital', type: 'Whole Blood', volumeL: 0.45),
    DonationHistory(date: 'Jan 08, 2025', center: "St. Luke's Medical Center", type: 'Whole Blood', volumeL: 0.45),
    DonationHistory(date: 'Nov 02, 2024', center: 'Red Cross — Manila Chapter', type: 'Whole Blood', volumeL: 0.45),
    DonationHistory(date: 'Sep 05, 2024', center: 'Philippine General Hospital', type: 'Whole Blood', volumeL: 0.45),
  ],
  challenges: const [
    Challenge(
      title: 'Frequent Donor',
      description: 'Donate 5 times in a year',
      current: 3,
      target: 5,
      reward: '🏆 Gold Badge',
    ),
    Challenge(
      title: 'Community Hero',
      description: 'Help 50 lives through donations',
      current: 36,
      target: 50,
      reward: '🌟 Hero Badge',
    ),
    Challenge(
      title: 'Blood Drive Volunteer',
      description: 'Participate in 3 blood drives',
      current: 1,
      target: 3,
      reward: '❤️ Volunteer Badge',
    ),
  ],
  badges: const [
    DonorBadge(emoji: '🩸', label: 'First Drop', earned: true),
    DonorBadge(emoji: '🔥', label: '4-Streak', earned: true),
    DonorBadge(emoji: '⭐', label: '10 Donations', earned: true),
    DonorBadge(emoji: '🏆', label: 'Life Saver', earned: true),
    DonorBadge(emoji: '🌟', label: 'Hero', earned: false),
    DonorBadge(emoji: '💎', label: 'Elite', earned: false),
  ],
);
