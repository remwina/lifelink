import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/theme_extensions.dart';
import '../../core/transitions.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart' as ap;
import '../../models/user_profile.dart';
import '../../models/booking.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../help/help_screen.dart';
import '../help/feedback_screen.dart';

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
    _tab = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppProvider>().user;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          _ProfileHeader(user: user, tabController: _tab),
        ],
        body: TabBarView(
          controller: _tab,
          children: [
            const _AppointmentsTab(),
            _HistoryTab(user: user),
            _ChallengesTab(user: user),
            _BadgesTab(user: user),
            _CommunityTab(user: user),
            const _SettingsTab(),
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
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.qr_code_2_rounded,
            color: AppColors.primary,
            size: 23,
          ),
          tooltip: 'Donor QR card',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => _DonorCardDialog(user: user),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.logout_rounded,
            color: context.colorTextMuted,
            size: 20,
          ),
          tooltip: 'Sign out',
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(
                  'Sign out',
                  style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                ),
                content: Text(
                  'Are you sure you want to sign out?',
                  style: GoogleFonts.dmSans(),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(
                      'Sign out',
                      style: GoogleFonts.dmSans(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            );
            if (confirmed == true && context.mounted) {
              await context.read<ap.AuthProvider>().signOut();
            }
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _ProfileInfo(user: user),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: context.colorTextMuted,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.calendar_month_rounded, size: 20),
                text: 'Appointments',
              ),
              Tab(
                icon: Icon(Icons.history_rounded, size: 20),
                text: 'History',
              ),
              Tab(
                icon: Icon(Icons.emoji_events_rounded, size: 20),
                text: 'Challenges',
              ),
              Tab(
                icon: Icon(Icons.star_rounded, size: 20),
                text: 'Badges',
              ),
              Tab(
                icon: Icon(Icons.groups_rounded, size: 20),
                text: 'Community',
              ),
              Tab(
                icon: Icon(Icons.settings_rounded, size: 20),
                text: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonorCardDialog extends StatelessWidget {
  final UserProfile user;

  const _DonorCardDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🩸', style: TextStyle(fontSize: 30)),
            const SizedBox(height: 4),
            Text(
              'LifeLink donor card',
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Show this at a donation center',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: context.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 18),
            QrImageView(
              data: 'lifelink://donor/${user.uid}',
              version: QrVersions.auto,
              size: 180,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              user.name,
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: context.colorPrimaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Blood type ${user.bloodType}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final UserProfile user;

  const _ProfileInfo({required this.user});

  // Fix #13: safe initials — handles empty or single-word names
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

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
                backgroundColor: context.colorPrimaryLight,
                child: Text(
                  _initials(user.name),
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
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            user.name,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 22,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: context.colorPrimaryLight,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: context.isDark
                      ? AppColors.warningLightDark
                      : const Color(0xFFFFF3E0),
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
              _ProfileStat(value: '${user.donationsTotal}', label: 'Donations'),
              _ProfileDivider(),
              _ProfileStat(value: '${user.livesHelped}', label: 'Lives helped'),
              _ProfileDivider(),
              _ProfileStat(value: '${user.bloodGivenL}L', label: 'Blood given'),
            ],
          ),
          const SizedBox(height: 16),

          // Next eligible donation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colorPrimaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Next eligible: ${user.nextEligibleDate}',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                if (user.daysUntilEligible > 0)
                  Text(
                    'in ${user.daysUntilEligible}d',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
              ],
            ),
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
              color: context.colorTextPrimary,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: context.colorTextSecondary,
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
    return Container(height: 36, width: 1, color: context.colorBorder);
  }
}

