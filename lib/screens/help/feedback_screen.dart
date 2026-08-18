import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  bool _isSubmitting = false;

  final _categories = [
    'Bug Report',
    'Feature Request',
    'General Feedback',
    'Donation Experience',
    'Other',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Thank you! Your feedback helps us improve LifeLink.',
          style: GoogleFonts.dmSans(fontSize: 13),
        ),
        backgroundColor: context.colorSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: context.colorBorder),
        ),
      ),
    );

    Navigator.of(context)
      ..pop()
      ..pop();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send Feedback',
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
          Text(
            'We\'d love to hear from you. Have a suggestion, found a bug, '
            'or just want to tell us how we\'re doing?',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              height: 1.5,
              color: context.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySelector(),
                const SizedBox(height: 16),
                _buildSubjectField(),
                const SizedBox(height: 16),
                _buildMessageField(),
                const SizedBox(height: 20),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: context.colorTextPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final selected = _selectedCategory == cat;
            return GestureDetector(
              onTap: () {
                setState(() => _selectedCategory = cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? (context.isDark
                          ? AppColors.primary
                          : AppColors.primaryLight)
                      : context.colorSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : context.colorBorder,
                  ),
                ),
                child: Text(
                  cat,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? (context.isDark
                            ? Colors.white
                            : AppColors.primary)
                        : context.colorTextPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectField() {
    return TextFormField(
      controller: _subjectController,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter a subject';
        }
        if (v.trim().length < 3) {
          return 'Subject must be at least 3 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Subject',
        hintText: 'Brief summary of your feedback',
        labelStyle: GoogleFonts.dmSans(fontSize: 13),
        hintStyle: GoogleFonts.dmSans(fontSize: 13),
        filled: true,
        fillColor: context.colorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      style: GoogleFonts.dmSans(fontSize: 13),
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildMessageField() {
    return TextFormField(
      controller: _messageController,
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter your feedback message';
        }
        if (v.trim().length < 10) {
          return 'Message must be at least 10 characters';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: 'Message',
        hintText: 'Tell us more...',
        labelStyle: GoogleFonts.dmSans(fontSize: 13),
        hintStyle: GoogleFonts.dmSans(fontSize: 13),
        filled: true,
        fillColor: context.colorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: context.colorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      style: GoogleFonts.dmSans(fontSize: 13),
      textInputAction: TextInputAction.newline,
      maxLines: 6,
      minLines: 4,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'Submit Feedback',
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
