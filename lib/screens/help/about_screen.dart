import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _appVersion = '1.0.0';
  static const _appBuild = '1';

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About LifeLink',
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
            color: context.colorTextPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLightDark
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.favorite_rounded,
                    color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'LifeLink connects blood donors with patients who need them. '
                    'Find nearby donation centers, book appointments, track your '
                    'donation history, and stay eligible with personalized reminders.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textPrimaryDark.withValues(alpha: 0.9)
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'App details',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'App name', value: 'LifeLink'),
          _DetailRow(label: 'Version', value: _appVersion),
          _DetailRow(label: 'Build', value: _appBuild),
          const SizedBox(height: 24),
          Text(
            'Our mission',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We believe that every blood donation has the power to save up to '
            'three lives. LifeLink makes it simple, rewarding, and accessible for '
            'everyone to give — because together, a single drop can make the '
            'difference between life and death.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.6,
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Connect',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Have a question, suggestion, or just want to say hi? Use the '
            '"Send feedback" option in Support to reach the LifeLink team directly.',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.6,
              color: context.colorTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorBorder),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colorTextMuted,
            ),
          ),
          const SizedBox(width: 8),
          Text(':',
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: context.colorTextMuted)),
          const SizedBox(width: 8),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colorTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
