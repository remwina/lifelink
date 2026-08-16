import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/theme_extensions.dart';
import '../../models/blood_supply.dart';
import '../../models/donation_center.dart';
import '../../providers/app_provider.dart';

class PulseAlertOverlay extends StatefulWidget {
  const PulseAlertOverlay({super.key});

  @override
  State<PulseAlertOverlay> createState() => _PulseAlertOverlayState();
}

class _PulseAlertOverlayState extends State<PulseAlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeOutBack),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeIn),
    );
    _pulse.forward();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _dismiss(BuildContext context) {
    _pulse.reverse().then((_) {
      if (mounted) context.read<AppProvider>().dismissPulseAlert();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        color: Colors.black.withValues(alpha: 0.65),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _dismiss(context),
                  behavior: HitTestBehavior.opaque,
                  child: const SizedBox.expand(),
                ),
              ),
              ScaleTransition(
                scale: _scaleAnim,
                child: _AlertSheet(onDismiss: () => _dismiss(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertSheet extends StatelessWidget {
  final VoidCallback onDismiss;

  const _AlertSheet({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Find the lowest blood supply level to highlight
    final supply = provider.bloodSupply;
    BloodSupplyEntry? critical;
    if (supply.isNotEmpty) {
      critical = supply.reduce(
          (a, b) => a.percentage < b.percentage ? a : b);
    }

    // Nearest open center
    final openCenters = provider.centers
        .where((c) => c.slotStatus != SlotStatus.full)
        .toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final nearest = openCenters.isNotEmpty ? openCenters.first : null;

    final bloodType = critical?.type ?? 'O−';
    final supplyPct = critical != null ? '${critical.percentage}%' : '—';
    final centersCount = openCenters.length.toString();

    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Red header band
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🚨 PULSE ALERT',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Critical Blood Shortage',
                        style: GoogleFonts.dmSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'LIVE',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats row — real data
                Row(
                  children: [
                    _AlertStat(
                      value: bloodType,
                      label: 'Blood type needed',
                      bgColor: context.isDark ? AppColors.dangerLightDark : AppColors.dangerLight,
                      textColor: AppColors.danger,
                    ),
                    const SizedBox(width: 10),
                    _AlertStat(
                      value: supplyPct,
                      label: 'Supply remaining',
                      bgColor: context.isDark ? AppColors.warningLightDark : AppColors.warningLight,
                      textColor: AppColors.warning,
                    ),
                    const SizedBox(width: 10),
                    _AlertStat(
                      value: centersCount,
                      label: 'Centers open',
                      bgColor: context.isDark ? AppColors.successLightDark : AppColors.successLight,
                      textColor: AppColors.success,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                Text(
                  nearest != null
                      ? '${nearest.name} and ${(openCenters.length - 1).clamp(0, 99)} other '
                        'center${openCenters.length != 2 ? 's' : ''} urgently need $bloodType donors. '
                        'Supply is critically low. Your donation can save up to 3 lives today.'
                      : 'Blood banks in Metro Manila urgently need $bloodType donors. '
                        'Supply is critically low at $supplyPct. Your donation can save lives.',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: context.colorTextSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Nearest center — real data
                if (nearest != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorSurfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.colorBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.colorPrimaryLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.location_on_rounded,
                              color: AppColors.primary, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nearest.name,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.colorTextPrimary,
                                ),
                              ),
                              Text(
                                '${nearest.distanceLabel} away · ${nearest.slotLabel}',
                                style: GoogleFonts.dmSans(
                                  fontSize: 11,
                                  color: context.colorTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          nearest.distanceLabel,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Fix #11: index 2 = Booking tab (was wrongly 1)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      onDismiss();
                      // Pre-select nearest center if available
                      if (nearest != null) {
                        context.read<AppProvider>().selectCenter(nearest);
                      }
                      context.read<AppProvider>().setIndex(2);
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 16),
                    label: const Text('Book Appointment Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      textStyle: GoogleFonts.dmSans(
                          fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: context.colorTextSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Maybe later',
                      style: GoogleFonts.dmSans(fontSize: 14),
                    ),
                  ),
                ),
                SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertStat extends StatelessWidget {
  final String value;
  final String label;
  final Color bgColor;
  final Color textColor;

  const _AlertStat({
    required this.value,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.dmSerifDisplay(
                fontSize: 22,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
