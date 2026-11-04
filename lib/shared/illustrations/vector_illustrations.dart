// lib/shared/illustrations/vector_illustrations.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Reusable grocery basket illustration matching the inspiration splash screen
class GroceryBasketIllustration extends StatelessWidget {
  final double size;
  const GroceryBasketIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GroceryBasketPainter(),
      ),
    );
  }
}

class _GroceryBasketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Paints
    final baguettePaint = Paint()..color = const Color(0xFFE8B673);
    final baguetteSlicePaint = Paint()..color = const Color(0xFFD39B54);
    final turnipGreenPaint = Paint()..color = const Color(0xFF8CD84E);
    final turnipRootPaint = Paint()..color = const Color(0xFFFFB703);
    final bottlePaint = Paint()..color = const Color(0xFF8B2651);
    final bottleCapPaint = Paint()..color = const Color(0xFFDF4A82);
    final milkPaint = Paint()..color = const Color(0xFFD6E2EA);
    final milkCapPaint = Paint()..color = const Color(0xFF5B92B5);

    final basketRimPaint = Paint()..color = const Color(0xFF64B5F6);
    final basketBodyPaint = Paint()..color = const Color(0xFF89D645);
    final basketSlotPaint = Paint()..color = const Color(0xFF6AB92E);
    final handlePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 1. Baguette (tilted on the left)
    canvas.save();
    canvas.translate(55, 65);
    canvas.rotate(-math.pi / 8);
    final baguetteRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 36, 95),
      const Radius.circular(18),
    );
    canvas.drawRRect(baguetteRRect, baguettePaint);
    // Baguette cuts
    final cutPaint = Paint()
      ..color = baguetteSlicePaint.color
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(8, 25), const Offset(28, 32), cutPaint);
    canvas.drawLine(const Offset(8, 45), const Offset(28, 52), cutPaint);
    canvas.drawLine(const Offset(8, 65), const Offset(28, 72), cutPaint);
    canvas.restore();

    // 2. Carrot / Turnip (center left)
    // Leaves
    canvas.drawOval(const Rect.fromLTWH(75, 65, 18, 38), turnipGreenPaint);
    canvas.drawOval(const Rect.fromLTWH(86, 60, 18, 42), turnipGreenPaint);
    canvas.drawOval(const Rect.fromLTWH(98, 68, 16, 36), turnipGreenPaint);
    // Root
    final turnipPath = Path();
    turnipPath.addOval(const Rect.fromLTWH(78, 85, 38, 38));
    canvas.drawPath(turnipPath, turnipRootPaint);

    // 3. Bottle (maroon, standing tall)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(92, 45, 16, 25), const Radius.circular(4)),
      bottleCapPaint,
    );
    final bottlePath = Path();
    bottlePath.moveTo(94, 68);
    bottlePath.lineTo(84, 95);
    bottlePath.lineTo(84, 125);
    bottlePath.lineTo(116, 125);
    bottlePath.lineTo(116, 95);
    bottlePath.lineTo(106, 68);
    bottlePath.close();
    canvas.drawPath(bottlePath, bottlePaint);

    // 4. Milk Jar / Carton (right side)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(115, 80, 22, 10), const Radius.circular(3)),
      milkCapPaint,
    );
    final milkPath = Path();
    milkPath.moveTo(115, 90);
    milkPath.lineTo(105, 105);
    milkPath.lineTo(105, 125);
    milkPath.lineTo(142, 125);
    milkPath.lineTo(142, 105);
    milkPath.lineTo(137, 90);
    milkPath.close();
    canvas.drawPath(milkPath, milkPaint);

    // 5. Handles (behind rim or on the sides angled down)
    // Left handle angled down
    canvas.drawLine(const Offset(70, 108), const Offset(42, 148), handlePaint);
    // Right handle angled down
    canvas.drawLine(const Offset(130, 108), const Offset(158, 148), handlePaint);

    // 6. Basket Body
    final basketPath = Path();
    basketPath.moveTo(55, 114);
    basketPath.lineTo(62, 155);
    basketPath.quadraticBezierTo(63, 162, 72, 162);
    basketPath.lineTo(128, 162);
    basketPath.quadraticBezierTo(137, 162, 138, 155);
    basketPath.lineTo(145, 114);
    basketPath.close();
    canvas.drawPath(basketPath, basketBodyPaint);

    // Basket Slots (vertical pill dashes)
    void drawSlot(double cx, double cy, double h) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy), width: 7, height: h),
          const Radius.circular(4),
        ),
        basketSlotPaint,
      );
    }
    drawSlot(75, 132, 12);
    drawSlot(90, 132, 12);
    drawSlot(105, 132, 12);
    drawSlot(120, 132, 12);
    drawSlot(82, 148, 10);
    drawSlot(97, 148, 10);
    drawSlot(112, 148, 10);

    // 7. Basket Rim (Soft Blue bar at top of basket)
    final rimRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(46, 106, 108, 12),
      const Radius.circular(5),
    );
    canvas.drawRRect(rimRRect, basketRimPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Smart Recommendations vector illustration for splash onboarding
class RecommendationsIllustration extends StatelessWidget {
  final double size;
  const RecommendationsIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _RecommendationsPainter()),
    );
  }
}

