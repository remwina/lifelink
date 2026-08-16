import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';
import '../../../models/user_profile.dart';
import '../../../widgets/app_card.dart';

class ImpactCard extends StatelessWidget {
  final UserProfile user;

  const ImpactCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Your impact',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.colorTextPrimary,
                ),
              ),
              const Spacer(),
              _StreakBadge(count: user.streakCount),
            ],
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: [
                _StatTile(
                    value: '${user.donationsTotal}',
                    label: 'Donations\ntotal'),
                const SizedBox(width: 8),
                _StatTile(
                    value: '${user.livesHelped}',
                    label: 'Lives\nhelped'),
                const SizedBox(width: 8),
                _StatTile(
                    value: '${user.bloodGivenL}L',
                    label: 'Blood\ngiven'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int count;

  const _StreakBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
         color: context.isDark ? AppColors.warningLightDark : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            '$count-donation streak',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: context.colorSurfaceAlt,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 22,
                  color: context.colorTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: context.colorTextSecondary,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
