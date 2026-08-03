import 'package:flutter/material.dart';
import '../core/theme.dart';

class BloodDropIcon extends StatelessWidget {
  final double size;
  final Color color;

  const BloodDropIcon({super.key, this.size = 24, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BloodDropPainter(color: color),
    );
  }
}

class _BloodDropPainter extends CustomPainter {
  final Color color;
  _BloodDropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    final path = Path();
    // pointed top, round bottom
    path.moveTo(w * 0.5, 0);
    path.cubicTo(w * 0.5, 0, w, h * 0.5, w, h * 0.65);
    path.arcToPoint(Offset(0, h * 0.65),
        radius: Radius.circular(w * 0.5), clockwise: false);
    path.cubicTo(0, h * 0.5, w * 0.5, 0, w * 0.5, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BloodDropPainter old) => old.color != color;
}
