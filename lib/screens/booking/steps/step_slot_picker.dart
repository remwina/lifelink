import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../models/booking.dart';
import '../../../models/donation_center.dart';
import '../../../providers/app_provider.dart';
import '../widgets/booking_progress.dart';

class SlotPickerStep extends StatelessWidget {
  const SlotPickerStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    // Ensure a center is always selected in the provider — sync the fallback
    // on the next frame so we don't call setState during build.
    if (provider.selectedCenter == null && provider.centers.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.selectCenter(provider.centers.first);
      });
    }

    final center = provider.selectedCenter ??
        (provider.centers.isNotEmpty ? provider.centers.first : null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Book Appointment',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 20,
            color: AppColors.textPrimary,
          ),
        ),
        automaticallyImplyLeading: false,
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
                            const BookingProgress(step: 0),
                            const SizedBox(height: 20),

                            // Center selector
                            Text(
                              'Donation Center',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (center != null)
                              _CenterSelector(
                                selected: center,
                                onTap: provider.centers.length > 1
                                    ? () => _showCenterPicker(
                                          context,
                                          provider.centers,
                                          provider.selectCenter,
                                        )
                                    : null,
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Text(
                                  'Loading centers…',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Date picker
                            Text(
                              'Select Date',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DatePickerWidget(
                              selectedIndex: provider.selectedDateIndex,
                              onSelect: provider.selectDate,
                            ),
                            const SizedBox(height: 20),

                            // Time slots
                            Text(
                              'Select Time',
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SlotGrid(
                              selected: provider.selectedSlot,
                              onSelect: provider.selectSlot,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _BottomBar(
                      enabled: provider.selectedSlot != null,
                      onNext: provider.advanceBooking,
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

void _showCenterPicker(
  BuildContext context,
  List<DonationCenter> centers,
  void Function(DonationCenter) onSelect,
) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Donation Center',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ...centers.map(
                (c) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                  title: Text(
                    c.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    '${c.address} · ${c.hours}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  onTap: () {
                    onSelect(c);
                    Navigator.of(ctx).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CenterSelector extends StatelessWidget {
  final DonationCenter selected;
  final VoidCallback? onTap;

  const _CenterSelector({required this.selected, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected.name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${selected.address} · ${selected.hours}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: onTap != null ? AppColors.textMuted : AppColors.border,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class DatePickerWidget extends StatelessWidget {
  final int selectedIndex;
  final void Function(int) onSelect;

  const DatePickerWidget({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: bookingDates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == selectedIndex;
          final parts = bookingDates[i].split(', ');
          return GestureDetector(
            onTap: () => onSelect(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    parts[0],
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : AppColors.textMuted,
                    ),
                  ),
                  Text(
                    parts[1],
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SlotGrid extends StatelessWidget {
  final TimeSlot? selected;
  final void Function(TimeSlot) onSelect;

  const _SlotGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 3 columns, 2 gaps of 10px
        final cellW = (constraints.maxWidth - 20) / 3;
        final cellH = (cellW * 0.45).clamp(38.0, 50.0);

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: availableSlots.map((slot) {
            final isSelected = selected?.id == slot.id;
            final isDisabled = !slot.available;

            Color bg, fg, border;
            if (isDisabled) {
              bg = const Color(0xFFF0EDE8);
              fg = AppColors.textMuted;
              border = AppColors.border;
            } else if (isSelected) {
              bg = AppColors.primary;
              fg = Colors.white;
              border = AppColors.primary;
            } else {
              bg = AppColors.surface;
              fg = AppColors.textPrimary;
              border = AppColors.border;
            }

            return GestureDetector(
              onTap: isDisabled ? null : () => onSelect(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: cellW,
                height: cellH,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: border),
                ),
                child: Center(
                  child: Text(
                    isDisabled ? '${slot.time}\nFull' : slot.time,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: fg,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool enabled;
  final VoidCallback onNext;

  const _BottomBar({required this.enabled, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: enabled ? onNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: enabled ? AppColors.primary : AppColors.border,
            foregroundColor: enabled ? Colors.white : AppColors.textMuted,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            'Continue',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
