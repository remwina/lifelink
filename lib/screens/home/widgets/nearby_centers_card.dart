import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../models/donation_center.dart';
import '../../../widgets/app_card.dart';

class NearbyCentersCard extends StatelessWidget {
  final List<DonationCenter> centers;
  final void Function(DonationCenter) onBook;

  const NearbyCentersCard({
    super.key,
    required this.centers,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final visible = centers.take(3).toList();

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby centers',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...visible.asMap().entries.map((e) {
            final isLast = e.key == visible.length - 1;
            return Column(
              children: [
                _CenterRow(center: e.value, onTap: () => onBook(e.value)),
                if (!isLast)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1, color: AppColors.border),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CenterRow extends StatelessWidget {
  final DonationCenter center;
  final VoidCallback onTap;

  const _CenterRow({required this.center, required this.onTap});

  Color get _slotColor {
    switch (center.slotStatus) {
      case SlotStatus.open:
        return AppColors.success;
      case SlotStatus.limited:
        return AppColors.warning;
      case SlotStatus.full:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          // Icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 11),
          // Name + address
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  center.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${center.address} · ${center.hours}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Distance + slot
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                center.distanceLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                center.slotLabel,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _slotColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
