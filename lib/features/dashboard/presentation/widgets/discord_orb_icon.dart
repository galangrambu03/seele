import 'dart:math' as math;
import 'package:material_ui/material_ui.dart';
import '../../../../core/color/color.dart';

/// A custom-rendered Discord Orb icon featuring glowing multi-faceted crystal geometry.
class DiscordOrbIcon extends StatelessWidget {
  final double size;
  final bool glowing;

  const DiscordOrbIcon({
    super.key,
    this.size = 24,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DiscordOrbPainter(glowing: glowing),
      ),
    );
  }
}

class _DiscordOrbPainter extends CustomPainter {
  final bool glowing;

  _DiscordOrbPainter({required this.glowing});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);
    final radius = w * 0.42;

    // Ambient glow if enabled
    if (glowing) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColor.cyan.withValues(alpha: 0.35),
            AppColor.lavender.withValues(alpha: 0.15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: w * 0.5));
      canvas.drawCircle(center, w * 0.5, glowPaint);
    }

    // 3D Shadow underneath the orb
    final shadowPaint = Paint()
      ..color = AppColor.lavenderDark.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(center.dx, center.dy + h * 0.05), radius, shadowPaint);

    // Outer Orb Sphere with Gradient
    final sphereRect = Rect.fromCircle(center: center, radius: radius);
    final spherePaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.35),
        radius: 0.85,
        colors: [
          Color(0xFFEFE8F6), // Top highlight
          AppColor.lavender,
          Color(0xFF907AA8), // Deep purple-navy base
        ],
      ).createShader(sphereRect);
    canvas.drawCircle(center, radius, spherePaint);

    // Inner Diamond Core / Facet
    final innerPath = Path()
      ..moveTo(center.dx, center.dy - radius * 0.58)
      ..lineTo(center.dx + radius * 0.48, center.dy)
      ..lineTo(center.dx, center.dy + radius * 0.58)
      ..lineTo(center.dx - radius * 0.48, center.dy)
      ..close();

    final corePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColor.cyan,
          AppColor.lavender,
        ],
      ).createShader(sphereRect);
    canvas.drawPath(innerPath, corePaint);

    // Specular Highlight Spot
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(center.dx - radius * 0.32, center.dy - radius * 0.32),
      radius * 0.22,
      highlightPaint,
    );

    // Tiny Sparkle on the side
    final sparklePaint = Paint()
      ..color = AppColor.amber
      ..style = PaintingStyle.fill;
    _drawMiniSparkle(canvas, Offset(w * 0.82, h * 0.22), w * 0.12, sparklePaint);
  }

  void _drawMiniSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final outerX = center.dx + math.cos(angle) * radius;
      final outerY = center.dy + math.sin(angle) * radius;
      final innerAngle = angle + math.pi / 4;
      final innerX = center.dx + math.cos(innerAngle) * (radius * 0.28);
      final innerY = center.dy + math.sin(innerAngle) * (radius * 0.28);

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
  bool shouldRepaint(covariant _DiscordOrbPainter oldDelegate) {
    return oldDelegate.glowing != glowing;
  }
}
