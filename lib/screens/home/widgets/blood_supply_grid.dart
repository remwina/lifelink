import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';
import '../../../models/blood_supply.dart';
import '../../../providers/app_provider.dart';
import '../../../widgets/app_card.dart';

class BloodSupplyGrid extends StatelessWidget {
  const BloodSupplyGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final supply = context.watch<AppProvider>().bloodSupply;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  '🩸 Blood Supply — Metro Manila',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: context.colorTextPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (supply.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(
                    color: AppColors.primary, strokeWidth: 2),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final cellW = (constraints.maxWidth - 36) / 4;
                final barH = (cellW * 1.1).clamp(48.0, 72.0);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(supply.length.clamp(0, 4), (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: i == 0 ? 0 : 9),
                        child: _BloodTypeBar(
                          entry: supply[i],
                          barHeight: barH,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
        ],
      ),
    );
  }
}

// Split into two rows of 4 (matching prototype layout)
class BloodSupplyGridWidget extends StatelessWidget {
  final String highlightType;

  const BloodSupplyGridWidget({super.key, this.highlightType = ''});

  @override
  Widget build(BuildContext context) {
    final supply = context.watch<AppProvider>().bloodSupply;

    if (supply.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🩸 Blood Supply — Metro Manila',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.colorTextPrimary,
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🩸 Blood Supply — Metro Manila',
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colorTextPrimary,
                      ),
                    ),
                    if (highlightType.isNotEmpty)
                      Text(
                        'Your type is highlighted',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: context.colorTextMuted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: AppColors.success, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Live',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final barH =
                ((constraints.maxWidth - 36) / 4 * 1.1).clamp(48.0, 72.0);
            final entries = supply.take(8).toList();
            final row1 = entries.length >= 4 ? entries.sublist(0, 4) : entries;
            final row2 = entries.length >= 8
                ? entries.sublist(4, 8)
                : <BloodSupplyEntry>[];
            return Column(
              children: [
                _BarRow(entries: row1, barHeight: barH, highlightType: highlightType),
                if (row2.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BarRow(entries: row2, barHeight: barH, highlightType: highlightType),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  final List<BloodSupplyEntry> entries;
  final double barHeight;
  final String highlightType;

  const _BarRow({
    required this.entries,
    required this.barHeight,
    this.highlightType = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries.asMap().entries.map((e) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: e.key == 0 ? 0 : 9),
            child: _BloodTypeBar(
              entry: e.value,
              barHeight: barHeight,
              isHighlighted: e.value.type == highlightType,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BloodTypeBar extends StatelessWidget {
  final BloodSupplyEntry entry;
  final double barHeight;
  final bool isHighlighted;

  const _BloodTypeBar({
    required this.entry,
    required this.barHeight,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final fillHeight = barHeight * (entry.percentage / 100);

    return Container(
      padding: isHighlighted
          ? const EdgeInsets.all(4)
          : EdgeInsets.zero,
      decoration: isHighlighted
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  width: 1.5),
              color: context.colorPrimaryLight.withValues(alpha: 0.4),
            )
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.type,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w700,
              color: isHighlighted ? AppColors.primary : context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: double.infinity,
                  height: barHeight,
                  color: context.colorLevelBg,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  height: fillHeight.clamp(2.0, barHeight),
                  color: entry.levelColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.percentage}%',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isHighlighted
                  ? AppColors.primary
                  : context.colorTextSecondary,
            ),
          ),
          if (entry.isLow) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.dangerLightDark : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'LOW',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                  color: AppColors.danger,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ] else
            const SizedBox(height: 14),
        ],
      ),
    );
  }
}
