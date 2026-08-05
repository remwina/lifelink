import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../widgets/blood_drop_icon.dart';
import 'widgets/blood_supply_grid.dart';
import 'widgets/eligibility_card.dart';
import 'widgets/impact_card.dart';
import 'widgets/nearby_centers_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final user = provider.user ?? const UserProfile(
      uid: '',
      name: 'Donor',
      email: '',
      bloodType: '—',
    );
    final bottomPad = MediaQuery.of(context).padding.bottom;

    // Find user's blood type supply level
    final mySupply = provider.bloodSupply
        .where((e) => e.type == user.bloodType)
        .toList();
    final myLevel = mySupply.isNotEmpty ? mySupply.first : null;
    final myTypeIsLow = myLevel != null && myLevel.isLow;

    // Next upcoming appointment from provider
    final nextAppointment = provider.nextAppointment;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────────────────────────
          SliverAppBar(
            pinned: false,
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            titleSpacing: 16,
            toolbarHeight: 56,
            title: Row(
              children: [
                const BloodDropIcon(size: 20, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(
                  'LifeLink',
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 19,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            actions: [
              // Notification bell
              Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: AppColors.textSecondary, size: 22),
                    onPressed: () => provider.setIndex(1),
                  ),
                  if (provider.unreadCount > 0)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // Pulse alert dot
              GestureDetector(
                onTap: provider.showPulseAlert,
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'PULSE',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Greeting ────────────────────────────────────────────────
                Text(
                  _greeting(),
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        user.bloodType,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Critical alert for user's blood type ────────────────────
                if (myTypeIsLow) ...[
                  _CriticalBloodAlert(
                    bloodType: user.bloodType,
                    percentage: myLevel!.percentage,
                    onBook: () => provider.setIndex(2),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Eligibility card ─────────────────────────────────────────
                EligibilityCard(
                  user: user,
                  onBookNow: () => provider.setIndex(2),
                ),
                const SizedBox(height: 14),

                // ── Quick actions ────────────────────────────────────────────
                _QuickActionsRow(
                  onBook: () => provider.setIndex(2),
                  onMap: () => provider.setIndex(3),
                  onHistory: () => provider.setIndex(4),
                ),
                const SizedBox(height: 14),

                // ── Upcoming appointment ─────────────────────────────────────
                if (nextAppointment != null) ...[
                  _UpcomingAppointmentCard(appointment: nextAppointment),
                  const SizedBox(height: 14),
                ],

                // ── Blood supply ─────────────────────────────────────────────
                BloodSupplyGridWidget(highlightType: user.bloodType),
                const SizedBox(height: 14),

                // ── Impact ───────────────────────────────────────────────────
                ImpactCard(user: user),
                const SizedBox(height: 14),

                // ── Nearby centers ───────────────────────────────────────────
                NearbyCentersCard(
                  onBook: (center) {
                    provider.selectCenter(center);
                    provider.setIndex(2);
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Critical blood alert banner ───────────────────────────────────────────────
class _CriticalBloodAlert extends StatelessWidget {
  final String bloodType;
  final int percentage;
  final VoidCallback onBook;

  const _CriticalBloodAlert({
    required this.bloodType,
    required this.percentage,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded,
                color: AppColors.danger, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your blood type ($bloodType) is critically low!',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                  ),
                ),
                Text(
                  'Only $percentage% supply remaining in Metro Manila.',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.danger),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onBook,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Book',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onMap;
  final VoidCallback onHistory;

  const _QuickActionsRow({
    required this.onBook,
    required this.onMap,
    required this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.calendar_month_rounded,
          label: 'Book',
          color: AppColors.primary,
          bg: AppColors.primaryLight,
          onTap: onBook,
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: Icons.map_rounded,
          label: 'Find Center',
          color: AppColors.success,
          bg: AppColors.successLight,
          onTap: onMap,
        ),
        const SizedBox(width: 10),
        _QuickAction(
          icon: Icons.history_rounded,
          label: 'History',
          color: AppColors.accent,
          bg: const Color(0xFFFFF3E0),
          onTap: onHistory,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Upcoming appointment card ─────────────────────────────────────────────────
class _UpcomingAppointmentCard extends StatelessWidget {
  final dynamic appointment; // Appointment model

  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upcoming Appointment',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appointment.centerName ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${appointment.date}  ·  ${appointment.time}',
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Confirmed',
              style: GoogleFonts.dmSans(
                fontSize: 11,
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
