import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme.dart';
import '../../../core/theme_extensions.dart';

class BookingProgress extends StatelessWidget {
  final int step; // 0-indexed 0..2

  const BookingProgress({super.key, required this.step});

  static const _labels = ['Time Slot', 'Screener', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector
          final leftStep = i ~/ 2;
          final done = step > leftStep;
          return Expanded(
            child: Container(
               height: 2,
               color: done ? AppColors.primary : context.colorBorder,
            ),
          );
        }
        final idx = i ~/ 2;
        final done = step > idx;
        final active = step == idx;
        return _StepCircle(
          index: idx,
          label: _labels[idx],
          done: done,
          active: active,
        );
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final String label;
  final bool done;
  final bool active;

  const _StepCircle({
    required this.index,
    required this.label,
    required this.done,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    final bg = done
        ? AppColors.success
        : active
            ? AppColors.primary
            : context.colorBorder;
    final fg = (done || active) ? Colors.white : context.colorTextMuted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                : Text(
                    '${index + 1}',
                    style: GoogleFonts.dmSans(
                        fontSize: 12, fontWeight: FontWeight.w700, color: fg),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? AppColors.primary : context.colorTextMuted,
          ),
        ),
      ],
    );
  }
}