class _RecommendationsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    final bgCirclePaint = Paint()..color = const Color(0xFFF2FAEB);
    canvas.drawCircle(const Offset(100, 100), 85, bgCirclePaint);

    // Phone / AI frame
    final devicePaint = Paint()..color = const Color(0xFF1E2530);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(70, 35, 60, 110), const Radius.circular(14)),
      devicePaint,
    );
    final screenPaint = Paint()..color = const Color(0xFFFFFFFF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(74, 45, 52, 90), const Radius.circular(8)),
      screenPaint,
    );

    // Screen mini cards
    final card1Paint = Paint()..color = const Color(0xFFE9F7DA);
    final card2Paint = Paint()..color = const Color(0xFFF3F4F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(78, 52, 44, 20), const Radius.circular(4)),
      card1Paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(78, 77, 44, 20), const Radius.circular(4)),
      card2Paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(78, 102, 44, 20), const Radius.circular(4)),
      card1Paint,
    );

    // AI Sparkle Stars
    final starPaint = Paint()..color = const Color(0xFFFFB703);
    void drawStar(double cx, double cy, double s) {
      final p = Path();
      p.moveTo(cx, cy - s);
      p.quadraticBezierTo(cx, cy, cx + s, cy);
      p.quadraticBezierTo(cx, cy, cx, cy + s);
      p.quadraticBezierTo(cx, cy, cx - s, cy);
      p.quadraticBezierTo(cx, cy, cx, cy - s);
      canvas.drawPath(p, starPaint);
    }
    drawStar(145, 45, 14);
    drawStar(50, 65, 10);
    drawStar(150, 120, 9);

    // Green thumbs up / AI badge
    final badgePaint = Paint()..color = const Color(0xFF65B718);
    canvas.drawCircle(const Offset(100, 140), 22, badgePaint);
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final checkPath = Path();
    checkPath.moveTo(92, 140);
    checkPath.lineTo(98, 146);
    checkPath.lineTo(108, 134);
    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Fast Delivery vector illustration for splash onboarding
class DeliveryIllustration extends StatelessWidget {
  final double size;
  const DeliveryIllustration({super.key, this.size = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DeliveryPainter()),
    );
  }
}

class _DeliveryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 200.0;
    canvas.save();
    canvas.scale(scale, scale);

    final bgCirclePaint = Paint()..color = const Color(0xFFF2FAEB);
    canvas.drawCircle(const Offset(100, 100), 85, bgCirclePaint);

    // Delivery Van / Cart
    final vanBody = Paint()..color = const Color(0xFF65B718);
    final vanCabin = Paint()..color = const Color(0xFF89D645);
    final wheelPaint = Paint()..color = const Color(0xFF1E2530);
    final wheelInner = Paint()..color = const Color(0xFFE5E7EB);
    final windowPaint = Paint()..color = const Color(0xFFE0F2FE);

    // Van Cargo Box
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(45, 80, 75, 48), const Radius.circular(8)),
      vanBody,
    );
    // Van Front Cabin
    final cabinPath = Path();
    cabinPath.moveTo(120, 88);
    cabinPath.lineTo(142, 94);
    cabinPath.quadraticBezierTo(148, 98, 150, 108);
    cabinPath.lineTo(150, 128);
    cabinPath.lineTo(120, 128);
    cabinPath.close();
    canvas.drawPath(cabinPath, vanCabin);

    // Cabin Window
    final winPath = Path();
    winPath.moveTo(122, 92);
    winPath.lineTo(139, 96);
    winPath.lineTo(139, 108);
    winPath.lineTo(122, 108);
    winPath.close();
    canvas.drawPath(winPath, windowPaint);

    // Wheels
    canvas.drawCircle(const Offset(68, 130), 14, wheelPaint);
    canvas.drawCircle(const Offset(68, 130), 6, wheelInner);

    canvas.drawCircle(const Offset(132, 130), 14, wheelPaint);
    canvas.drawCircle(const Offset(132, 130), 6, wheelInner);

    // Speed Lines
    final speedPaint = Paint()
      ..color = const Color(0xFF65B718)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(22, 92), const Offset(36, 92), speedPaint);
    canvas.drawLine(const Offset(15, 104), const Offset(38, 104), speedPaint);
    canvas.drawLine(const Offset(24, 116), const Offset(34, 116), speedPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Security / Password vector illustration
class SecurityIllustration extends StatelessWidget {
  final double size;
  const SecurityIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SecurityPainter()),
    );
  }
}

