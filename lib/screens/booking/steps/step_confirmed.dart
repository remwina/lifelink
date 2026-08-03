import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/booking.dart';
import '../../../providers/app_provider.dart';

class ConfirmedStep extends StatelessWidget {
  const ConfirmedStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final center = provider.selectedCenter;
    final slot = provider.selectedSlot;
    final date = bookingDates[provider.selectedDateIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // Success animation circle
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.4), width: 4),
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 52),
              ),
              const SizedBox(height: 24),

              Text(
                'You\'re confirmed!',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment has been booked. See you there!',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // Booking ticket
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    _TicketRow(
                      emoji: '📅',
                      label: 'Date',
                      value: date,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    _TicketRow(
                      emoji: '⏰',
                      label: 'Time',
                      value: slot?.time ?? '—',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.border, height: 1),
                    ),
                    _TicketRow(
                      emoji: '📍',
                      label: 'Address',
                      value: center?.address ?? '—',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Reminder box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
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

              const Spacer(),

              // Actions
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
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
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => provider.resetBooking(),
                child: Text(
                  'Book another appointment',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
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
                  fontSize: 11, color: AppColors.textMuted),
            ),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
