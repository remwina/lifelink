import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/app_provider.dart';
import 'steps/step_slot_picker.dart';
import 'steps/step_screener.dart';
import 'steps/step_review.dart';
import 'steps/step_confirmed.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.05, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: _stepWidget(provider),
      ),
    );
  }

  Widget _stepWidget(AppProvider provider) {
    switch (provider.bookingStep) {
      case 0:
        return const SlotPickerStep(key: ValueKey('slot'));
      case 1:
        return const ScreenerStep(key: ValueKey('screener'));
      case 2:
        return const ReviewStep(key: ValueKey('review'));
      case 3:
        return const ConfirmedStep(key: ValueKey('confirmed'));
      default:
        return const SlotPickerStep(key: ValueKey('slot'));
    }
  }
}