class _SecurityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 110.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Background circle
    canvas.drawCircle(const Offset(55, 55), 48, Paint()..color = const Color(0xFFF2FAEB));

    // Shield
    final shieldPaint = Paint()..color = const Color(0xFF65B718);
    final shieldPath = Path();
    shieldPath.moveTo(55, 24);
    shieldPath.lineTo(78, 33);
    shieldPath.quadraticBezierTo(78, 62, 55, 82);
    shieldPath.quadraticBezierTo(32, 62, 32, 33);
    shieldPath.close();
    canvas.drawPath(shieldPath, shieldPaint);

    // Lock inside shield
    final lockShacklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(47, 40, 16, 16),
      math.pi,
      math.pi,
      false,
      lockShacklePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(44, 48, 22, 18), const Radius.circular(4)),
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(const Offset(55, 56), 2.5, Paint()..color = const Color(0xFF65B718));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mail Verification vector illustration
class MailIllustration extends StatelessWidget {
  final double size;
  const MailIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MailPainter()),
    );
  }
}

class _MailPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 110.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Background
    canvas.drawCircle(const Offset(55, 55), 48, Paint()..color = const Color(0xFFF2FAEB));

    // Envelope
    final envRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 36, 58, 40),
      const Radius.circular(8),
    );
    canvas.drawRRect(envRRect, Paint()..color = const Color(0xFF65B718));

    // Envelope Flap
    final flapPath = Path();
    flapPath.moveTo(27, 37);
    flapPath.lineTo(55, 57);
    flapPath.lineTo(83, 37);
    flapPath.close();
    canvas.drawPath(flapPath, Paint()..color = const Color(0xFF89D645));

    // Envelope Bottom V
    final bottomPath = Path();
    bottomPath.moveTo(27, 75);
    bottomPath.lineTo(46, 54);
    canvas.drawPath(
      bottomPath,
      Paint()
        ..color = const Color(0xFF4C8E0F)
        ..strokeWidth = 2,
    );
    final bottomPath2 = Path();
    bottomPath2.moveTo(83, 75);
    bottomPath2.lineTo(64, 54);
    canvas.drawPath(
      bottomPath2,
      Paint()
        ..color = const Color(0xFF4C8E0F)
        ..strokeWidth = 2,
    );

    // Notification pin dot
    canvas.drawCircle(const Offset(82, 34), 8, Paint()..color = const Color(0xFFFFB703));
    canvas.drawCircle(const Offset(82, 34), 4, Paint()..color = Colors.white);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Success checkmark vector illustration
class SuccessIllustration extends StatelessWidget {
  final double size;
  const SuccessIllustration({super.key, this.size = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SuccessPainter()),
    );
  }
}

class _SuccessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 110.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Outer gentle glow ring
    canvas.drawCircle(const Offset(55, 55), 48, Paint()..color = const Color(0xFFE9F7DA));
    // Inner vibrant circle
    canvas.drawCircle(const Offset(55, 55), 36, Paint()..color = const Color(0xFF65B718));

    // Crisp checkmark
    final checkPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final checkPath = Path();
    checkPath.moveTo(42, 55);
    checkPath.lineTo(51, 64);
    checkPath.lineTo(68, 46);
    canvas.drawPath(checkPath, checkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Avocado (Fruits & Vegetables)
class AvocadoIllustration extends StatelessWidget {
  final double size;
  const AvocadoIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AvocadoPainter()),
    );
  }
}

