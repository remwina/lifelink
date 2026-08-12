import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/transitions.dart';
import '../../models/booking.dart';
import '../../models/user_profile.dart';
import '../../providers/app_provider.dart';
import '../../providers/auth_provider.dart' as ap;
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
              // Animated PULSE alert button
              const _PulseButton(),
            ],
          ),

          // ── Content ───────────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16, 4, 16, 24 + bottomPad),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Greeting ────────────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 60),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Critical alert for user's blood type ────────────────────
                if (myTypeIsLow) ...[
                  StaggeredFadeSlide(
                    delay: const Duration(milliseconds: 120),
                    child: _CriticalBloodAlert(
                      bloodType: user.bloodType,
                      percentage: myLevel.percentage,
                      onBook: () => provider.setIndex(2),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Eligibility card ─────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 160),
                  child: EligibilityCard(
                    user: user,
                    onBookNow: () => provider.setIndex(2),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Quick actions ────────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 210),
                  child: _QuickActionsRow(
                    onBook: () => provider.setIndex(2),
                    onMap: () => provider.setIndex(3),
                    onHistory: () => provider.setIndex(4),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Upcoming appointment ─────────────────────────────────────
                if (nextAppointment != null) ...[
                  StaggeredFadeSlide(
                    delay: const Duration(milliseconds: 250),
                    child: _UpcomingAppointmentCard(
                        appointment: nextAppointment),
                  ),
                  const SizedBox(height: 14),
                ],

                // ── Blood supply ─────────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 300),
                  child: BloodSupplyGridWidget(highlightType: user.bloodType),
                ),
                const SizedBox(height: 14),

                // ── Impact ───────────────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 350),
                  child: ImpactCard(user: user),
                ),
                const SizedBox(height: 14),

                // ── Nearby centers ───────────────────────────────────────────
                StaggeredFadeSlide(
                  delay: const Duration(milliseconds: 400),
                  child: NearbyCentersCard(
                    onBook: (center) {
                      provider.selectCenter(center);
                      provider.setIndex(2);
                    },
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulsing PULSE button ──────────────────────────────────────────────────────
class _PulseButton extends StatefulWidget {
  const _PulseButton();

  @override
  State<_PulseButton> createState() => _PulseButtonState();
}

class _PulseButtonState extends State<_PulseButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    return GestureDetector(
      onTap: provider.showPulseAlert,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple ring behind the button
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => Transform.scale(
                scale: _pulseScale.value,
                child: Opacity(
                  opacity: _pulseOpacity.value,
                  child: Container(
                    width: 70,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
            // Actual pill button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, _) => Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          AppColors.primary,
                          AppColors.primaryDark,
                          _ctrl.value,
                        )!,
                        shape: BoxShape.circle,
                      ),
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
          ],
        ),
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
      child: TapScaleEffect(
        onTap: onTap,
        scale: 0.92,
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
  final Appointment appointment;

  const _UpcomingAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final uid = context.read<ap.AuthProvider>().currentUid ?? '';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      appointment.centerName,
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
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: provider.isCancelling
                  ? null
                  : () => _confirmCancel(context, provider, uid),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: provider.isCancelling
                  ? const SizedBox(
                      height: 13,
                      width: 13,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.danger,
                      ),
                    )
                  : const Icon(Icons.cancel_outlined, size: 15),
              label: Text(
                provider.isCancelling ? 'Cancelling…' : 'Cancel Appointment',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancel(
      BuildContext context, AppProvider provider, String uid) async {
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
              style: GoogleFonts.dmSans(color: AppColors.textSecondary),
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
