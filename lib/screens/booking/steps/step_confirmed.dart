import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';
import '../../../models/booking.dart';
import '../../../providers/app_provider.dart';

class ConfirmedStep extends StatelessWidget {
  const ConfirmedStep({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedCenter = context.select((AppProvider p) => p.selectedCenter);
    final selectedSlot = context.select((AppProvider p) => p.selectedSlot);
    final selectedDateIndex = context.select((AppProvider p) => p.selectedDateIndex);
    final center = selectedCenter;
    final slot = selectedSlot;
    final date = bookingDates[selectedDateIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
                    // Success animation circle
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: context.isDark ? AppColors.successLightDark : AppColors.successLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                            width: 4),
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: AppColors.success, size: 52),
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'You\'re confirmed!',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 28,
                        color: context.colorTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your appointment has been booked. See you there!',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: context.colorTextSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Booking ticket
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: context.colorSurface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: context.colorBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _TicketRow(
                            emoji: '🏥',
                            label: 'Center',
                            value: center?.name ?? '—',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: context.colorBorder, height: 1),
                          ),
                          _TicketRow(
                            emoji: '📅',
                            label: 'Date',
                            value: date,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: context.colorBorder, height: 1),
                          ),
                          _TicketRow(
                            emoji: '⏰',
                            label: 'Time',
                            value: slot?.time ?? '—',
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: context.colorBorder, height: 1),
                          ),
                          _TicketRow(
                            emoji: '📍',
                            label: 'Address',
                            value: center?.address ?? '—',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Reminder box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.colorPrimaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Text('💧', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Reminder: Stay hydrated and eat a good meal before your appointment.',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.primary,
                                height: 1.4,
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

            // Pinned action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final provider = context.read<AppProvider>();
                        provider.resetBooking();
                        provider.setIndex(0);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Back to Home',
                        style: GoogleFonts.dmSans(
                            fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: () => context.read<AppProvider>().resetBooking(),
                    child: Text(
                      'Book another appointment',
                      style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
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

class _TicketRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _TicketRow(
      {required this.emoji, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 11, color: context.colorTextMuted),
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
      ],
    );
  }
}
