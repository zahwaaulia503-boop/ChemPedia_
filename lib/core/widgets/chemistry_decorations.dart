import 'dart:math';
import 'package:flutter/material.dart';

/// Ornamen latar belakang kimia berupa gelembung dan cincin benzena samar
class ChemistryDoodlePainter extends CustomPainter {
  final Color color;

  ChemistryDoodlePainter({this.color = const Color(0xFF7E57C2)});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    // Gambar gelembung-gelembung gas kecil
    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 4.0 + random.nextDouble() * 12.0;

      canvas.drawCircle(Offset(x, y), radius, fillPaint);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Gambar heksagon (cincin benzena) di sudut
    _drawHexagon(canvas, Offset(size.width * 0.85, size.height * 0.15), 28, paint);
    _drawHexagon(canvas, Offset(size.width * 0.12, size.height * 0.75), 20, paint);

    // Gambar elips orbit atom
    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.88, size.height * 0.85),
      width: 60,
      height: 25,
    );
    canvas.save();
    canvas.translate(orbitRect.center.dx, orbitRect.center.dy);
    canvas.rotate(pi / 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 60, height: 25),
      paint,
    );
    canvas.restore();
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (pi / 3) * i - (pi / 6);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Widget pembungkus dengan dekorasi kimia
class ChemistryBackground extends StatelessWidget {
  final Widget child;
  final Color doodleColor;

  const ChemistryBackground({
    super.key,
    required this.child,
    this.doodleColor = const Color(0xFF7E57C2),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: ChemistryDoodlePainter(color: doodleColor),
          ),
        ),
        child,
      ],
    );
  }
}
