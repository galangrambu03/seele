import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';

enum MascotExpression { happy, cheering, curious }

/// A custom-drawn illustrative mascot companion for SEELE.
/// Built with pure vector canvas strokes and shapes (no emojis, no raster images).
class SeeleMascot extends StatelessWidget {
  final double size;
  final MascotExpression expression;

  const SeeleMascot({
    super.key,
    this.size = 72,
    this.expression = MascotExpression.happy,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SeeleMascotPainter(expression: expression),
      ),
    );
  }
}

class _SeeleMascotPainter extends CustomPainter {
  final MascotExpression expression;

  _SeeleMascotPainter({required this.expression});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.52);

    // 1. Soft ambient glow behind mascot
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColor.cyan.withValues(alpha: 0.25),
          AppColor.lime.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: w * 0.48));
    canvas.drawCircle(center, w * 0.48, glowPaint);

    // 2. Playful floating ears / horns
    final leftEarPath = Path()
      ..moveTo(w * 0.30, h * 0.32)
      ..quadraticBezierTo(w * 0.18, h * 0.12, w * 0.28, h * 0.10)
      ..quadraticBezierTo(w * 0.36, h * 0.16, w * 0.38, h * 0.28)
      ..close();

    final rightEarPath = Path()
      ..moveTo(w * 0.70, h * 0.32)
      ..quadraticBezierTo(w * 0.82, h * 0.12, w * 0.72, h * 0.10)
      ..quadraticBezierTo(w * 0.64, h * 0.16, w * 0.62, h * 0.28)
      ..close();

    final earPaint = Paint()
      ..color = AppColor.surfaceHighlight
      ..style = PaintingStyle.fill;
    final earTipPaint = Paint()
      ..color = AppColor.cyan
      ..style = PaintingStyle.fill;

    canvas.drawPath(leftEarPath, earPaint);
    canvas.drawPath(rightEarPath, earPaint);

    // Ear tip accents (Pastel Cyan & Lime)
    canvas.drawCircle(Offset(w * 0.26, h * 0.13), w * 0.06, earTipPaint);
    canvas.drawCircle(
      Offset(w * 0.74, h * 0.13),
      w * 0.06,
      Paint()..color = AppColor.lime,
    );

    // 3. Main body (Cute rounded blob)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: w * 0.68,
        height: h * 0.64,
      ),
      Radius.circular(w * 0.32),
    );

    // 3D tactile bottom shadow on body
    final shadowPaint = Paint()
      ..color = const Color(0xFF0F1A2B)
      ..style = PaintingStyle.fill;
    final shadowBodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + h * 0.04),
        width: w * 0.68,
        height: h * 0.64,
      ),
      Radius.circular(w * 0.32),
    );
    canvas.drawRRect(shadowBodyRect, shadowPaint);

    // Body fill with subtle gradient
    final bodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF2E486D),
          Color(0xFF1E324E),
        ],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, bodyPaint);

    // Crisp body border
    final borderPaint = Paint()
      ..color = AppColor.cardBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(bodyRect, borderPaint);

    // 4. Cheerful Blush Spots (Pastel Amber/Coral)
    final blushPaint = Paint()
      ..color = AppColor.amber.withValues(alpha: 0.45)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.28, h * 0.58),
        width: w * 0.10,
        height: h * 0.05,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.72, h * 0.58),
        width: w * 0.10,
        height: h * 0.05,
      ),
      blushPaint,
    );

    // 5. Expressive Visor Eyes
    final eyePaint = Paint()
      ..color = AppColor.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    if (expression == MascotExpression.cheering ||
        expression == MascotExpression.happy) {
      // Happy curved arcs: ^ ^
      final leftEyePath = Path()
        ..moveTo(w * 0.33, h * 0.49)
        ..quadraticBezierTo(w * 0.40, h * 0.42, w * 0.45, h * 0.49);
      final rightEyePath = Path()
        ..moveTo(w * 0.55, h * 0.49)
        ..quadraticBezierTo(w * 0.60, h * 0.42, w * 0.67, h * 0.49);

      canvas.drawPath(leftEyePath, eyePaint);
      canvas.drawPath(rightEyePath, eyePaint);
    } else {
      // Wide curious glowing eyes with highlights
      canvas.drawCircle(
        Offset(w * 0.39, h * 0.46),
        w * 0.055,
        Paint()..color = AppColor.cyan,
      );
      canvas.drawCircle(
        Offset(w * 0.61, h * 0.46),
        w * 0.055,
        Paint()..color = AppColor.cyan,
      );
      // Highlights
      canvas.drawCircle(
        Offset(w * 0.37, h * 0.44),
        w * 0.02,
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        Offset(w * 0.59, h * 0.44),
        w * 0.02,
        Paint()..color = Colors.white,
      );
    }

    // 6. Cute Smile
    final mouthPaint = Paint()
      ..color = AppColor.lime
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    final mouthPath = Path()
      ..moveTo(w * 0.46, h * 0.55)
      ..quadraticBezierTo(w * 0.50, h * 0.59, w * 0.54, h * 0.55);
    canvas.drawPath(mouthPath, mouthPaint);

    // 7. Little floating paws / orb accessory
    final pawPaint = Paint()
      ..color = AppColor.surfaceLight
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.26, h * 0.68), w * 0.07, pawPaint);
    canvas.drawCircle(Offset(w * 0.74, h * 0.68), w * 0.07, pawPaint);

    // Tiny Sparkle Star near the head
    final sparklePaint = Paint()
      ..color = AppColor.amber
      ..style = PaintingStyle.fill;
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.28), w * 0.07, sparklePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final outerX = center.dx + math.cos(angle) * radius;
      final outerY = center.dy + math.sin(angle) * radius;
      final innerAngle = angle + math.pi / 4;
      final innerX = center.dx + math.cos(innerAngle) * (radius * 0.3);
      final innerY = center.dy + math.sin(innerAngle) * (radius * 0.3);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SeeleMascotPainter oldDelegate) {
    return oldDelegate.expression != expression;
  }
}
