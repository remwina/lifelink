import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';
import '../../../models/booking.dart';
import '../../../providers/app_provider.dart';
import '../widgets/booking_progress.dart';

class ScreenerStep extends StatelessWidget {
  const ScreenerStep({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.read<AppProvider>().goBack(),
        ),
        title: Text(
          'Health Screener',
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
                            const BookingProgress(step: 1),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: context.isDark ? AppColors.warningLightDark : AppColors.warningLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFFCC80),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    '⚠️',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Please answer honestly. All responses are confidential and used to ensure donor safety.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...screenerQuestions.map(
                              (q) => _QuestionCard(
                                question: q,
                                answer: provider.screenerAnswers[q.id],
                                onAnswer: (val) => context
                                    .read<AppProvider>()
                                    .setScreenerAnswer(q.id, val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _ScreenerBottomBar(
                      enabled: provider.screenerComplete,
                      passed: provider.screenerPassed,
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

class _QuestionCard extends StatelessWidget {
  final ScreenerQuestion question;
  final bool? answer;
  final void Function(bool) onAnswer;

  const _QuestionCard({
    required this.question,
    required this.answer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colorSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: answer == null
                ? context.colorBorder
                : answer!
                ? const Color(0xFFA5D6A7)
                : const Color(0xFFEF9A9A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _AnswerBtn(
                label: 'Yes',
                selected: answer == true,
                positive: true,
                onTap: () => onAnswer(true),
              ),
              const SizedBox(width: 10),
              _AnswerBtn(
                label: 'No',
                selected: answer == false,
                positive: false,
                onTap: () => onAnswer(false),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnswerBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final bool positive;
  final VoidCallback onTap;

  const _AnswerBtn({
    required this.label,
    required this.selected,
    required this.positive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selColor = positive ? AppColors.success : AppColors.danger;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? selColor.withValues(alpha: 0.12)
                : context.colorSurfaceAlt,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? selColor : context.colorBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? selColor : context.colorTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScreenerBottomBar extends StatelessWidget {
  final bool enabled;
  final bool passed;
  final VoidCallback onNext;

  const _ScreenerBottomBar({
    required this.enabled,
    required this.passed,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorBackground,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (enabled && !passed)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.dangerLightDark : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '⚠️ Based on your answers, you may not be eligible to donate today. Please consult a healthcare provider.',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.danger,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (enabled && passed) ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: (enabled && passed)
                    ? AppColors.primary
                    : context.colorBorder,
                foregroundColor: (enabled && passed)
                    ? Colors.white
                    : context.colorTextMuted,
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
        ],
      ),
    );
  }
}
