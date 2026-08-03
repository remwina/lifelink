import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import '../../models/user_profile.dart';
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _ProfileHeader(user: user, tabController: _tab),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            _HistoryTab(user: user),
            _ChallengesTab(user: user),
            _BadgesTab(user: user),
          ],
        ),
      ),
    );
  }
}

// ── Profile header sliver ─────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final TabController tabController;

  const _ProfileHeader({required this.user, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _ProfileInfo(user: user),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: AppColors.background,
          child: TabBar(
            controller: tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.dmSans(
                fontSize: 13, fontWeight: FontWeight.w700),
            unselectedLabelStyle:
                GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'History'),
              Tab(text: 'Challenges'),
              Tab(text: 'Badges'),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserProfile user;

  const _ProfileInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPad + 8, 16, 0),
      child: Column(
        children: [
          // Avatar + edit
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.primaryLight,
                child: Text(
                  user.name.split(' ').map((w) => w[0]).take(2).join(),
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_rounded,
                      color: Colors.white, size: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.bloodType,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 3),
                    Text(
                      '${user.streakCount}-donation streak',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stats row
          Row(
            children: [
              _ProfileStat(
                  value: '${user.donationsTotal}', label: 'Donations'),
              _ProfileDivider(),
              _ProfileStat(
                  value: '${user.livesHelped}', label: 'Lives helped'),
              _ProfileDivider(),
              _ProfileStat(
                  value: '${user.bloodGivenL}L', label: 'Blood given'),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: AppColors.border,
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final UserProfile user;

  const _HistoryTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 24 + MediaQuery.of(context).padding.bottom),
      children: [
        ...user.history.map((h) => _HistoryCard(history: h)),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final DonationHistory history;

  const _HistoryCard({required this.history});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${history.type} · ${history.date}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${history.volumeL}L',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Challenges Tab ────────────────────────────────────────────────────────────
class _ChallengesTab extends StatelessWidget {
  final UserProfile user;

  const _ChallengesTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 24 + MediaQuery.of(context).padding.bottom),
      children: user.challenges.map((c) => _ChallengeCard(challenge: c)).toList(),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const _ChallengeCard({required this.challenge});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  challenge.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                challenge.reward,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            challenge.description,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    backgroundColor: AppColors.levelBg,
                    color: AppColors.primary,
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${challenge.current}/${challenge.target}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Badges Tab ────────────────────────────────────────────────────────────────
class _BadgesTab extends StatelessWidget {
  final UserProfile user;

  const _BadgesTab({required this.user});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 24 + MediaQuery.of(context).padding.bottom),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: user.badges.length,
      itemBuilder: (context, i) => _BadgeTile(badge: user.badges[i]),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final DonorBadge badge;

  const _BadgeTile({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badge.earned ? AppColors.surface : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badge.earned ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColorFiltered(
            colorFilter: badge.earned
                ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                : const ColorFilter.matrix([
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0.2126, 0.7152, 0.0722, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
            child: Text(
              badge.emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badge.earned ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          if (!badge.earned) ...[
            const SizedBox(height: 3),
            Text(
              'Locked',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