// ── Appointments Tab ──────────────────────────────────────────────────────────
class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab();

  @override
  Widget build(BuildContext context) {
    final appointments = context.watch<AppProvider>().appointments;
    final uid = context.read<ap.AuthProvider>().currentUid ?? '';

    if (appointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded,
                  color: context.colorTextMuted, size: 48),
              const SizedBox(height: 12),
              Text(
                'No appointments yet',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Book an appointment to get started.',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: appointments
          .map((a) => _AppointmentCard(appointment: a, uid: uid))
          .toList(),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final String uid;

  const _AppointmentCard({required this.appointment, required this.uid});

  Color _statusColor(BuildContext context, AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return AppColors.primary;
      case AppointmentStatus.completed:
        return AppColors.success;
      case AppointmentStatus.cancelled:
        return context.colorTextMuted;
    }
  }

  Color _statusBg(BuildContext context, AppointmentStatus status) {
    final isDark = context.isDark;
    switch (status) {
      case AppointmentStatus.upcoming:
        return context.colorPrimaryLight;
      case AppointmentStatus.completed:
        return isDark ? AppColors.successLightDark : AppColors.successLight;
      case AppointmentStatus.cancelled:
        return context.colorSurfaceAlt;
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return 'Upcoming';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isUpcoming = appointment.status == AppointmentStatus.upcoming;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _statusBg(context, appointment.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.local_hospital_rounded,
                  color: _statusColor(context, appointment.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.centerName,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colorTextPrimary,
                      ),
                    ),
                    Text(
                      appointment.centerAddress,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg(context, appointment.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel(appointment.status),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(context, appointment.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 14, color: context.colorTextMuted),
                const SizedBox(width: 6),
                Text(
                  appointment.date,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextPrimary,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time_rounded,
                    size: 14, color: context.colorTextMuted),
                const SizedBox(width: 6),
                Text(
                  appointment.time,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colorTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (isUpcoming) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: provider.isCancelling
                    ? null
                    : () => _confirmCancel(context, provider),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: provider.isCancelling
                    ? const SizedBox(
                        height: 14,
                        width: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.danger,
                        ),
                      )
                    : const Icon(Icons.cancel_outlined, size: 16),
                label: Text(
                  provider.isCancelling ? 'Cancelling…' : 'Cancel Appointment',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Cancel appointment?',
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Your slot at ${appointment.centerName} on ${appointment.date} at ${appointment.time} will be released.',
          style: GoogleFonts.dmSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep it',
              style: GoogleFonts.dmSans(color: context.colorTextSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes, cancel',
              style: GoogleFonts.dmSans(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await provider.cancelAppointment(appointment.id);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.cancelError ?? 'Could not cancel. Please try again.',
              style: GoogleFonts.dmSans(),
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  final UserProfile user;

  const _HistoryTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final history = user.history;

    if (history.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history_rounded,
                  color: context.colorTextMuted, size: 48),
              const SizedBox(height: 12),
              Text(
                'No donations yet',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18,
                  color: context.colorTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your donation history will appear here after your first',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: context.colorTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: [...history.map((h) => _HistoryCard(history: h))],
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
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorPrimaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: AppColors.primary,
              size: 22,
            ),
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
                    color: context.colorTextPrimary,
                  ),
                ),
                Text(
                  '${history.type} · ${history.date}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: context.colorTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.isDark
                  ? AppColors.successLightDark
                  : AppColors.successLight,
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
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: user.challenges
          .map((c) => _ChallengeCard(challenge: c))
          .toList(),
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
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorBorder),
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
                    color: context.colorTextPrimary,
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
              color: context.colorTextSecondary,
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
                    backgroundColor: context.colorLevelBg,
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
                  color: context.colorTextSecondary,
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
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
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
        color: badge.earned ? context.colorSurface : context.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: badge.earned
              ? AppColors.primary.withValues(alpha: 0.3)
              : context.colorBorder,
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
                    0,      0,      0,      1, 0,
                  ]),
            child: Text(badge.emoji, style: const TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 6),
          Text(
            badge.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: badge.earned
                  ? context.colorTextPrimary
                  : context.colorTextMuted,
            ),
          ),
          if (!badge.earned) ...[
            const SizedBox(height: 3),
            Text(
              'Locked',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                color: context.colorTextMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Community Tab ───────────────────────────────────────────────────────────────
class _CommunityTab extends StatelessWidget {
  final UserProfile user;

  const _CommunityTab({required this.user});

  @override
  Widget build(BuildContext context) {
    final donors = [
      _DemoDonor('Mia Santos', '🏆', 18),
      _DemoDonor(user.name, '❤️', user.donationsTotal),
      _DemoDonor('Noah Reyes', '🌟', 12),
      _DemoDonor('Ava Cruz', '🩸', 9),
      _DemoDonor('Liam Garcia', '✨', 7),
    ]..sort((a, b) => b.donations.compareTo(a.donations));

    final userRank = donors.indexWhere((donor) => donor.name == user.name) + 1;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: context.isDark
                  ? [AppColors.primaryLightDark, AppColors.warningLightDark]
                  : [const Color(0xFFFFE3E5), const Color(0xFFFFF3D8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Text('🌈', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  userRank == 1
                      ? 'You\'re leading the kindness list!'
                      : 'Every donation moves you up the kindness list.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              'Community heroes',
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
            const Spacer(),
            Text(
              'This year',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: context.colorTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...donors.asMap().entries.map(
              (entry) => _DonorRankCard(
                rank: entry.key + 1,
                donor: entry.value,
                isCurrentUser: entry.value.name == user.name,
              ),
            ),
        const SizedBox(height: 8),
        Text(
          'Demo rankings — connect your community to see real heroes here.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: context.colorTextMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _DemoDonor {
  final String name;
  final String emoji;
  final int donations;

  const _DemoDonor(this.name, this.emoji, this.donations);
}

class _DonorRankCard extends StatelessWidget {
  final int rank;
  final _DemoDonor donor;
  final bool isCurrentUser;

  const _DonorRankCard({
    required this.rank,
    required this.donor,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser ? context.colorPrimaryLight : context.colorSurface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isCurrentUser
              ? AppColors.primary.withValues(alpha: 0.35)
              : context.colorBorder,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              rank <= 3 ? ['🥇', '🥈', '🥉'][rank - 1] : '#$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: rank <= 3 ? 18 : 12,
                fontWeight: FontWeight.w700,
                color: context.colorTextSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 19,
            backgroundColor: isCurrentUser
                ? (context.isDark ? AppColors.surfaceDark : Colors.white)
                : context.colorSurfaceAlt,
            child:
                Text(donor.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isCurrentUser ? '${donor.name} (you)' : donor.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
          ),
          Text(
            '${donor.donations} drops',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isCurrentUser ? AppColors.primary : context.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Settings Tab ────────────────────────────────────────────────────────────────
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    final auth = context.read<ap.AuthProvider>();
    final demoMode = auth.demoMode;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      children: [
        Text(
          'Settings',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _SettingTile(
          icon: Icons.bloodtype_rounded,
          iconColor: AppColors.primary,
          title: 'Default blood type',
          value: 'O+',
          onTap: () {},
        ),
        _SettingTile(
          icon: Icons.notifications_rounded,
          iconColor: AppColors.warning,
          title: 'Push notifications',
          trailing: Switch(
            value: true,
            activeThumbColor: AppColors.primary,
            onChanged: (v) {},
          ),
        ),
        _SettingTile(
          icon: Icons.dark_mode_rounded,
          iconColor: context.colorTextSecondary,
          title: 'Dark mode',
          trailing: Switch(
            value: context.watch<AppProvider>().isDarkMode,
            activeThumbColor: AppColors.primary,
            onChanged: (v) {
              context.read<AppProvider>().toggleDarkMode();
            },
          ),
        ),
        const _SectionDivider(title: 'Support'),
         _SettingTile(
          icon: Icons.help_rounded,
          iconColor: AppColors.primary,
          title: 'Help & FAQ',
          onTap: () {
            Navigator.of(context).push(
              SlideUpPageRoute(page: const HelpScreen()),
            );
          },
        ),
        _SettingTile(
          icon: Icons.feedback_rounded,
          iconColor: AppColors.accent,
          title: 'Send feedback',
          onTap: () {
            Navigator.of(context).push(
              SlideUpPageRoute(page: const FeedbackScreen()),
            );
          },
        ),
        _SettingTile(
          icon: Icons.info_rounded,
          iconColor: context.colorTextSecondary,
          title: 'About LifeLink',
          onTap: () {},
        ),
        if (!demoMode) ...[
          const _SectionDivider(title: 'Account'),
          _SettingTile(
            icon: Icons.edit_rounded,
            iconColor: AppColors.primary,
            title: 'Edit profile',
            onTap: () {},
          ),
          _SettingTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.danger,
            title: 'Sign out',
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(
                    'Sign out',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                  ),
                  content: Text('Are you sure you want to sign out?',
                      style: GoogleFonts.dmSans()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(
                        'Sign out',
                        style: GoogleFonts.dmSans(color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await auth.signOut();
              }
            },
          ),
        ],
      ],
    );
  }
}

class _SectionDivider extends StatelessWidget {
  final String title;
  const _SectionDivider({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.colorTextMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.value,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: onTap != null ? context.colorSurfaceAlt : context.colorSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colorBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colorTextPrimary,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: context.colorTextSecondary,
                ),
              ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              trailing!,
            ],
            if (onTap != null && trailing == null && value == null)
              SizedBox(
                width: 34,
                child: Icon(Icons.chevron_right_rounded,
                    color: context.colorTextMuted, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}
