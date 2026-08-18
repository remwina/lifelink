import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static final faqs = [
    FAQItem(
      question: 'How often can I donate blood?',
      answer:
          'You can donate whole blood every 56 days (about every 8 weeks). '
          'Double red cell donations require 112 days between donations. '
          'Platelet donations can be done more frequently — up to 24 times per year.',
    ),
    FAQItem(
      question: 'What should I do before donating?',
      answer:
          '• Eat a healthy meal with iron-rich foods 2–3 hours before\n'
          '• Drink plenty of water (avoid caffeine and alcohol)\n'
          '• Bring a valid government-issued ID\n'
          '• Get a good night\'s sleep',
    ),
    FAQItem(
      question: 'What are the eligibility requirements?',
      answer:
          '• At least 16 years old (varies by location)\n'
          '• Weigh at least 110 lbs (50 kg)\n'
          '• Feeling healthy on the day of donation\n'
          '• No medications that affect donation eligibility\n'
          '• No recent tattoos or piercings (within 6 months–1 year)',
    ),
    FAQItem(
      question: 'Is blood donation safe?',
      answer:
          'Yes. All equipment is sterile, single-use, and disposable. '
          'Needles and collection bags are never reused. '
          'The entire donation process is monitored by trained healthcare professionals.',
    ),
    FAQItem(
      question: 'How long does the process take?',
      answer:
          'The actual blood draw takes 8–10 minutes. '
          'The full process — including registration, screening, and recovery — takes about 45–60 minutes.',
    ),
    FAQItem(
      question: 'Can I donate if I have a chronic condition?',
      answer:
          'Some conditions like diabetes, high blood pressure, or epilepsy may still allow you to donate '
          'if your condition is stable and well-controlled. '
          'You\'ll be asked health questions at the center to determine eligibility.',
    ),
    FAQItem(
      question: 'What happens to my blood after donation?',
      answer:
          'Whole blood is separated into red cells, plasma, platelets, and cryoprecipitate. '
          'Each component is used to treat different conditions — from surgery patients to cancer survivors. '
          'One donation can help save up to 3 lives.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help & FAQ',
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
              color: isDark ? AppColors.primaryLightDark : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.favorite_rounded,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Every question you have about blood donation — answered.\n'
                    'Still need help? Use the feedback button to reach us directly.',
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
            'Frequently Asked Questions',
            style: GoogleFonts.dmSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: context.colorTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...faqs.asMap().entries.map((entry) {
            final i = entry.key;
            final faq = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _FaqTile(faq: faq, index: i),
            );
          }),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});
}

class _FaqTile extends StatefulWidget {
  final FAQItem faq;
  final int index;

  const _FaqTile({required this.faq, required this.index});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _heightAnim;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _heightAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _expanded = !_expanded;
      if (_expanded) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: context.colorSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      '${widget.index + 1}',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.faq.question,
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.colorTextPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 240),
                    turns: _expanded ? 0.25 : 0,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: context.colorTextMuted,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizeTransition(
            sizeFactor: _heightAnim,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    color: context.colorBorder,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14, top: 10),
                    child: Text(
                      widget.faq.answer,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        height: 1.6,
                        color: context.colorTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