class _AvocadoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Avocado skin (dark green)
    final skinPath = Path();
    skinPath.moveTo(50, 10);
    skinPath.cubicTo(32, 10, 22, 38, 20, 60);
    skinPath.cubicTo(18, 80, 32, 94, 50, 94);
    skinPath.cubicTo(68, 94, 82, 80, 80, 60);
    skinPath.cubicTo(78, 38, 68, 10, 50, 10);
    skinPath.close();
    canvas.drawPath(skinPath, Paint()..color = const Color(0xFF22541C));

    // Avocado flesh (bright yellow-green)
    final fleshPath = Path();
    fleshPath.moveTo(50, 16);
    fleshPath.cubicTo(36, 16, 27, 40, 26, 60);
    fleshPath.cubicTo(25, 76, 36, 88, 50, 88);
    fleshPath.cubicTo(64, 88, 75, 76, 74, 60);
    fleshPath.cubicTo(73, 40, 64, 16, 50, 16);
    fleshPath.close();
    canvas.drawPath(fleshPath, Paint()..color = const Color(0xFFD6E963));

    // Pit (brown seed)
    canvas.drawOval(
      const Rect.fromLTWH(36, 50, 28, 34),
      Paint()..color = const Color(0xFFB56A2D),
    );
    // Pit highlight
    canvas.drawArc(
      const Rect.fromLTWH(40, 54, 20, 26),
      -math.pi * 0.7,
      math.pi * 0.5,
      false,
      Paint()
        ..color = const Color(0xFFDCA16E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Breakfast plate (Eggs, pancakes, bacon)
class BreakfastIllustration extends StatelessWidget {
  final double size;
  const BreakfastIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BreakfastPainter()),
    );
  }
}

class _BreakfastPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Plate
    canvas.drawCircle(const Offset(50, 50), 45, Paint()..color = const Color(0xFFF1F5F9));
    canvas.drawCircle(const Offset(50, 50), 38, Paint()..color = Colors.white);

    // Pancakes (top right)
    canvas.drawOval(const Rect.fromLTWH(48, 22, 34, 22), Paint()..color = const Color(0xFFDF9E53));
    canvas.drawOval(const Rect.fromLTWH(50, 20, 32, 20), Paint()..color = const Color(0xFFF3C078));
    // Butter cube
    canvas.drawRect(const Rect.fromLTWH(62, 24, 7, 6), Paint()..color = const Color(0xFFFFE600));

    // Fried Egg (center left)
    final eggWhite = Path();
    eggWhite.moveTo(32, 40);
    eggWhite.cubicTo(45, 38, 55, 46, 52, 58);
    eggWhite.cubicTo(50, 70, 36, 74, 26, 68);
    eggWhite.cubicTo(16, 62, 20, 42, 32, 40);
    canvas.drawPath(eggWhite, Paint()..color = const Color(0xFFF8FAFC));
    // Egg Yolk
    canvas.drawCircle(const Offset(38, 54), 10, Paint()..color = const Color(0xFFFF9E00));
    canvas.drawCircle(const Offset(36, 52), 3, Paint()..color = const Color(0xFFFFD166));

    // Bacon strip (bottom right)
    final bacon = Path();
    bacon.moveTo(48, 68);
    bacon.quadraticBezierTo(58, 60, 68, 70);
    bacon.quadraticBezierTo(78, 80, 84, 72);
    canvas.drawPath(
      bacon,
      Paint()
        ..color = const Color(0xFF991B1B)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Beverages (Smoothie bottles)
class BeveragesIllustration extends StatelessWidget {
  final double size;
  const BeveragesIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _BeveragesPainter()),
    );
  }
}

class _BeveragesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Red Bottle (left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(26, 20, 16, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    final redBottle = Path();
    redBottle.moveTo(30, 28);
    redBottle.lineTo(22, 45);
    redBottle.lineTo(22, 85);
    redBottle.lineTo(46, 85);
    redBottle.lineTo(46, 45);
    redBottle.lineTo(38, 28);
    redBottle.close();
    canvas.drawPath(redBottle, Paint()..color = const Color(0xFFE11D48));
    // Bottle label
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 52, 20, 20), const Radius.circular(3)),
      Paint()..color = Colors.white,
    );

    // Green Bottle (right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(58, 20, 16, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFE2E8F0),
    );
    final greenBottle = Path();
    greenBottle.moveTo(62, 28);
    greenBottle.lineTo(54, 45);
    greenBottle.lineTo(54, 85);
    greenBottle.lineTo(78, 85);
    greenBottle.lineTo(78, 45);
    greenBottle.lineTo(70, 28);
    greenBottle.close();
    canvas.drawPath(greenBottle, Paint()..color = const Color(0xFF4D7C0F));
    // Bottle label
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(56, 52, 20, 20), const Radius.circular(3)),
      Paint()..color = Colors.white,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Meat & Fish (Steak)
