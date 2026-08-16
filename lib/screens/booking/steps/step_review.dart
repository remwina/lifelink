import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';
import '../../../models/booking.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/auth_provider.dart' as ap;
import '../widgets/booking_progress.dart';

class ReviewStep extends StatelessWidget {
  const ReviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final uid = context.read<ap.AuthProvider>().currentUid ?? '';
    final center = provider.selectedCenter;
    final slot = provider.selectedSlot;
    final date = bookingDates[provider.selectedDateIndex];
    final user = provider.user;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.read<AppProvider>().goBack(),
        ),
        title: Text(
          'Review Booking',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: context.colorTextPrimary,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 700
                ? 700.0
                : constraints.maxWidth;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BookingProgress(step: 2),
                            const SizedBox(height: 20),

                            // Summary card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.colorSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: context.colorBorder),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Appointment Summary',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: context.colorTextPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _ReviewRow(
                                    icon: Icons.person_rounded,
                                    label: 'Donor',
                                    value:
                                        '${user?.name ?? '—'} · ${user?.bloodType ?? '—'}',
                                  ),
                                  const Divider(height: 20),
                                  _ReviewRow(
                                    icon: Icons.local_hospital_rounded,
                                    label: 'Center',
                                    value: center?.name ?? '—',
                                  ),
                                  const Divider(height: 20),
                                  _ReviewRow(
                                    icon: Icons.place_rounded,
                                    label: 'Address',
                                    value: center?.address ?? '—',
                                  ),
                                  const Divider(height: 20),
                                  _ReviewRow(
                                    icon: Icons.calendar_today_rounded,
                                    label: 'Date',
                                    value: date,
                                  ),
                                  const Divider(height: 20),
                                  _ReviewRow(
                                    icon: Icons.access_time_rounded,
                                    label: 'Time',
                                    value: slot?.time ?? '—',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // What to bring
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? AppColors.successLightDark
                                    : AppColors.successLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: context.isDark
                                      ? AppColors.successLightDark
                                      : const Color(0xFFA5D6A7),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '✅ What to bring',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...[
                                    'Valid government-issued ID',
                                    'Eat a full meal before visiting',
                                    'Drink at least 2 glasses of water',
                                    'Wear clothing with sleeves that roll up easily',
                                  ].map(
                                    (item) => Padding(
                                      padding:
                                          const EdgeInsets.only(top: 6),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            color: AppColors.success,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            item,
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: AppColors.success,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      color: context.colorSurface,
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Column(
                        children: [
                          if (provider.bookingError != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: context.isDark
                                    ? AppColors.dangerLightDark
                                    : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                provider.bookingError!,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: provider.isConfirming
                                  ? null
                                  : () => provider.confirmBooking(uid),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: provider.isConfirming
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Confirm Appointment',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: context.colorPrimaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: context.colorTextMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colorTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