class MeatFishIllustration extends StatelessWidget {
  final double size;
  const MeatFishIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _MeatFishPainter()),
    );
  }
}

class _MeatFishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Steak 1 (back steak)
    canvas.drawOval(const Rect.fromLTWH(42, 32, 42, 34), Paint()..color = const Color(0xFF633827));

    // Steak 2 (front prime steak)
    final steakPath = Path();
    steakPath.moveTo(35, 42);
    steakPath.cubicTo(55, 38, 70, 48, 68, 65);
    steakPath.cubicTo(66, 80, 45, 84, 28, 78);
    steakPath.cubicTo(15, 72, 18, 50, 35, 42);
    steakPath.close();
    canvas.drawPath(steakPath, Paint()..color = const Color(0xFF78350F));

    // Grill marks
    final grillPaint = Paint()
      ..color = const Color(0xFF451A03)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(28, 52), const Offset(54, 60), grillPaint);
    canvas.drawLine(const Offset(32, 62), const Offset(58, 70), grillPaint);

    // Rosemary sprig
    final herb = Path();
    herb.moveTo(56, 46);
    herb.lineTo(76, 30);
    canvas.drawPath(
      herb,
      Paint()
        ..color = const Color(0xFF65B718)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Snacks (Crispy potato chips bowl)
class SnacksIllustration extends StatelessWidget {
  final double size;
  const SnacksIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SnacksPainter()),
    );
  }
}

class _SnacksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Potato chips piling up
    final chipColor1 = Paint()..color = const Color(0xFFFFD166);
    final chipColor2 = Paint()..color = const Color(0xFFF4A261);

    canvas.drawOval(const Rect.fromLTWH(30, 28, 26, 18), chipColor1);
    canvas.drawOval(const Rect.fromLTWH(46, 22, 28, 20), chipColor2);
    canvas.drawOval(const Rect.fromLTWH(38, 36, 30, 22), chipColor1);
    canvas.drawOval(const Rect.fromLTWH(22, 40, 28, 20), chipColor2);
    canvas.drawOval(const Rect.fromLTWH(52, 38, 28, 20), chipColor1);

    // Glass Bowl
    final bowl = Path();
    bowl.moveTo(22, 50);
    bowl.quadraticBezierTo(26, 82, 50, 84);
    bowl.quadraticBezierTo(74, 82, 78, 50);
    bowl.close();
    canvas.drawPath(bowl, Paint()..color = const Color(0x77E2E8F0));
    canvas.drawPath(
      bowl,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Vector Art: Dairy (Milk bottles)
class DairyIllustration extends StatelessWidget {
  final double size;
  const DairyIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DairyPainter()),
    );
  }
}

class _DairyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Large Milk Bottle (right)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(55, 20, 16, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF67B5E2),
    );
    final bottle1 = Path();
    bottle1.moveTo(58, 26);
    bottle1.lineTo(52, 42);
    bottle1.lineTo(52, 82);
    bottle1.lineTo(74, 82);
    bottle1.lineTo(74, 42);
    bottle1.lineTo(68, 26);
    bottle1.close();
    canvas.drawPath(bottle1, Paint()..color = const Color(0xFFE2E8F0));
    canvas.drawPath(
      bottle1,
      Paint()
        ..color = const Color(0xFF94A3B8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Milk level in bottle 1
    final milkLevel1 = Path();
    milkLevel1.moveTo(52, 48);
    milkLevel1.lineTo(74, 48);
    milkLevel1.lineTo(74, 82);
    milkLevel1.lineTo(52, 82);
    milkLevel1.close();
    canvas.drawPath(milkLevel1, Paint()..color = Colors.white);

    // Smaller Milk Jug (left)
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(34, 34, 14, 6), const Radius.circular(2)),
      Paint()..color = const Color(0xFF1E2530),
    );
    final bottle2 = Path();
    bottle2.moveTo(36, 40);
    bottle2.lineTo(30, 52);
    bottle2.lineTo(30, 84);
    bottle2.lineTo(50, 84);
    bottle2.lineTo(50, 52);
    bottle2.lineTo(44, 40);
    bottle2.close();
    canvas.drawPath(bottle2, Paint()..color = const Color(0xFFF8FAFC));
    canvas.drawPath(
      bottle2,
      Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
