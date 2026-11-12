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

/// Category Vector Art: Fresh Produce & Poultry (Fruit, Vegetable & Chicken Drumstick)
class FreshProduceIllustration extends StatelessWidget {
  final double size;
  const FreshProduceIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _FreshProducePainter()),
    );
  }
}

class _FreshProducePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Roasted Poultry Drumstick (back right)
    final bonePaint = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawCircle(const Offset(78, 25), 4, bonePaint);
    canvas.drawCircle(const Offset(84, 30), 4, bonePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(70, 24, 12, 7), const Radius.circular(3)),
      bonePaint,
    );

    final meatPath = Path();
    meatPath.moveTo(48, 52);
    meatPath.cubicTo(45, 34, 60, 28, 72, 33);
    meatPath.cubicTo(80, 38, 80, 56, 68, 64);
    meatPath.cubicTo(56, 70, 50, 62, 48, 52);
    meatPath.close();
    canvas.drawPath(meatPath, Paint()..color = const Color(0xFFB45309));
    canvas.drawCircle(const Offset(62, 45), 10, Paint()..color = const Color(0xFFD97706));

    // 2. Carrot (middle vegetable)
    final carrotLeafPath = Path();
    carrotLeafPath.moveTo(34, 30);
    carrotLeafPath.lineTo(26, 16);
    carrotLeafPath.lineTo(32, 22);
    carrotLeafPath.lineTo(38, 14);
    carrotLeafPath.lineTo(36, 26);
    canvas.drawPath(
      carrotLeafPath,
      Paint()
        ..color = const Color(0xFF16A34A)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final carrotPath = Path();
    carrotPath.moveTo(27, 30);
    carrotPath.quadraticBezierTo(38, 28, 43, 33);
    carrotPath.lineTo(24, 82);
    carrotPath.quadraticBezierTo(20, 82, 19, 78);
    carrotPath.close();
    canvas.drawPath(carrotPath, Paint()..color = const Color(0xFFEA580C));

    // Carrot detail lines
    final carrotLine = Paint()
      ..color = const Color(0xFFC2410C)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(25, 42), const Offset(33, 40), carrotLine);
    canvas.drawLine(const Offset(24, 54), const Offset(30, 52), carrotLine);
    canvas.drawLine(const Offset(22, 66), const Offset(27, 65), carrotLine);

    // 3. Fresh Red Apple / Fruit (front left)
    canvas.drawOval(
      const Rect.fromLTWH(36, 48, 36, 36),
      Paint()..color = const Color(0xFFDC2626),
    );
    canvas.drawOval(
      const Rect.fromLTWH(50, 48, 30, 34),
      Paint()..color = const Color(0xFFEF4444),
    );
    // Apple shine
    canvas.drawOval(
      const Rect.fromLTWH(42, 54, 8, 14),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
    // Apple stem & leaf
    final stemPath = Path();
    stemPath.moveTo(56, 49);
    stemPath.quadraticBezierTo(58, 41, 63, 38);
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    final fruitLeaf = Path();
    fruitLeaf.moveTo(60, 40);
    fruitLeaf.quadraticBezierTo(68, 38, 70, 44);
    fruitLeaf.quadraticBezierTo(64, 46, 60, 40);
    fruitLeaf.close();
    canvas.drawPath(fruitLeaf, Paint()..color = const Color(0xFF22C55E));

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

/// Illustration of a courier packing boxes for the Orders screen empty state
class OrderPackingIllustration extends StatelessWidget {
  final double size;
  const OrderPackingIllustration({super.key, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.1,
      child: CustomPaint(
        painter: _OrderPackingPainter(),
      ),
    );
  }
}

class _OrderPackingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 240.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Soft peach background blob
    final blobPaint = Paint()..color = const Color(0xFFFFF4EC);
    final blobPath = Path();
    blobPath.moveTo(40, 100);
    blobPath.quadraticBezierTo(20, 140, 60, 170);
    blobPath.quadraticBezierTo(80, 200, 160, 190);
    blobPath.quadraticBezierTo(200, 180, 210, 130);
    blobPath.quadraticBezierTo(210, 80, 160, 85);
    blobPath.quadraticBezierTo(90, 75, 40, 100);
    blobPath.close();
    canvas.drawPath(blobPath, blobPaint);

    // 2. Ground shadow
    final shadowPaint = Paint()..color = const Color(0xFFE8EEF3);
    canvas.drawOval(const Rect.fromLTWH(18, 210, 204, 12), shadowPaint);

    // 3. Courier Person standing
    final pantsPaint = Paint()..color = const Color(0xFF263238);
    final skinPaint = Paint()..color = const Color(0xFFFFDFCE);
    final orangePaint = Paint()..color = const Color(0xFFF97316);
    final darkHairPaint = Paint()..color = const Color(0xFF1E293B);

    // Left leg
    final leftLeg = Path();
    leftLeg.moveTo(144, 128);
    leftLeg.lineTo(154, 206);
    leftLeg.lineTo(142, 206);
    leftLeg.lineTo(138, 128);
    leftLeg.close();
    canvas.drawPath(leftLeg, pantsPaint);

    // Right leg
    final rightLeg = Path();
    rightLeg.moveTo(154, 128);
    rightLeg.lineTo(176, 202);
    rightLeg.lineTo(168, 204);
    rightLeg.lineTo(146, 128);
    rightLeg.close();
    canvas.drawPath(rightLeg, pantsPaint);

    // Orange pant cuffs
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(139, 204, 14, 4), const Radius.circular(1.5)),
      orangePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(167, 201, 12, 4), const Radius.circular(1.5)),
      orangePaint,
    );

    // Shoes
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(134, 208, 17, 7), const Radius.circular(3)),
      darkHairPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(169, 204, 16, 7), const Radius.circular(3)),
      darkHairPaint,
    );

    // Torso (Orange T-shirt)
    final torsoPath = Path();
    torsoPath.moveTo(133, 90);
    torsoPath.lineTo(168, 90);
    torsoPath.lineTo(160, 130);
    torsoPath.lineTo(135, 130);
    torsoPath.close();
    canvas.drawPath(torsoPath, orangePaint);

    // Right Arm reaching to box
    canvas.save();
    final rightArm = Path();
    rightArm.moveTo(164, 92);
    rightArm.lineTo(169, 108);
    rightArm.lineTo(163, 114);
    rightArm.lineTo(158, 94);
    rightArm.close();
    canvas.drawPath(rightArm, orangePaint);
    // Forearm / hand
    canvas.drawOval(const Rect.fromLTWH(162, 112, 9, 18), skinPaint);
    canvas.restore();

    // Left Arm reaching to box
    final leftArm = Path();
    leftArm.moveTo(136, 92);
    leftArm.lineTo(108, 108);
    leftArm.lineTo(112, 115);
    leftArm.lineTo(140, 96);
    leftArm.close();
    canvas.drawPath(leftArm, orangePaint);
    // Forearm & hand
    final hand = Path();
    hand.moveTo(108, 108);
    hand.lineTo(92, 116);
    hand.lineTo(95, 122);
    hand.lineTo(112, 114);
    hand.close();
    canvas.drawPath(hand, skinPaint);

    // Neck & Head
    canvas.drawRect(const Rect.fromLTWH(145, 82, 7, 10), skinPaint);
    canvas.drawOval(const Rect.fromLTWH(139, 70, 15, 17), skinPaint);
    // Hair
    final hairPath = Path();
    hairPath.moveTo(137, 73);
    hairPath.quadraticBezierTo(145, 65, 155, 71);
    hairPath.lineTo(153, 80);
    hairPath.lineTo(146, 78);
    hairPath.lineTo(142, 82);
    hairPath.close();
    canvas.drawPath(hairPath, darkHairPaint);

    // 4. Lower Open Cardboard Box on ground
    final boxPaint = Paint()..color = const Color(0xFFE28738);
    final boxDarkPaint = Paint()..color = const Color(0xFFC76F26);
    final tapePaint = Paint()..color = const Color(0xFFFFD19A);

    // Base body
    final lowerBoxRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(50, 142, 76, 72),
      const Radius.circular(5),
    );
    canvas.drawRRect(lowerBoxRRect, boxPaint);

    // Inside shadow of lower box
    final insideBox = Path();
    insideBox.moveTo(50, 142);
    insideBox.lineTo(126, 142);
    insideBox.lineTo(122, 146);
    insideBox.lineTo(54, 146);
    insideBox.close();
    canvas.drawPath(insideBox, boxDarkPaint);

    // Vertical packing tape strip
    canvas.drawRect(const Rect.fromLTWH(62, 146, 8, 30), tapePaint);

    // Left flap open
    final leftFlap = Path();
    leftFlap.moveTo(50, 142);
    leftFlap.lineTo(44, 134);
    leftFlap.lineTo(58, 134);
    leftFlap.lineTo(60, 142);
    leftFlap.close();
    canvas.drawPath(leftFlap, boxDarkPaint);

    // Right flap open
    final rightFlap = Path();
    rightFlap.moveTo(96, 142);
    rightFlap.lineTo(98, 135);
    rightFlap.lineTo(124, 135);
    rightFlap.lineTo(126, 142);
    rightFlap.close();
    canvas.drawPath(rightFlap, boxDarkPaint);

    // 5. Upper Tilted Cardboard Box being placed into lower box
    canvas.save();
    canvas.translate(62, 92);
    canvas.rotate(-math.pi / 7);

    final upperBoxRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 58, 54),
      const Radius.circular(4),
    );
    canvas.drawRRect(upperBoxRRect, Paint()..color = const Color(0xFFD67828));

    // Upper box tape
    canvas.drawRect(const Rect.fromLTWH(20, 24, 12, 12), tapePaint);

    // Flap on upper box
    final uFlap = Path();
    uFlap.moveTo(0, 0);
    uFlap.lineTo(-8, -12);
    uFlap.lineTo(44, -12);
    uFlap.lineTo(50, 0);
    uFlap.close();
    canvas.drawPath(uFlap, Paint()..color = const Color(0xFFBE6318));

    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// High fidelity vector illustration of Milk Powder Pouch (Dano Power style)
class MilkPowderPouchIllustration extends StatelessWidget {
  final double size;
  const MilkPowderPouchIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MilkPowderPouchPainter(),
      ),
    );
  }
}

class _MilkPowderPouchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Pouch outline
    final pouchPath = Path();
    pouchPath.moveTo(25, 20);
    pouchPath.lineTo(95, 20);
    pouchPath.quadraticBezierTo(98, 60, 94, 102);
    pouchPath.lineTo(26, 102);
    pouchPath.quadraticBezierTo(22, 60, 25, 20);
    pouchPath.close();

    // White base pouch
    canvas.drawPath(pouchPath, Paint()..color = const Color(0xFFF8FAFC));

    // Top gold seal
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 16, 72, 8), const Radius.circular(2)),
      Paint()..color = const Color(0xFFEAB308),
    );

    // Red upper brand header
    final redHeader = Path();
    redHeader.moveTo(25, 24);
    redHeader.lineTo(95, 24);
    redHeader.lineTo(94, 62);
    redHeader.quadraticBezierTo(60, 52, 26, 62);
    redHeader.close();
    canvas.drawPath(redHeader, Paint()..color = const Color(0xFFDC2626));

    // DANO brand text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DANO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 14,
          letterSpacing: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(36, 28));

    final subPainter = TextPainter(
      text: const TextSpan(
        text: 'POWER',
        style: TextStyle(
          color: Color(0xFFFEF08A),
          fontWeight: FontWeight.w800,
          fontSize: 8,
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    subPainter.paint(canvas, const Offset(43, 44));

    // Milk splash graphic
    final splashPath = Path();
    splashPath.moveTo(35, 65);
    splashPath.quadraticBezierTo(42, 54, 48, 62);
    splashPath.quadraticBezierTo(60, 50, 72, 63);
    splashPath.quadraticBezierTo(78, 56, 85, 66);
    splashPath.lineTo(84, 82);
    splashPath.lineTo(36, 82);
    splashPath.close();
    canvas.drawPath(splashPath, Paint()..color = Colors.white);

    // Green bottom grass band
    final greenBand = Path();
    greenBand.moveTo(26, 84);
    greenBand.lineTo(94, 84);
    greenBand.lineTo(94, 102);
    greenBand.lineTo(26, 102);
    greenBand.close();
    canvas.drawPath(greenBand, Paint()..color = const Color(0xFF65A30D));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// High fidelity vector illustration of Milk Powder Can (Nestle Nido style)
class MilkPowderCanIllustration extends StatelessWidget {
  final double size;
  const MilkPowderCanIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MilkPowderCanPainter(),
      ),
    );
  }
}

class _MilkPowderCanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 120.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Can body (Bright Yellow Nido cylinder)
    final canRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(26, 22, 68, 80),
      const Radius.circular(8),
    );
    canvas.drawRRect(canRRect, Paint()..color = const Color(0xFFFBBF24));

    // Metallic silver top rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(24, 18, 72, 7), const Radius.circular(3.5)),
      Paint()..color = const Color(0xFFCBD5E1),
    );

    // Red diagonal brand banner
    final redRibbon = Path();
    redRibbon.moveTo(26, 38);
    redRibbon.lineTo(94, 38);
    redRibbon.lineTo(94, 60);
    redRibbon.lineTo(26, 60);
    redRibbon.close();
    canvas.drawPath(redRibbon, Paint()..color = const Color(0xFFB91C1C));

    // NIDO text
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'NIDO',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 15,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(38, 41));

    // Glass of milk splash on lower half
    final glassPath = Path();
    glassPath.moveTo(42, 68);
    glassPath.lineTo(78, 68);
    glassPath.lineTo(74, 92);
    glassPath.lineTo(46, 92);
    glassPath.close();
    canvas.drawPath(glassPath, Paint()..color = Colors.white);

    // Silver bottom rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(25, 99, 70, 5), const Radius.circular(2.5)),
      Paint()..color = const Color(0xFF94A3B8),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Spices illustration (terracotta mortar, pestle, red chili & turmeric powder)
class SpicesIllustration extends StatelessWidget {
  final double size;
  const SpicesIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SpicesPainter()),
    );
  }
}

class _SpicesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Red Chili Pepper in background
    final chiliPath = Path();
    chiliPath.moveTo(56, 32);
    chiliPath.quadraticBezierTo(78, 20, 84, 40);
    chiliPath.quadraticBezierTo(88, 56, 72, 65);
    chiliPath.quadraticBezierTo(78, 48, 70, 42);
    chiliPath.quadraticBezierTo(62, 36, 56, 32);
    chiliPath.close();
    canvas.drawPath(chiliPath, Paint()..color = const Color(0xFFDC2626));

    // Chili stem
    final stemPath = Path();
    stemPath.moveTo(56, 32);
    stemPath.quadraticBezierTo(50, 26, 44, 28);
    canvas.drawPath(
      stemPath,
      Paint()
        ..color = const Color(0xFF15803D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // 2. Mortar Bowl
    final mortarPath = Path();
    mortarPath.moveTo(22, 54);
    mortarPath.lineTo(78, 54);
    mortarPath.quadraticBezierTo(76, 84, 50, 84);
    mortarPath.quadraticBezierTo(24, 84, 22, 54);
    mortarPath.close();
    canvas.drawPath(mortarPath, Paint()..color = const Color(0xFFD97706));

    // Mortar rim
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 50, 64, 8), const Radius.circular(4)),
      Paint()..color = const Color(0xFFB45309),
    );

    // 3. Pestle leaning left
    canvas.save();
    canvas.translate(34, 30);
    canvas.rotate(-math.pi / 7);
    final pestleRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 10, 44),
      const Radius.circular(5),
    );
    canvas.drawRRect(pestleRRect, Paint()..color = const Color(0xFF92400E));
    canvas.restore();

    // 4. Ground golden saffron / turmeric powder in mortar
    canvas.drawOval(
      const Rect.fromLTWH(26, 55, 48, 12),
      Paint()..color = const Color(0xFFFBBF24),
    );

    // Spice specks
    final speckPaint = Paint()..color = const Color(0xFFB91C1C);
    canvas.drawCircle(const Offset(42, 60), 1.5, speckPaint);
    canvas.drawCircle(const Offset(52, 58), 1.8, speckPaint);
    canvas.drawCircle(const Offset(60, 62), 1.4, speckPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ice Creams & More illustration (waffle cone, scoops & cherry)
class IceCreamIllustration extends StatelessWidget {
  final double size;
  const IceCreamIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _IceCreamPainter()),
    );
  }
}

class _IceCreamPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // 1. Waffle Cone
    final conePath = Path();
    conePath.moveTo(35, 52);
    conePath.lineTo(65, 52);
    conePath.lineTo(50, 88);
    conePath.close();
    canvas.drawPath(conePath, Paint()..color = const Color(0xFFF59E0B));

    // Cone crosshatch lines
    final linePaint = Paint()
      ..color = const Color(0xFFD97706)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(40, 56), const Offset(55, 75), linePaint);
    canvas.drawLine(const Offset(45, 54), const Offset(52, 82), linePaint);
    canvas.drawLine(const Offset(60, 56), const Offset(45, 75), linePaint);
    canvas.drawLine(const Offset(55, 54), const Offset(48, 82), linePaint);

    // 2. Bottom vanilla / mint scoop
    canvas.drawCircle(const Offset(50, 48), 18, Paint()..color = const Color(0xFFFEF08A));

    // 3. Top strawberry scoop
    canvas.drawCircle(const Offset(50, 32), 16, Paint()..color = const Color(0xFFFB7185));

    // Chocolate syrup drips
    final dripPath = Path();
    dripPath.moveTo(38, 30);
    dripPath.quadraticBezierTo(44, 40, 46, 32);
    dripPath.quadraticBezierTo(50, 42, 54, 32);
    dripPath.quadraticBezierTo(58, 38, 62, 30);
    dripPath.quadraticBezierTo(50, 20, 38, 30);
    dripPath.close();
    canvas.drawPath(dripPath, Paint()..color = const Color(0xFF78350F));

    // 4. Cherry on top
    canvas.drawCircle(const Offset(50, 16), 6.5, Paint()..color = const Color(0xFFE11D48));
    final cherryStem = Path();
    cherryStem.moveTo(50, 12);
    cherryStem.quadraticBezierTo(56, 4, 62, 8);
    canvas.drawPath(
      cherryStem,
      Paint()
        ..color = const Color(0xFF15803D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Honey Pot illustration for Spotlight section
class HoneyPotIllustration extends StatelessWidget {
  final double size;
  const HoneyPotIllustration({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HoneyPotPainter()),
    );
  }
}

class _HoneyPotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100.0;
    canvas.save();
    canvas.scale(scale, scale);

    // Honey Pot Jar Body
    final jarPath = Path();
    jarPath.moveTo(30, 40);
    jarPath.lineTo(70, 40);
    jarPath.lineTo(76, 56);
    jarPath.quadraticBezierTo(78, 80, 50, 80);
    jarPath.quadraticBezierTo(22, 80, 24, 56);
    jarPath.close();
    canvas.drawPath(jarPath, Paint()..color = const Color(0xFFFBBF24));

    // Honey shading
    final liquidPath = Path();
    liquidPath.moveTo(28, 48);
    liquidPath.lineTo(72, 48);
    liquidPath.lineTo(75, 58);
    liquidPath.quadraticBezierTo(77, 78, 50, 78);
    liquidPath.quadraticBezierTo(23, 78, 25, 58);
    liquidPath.close();
    canvas.drawPath(liquidPath, Paint()..color = const Color(0xFFF59E0B));

    // Jar Rim & Cloth Top
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(26, 34, 48, 10), const Radius.circular(5)),
      Paint()..color = const Color(0xFFD97706),
    );
    // Lid cloth tied with cord
    final lidPath = Path();
    lidPath.moveTo(22, 34);
    lidPath.quadraticBezierTo(50, 24, 78, 34);
    lidPath.lineTo(74, 38);
    lidPath.lineTo(26, 38);
    lidPath.close();
    canvas.drawPath(lidPath, Paint()..color = const Color(0xFFFEF3C7));

    // Label on Jar
    final labelRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(34, 54, 32, 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(labelRRect, Paint()..color = Colors.white);
    // Honey bee icon on label
    canvas.drawCircle(const Offset(50, 62), 4, Paint()..color = const Color(0xFFD97706));

    // Honey Dipper
    canvas.save();
    canvas.translate(72, 28);
    canvas.rotate(math.pi / 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-3, 0, 6, 42), const Radius.circular(3)),
      Paint()..color = const Color(0xFF92400E),
    );
    // Dipper head rings
    canvas.drawOval(const Rect.fromLTWH(-6, 26, 12, 6), Paint()..color = const Color(0xFFB45309));
    canvas.drawOval(const Rect.fromLTWH(-7, 31, 14, 6), Paint()..color = const Color(0xFFB45309));
    canvas.drawOval(const Rect.fromLTWH(-6, 36, 12, 6), Paint()..color = const Color(0xFFB45309));
    // Drip
    canvas.drawCircle(const Offset(0, 46), 2.5, Paint()..color = const Color(0xFFF59E0B));
    canvas.restore();

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EmptySearchIllustration extends StatelessWidget {
  final double size;

  const EmptySearchIllustration({super.key, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmptySearchPainter(),
      ),
    );
  }
}

class _EmptySearchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.45, size.height * 0.45);
    final radius = size.width * 0.32;

    // Ambient glow circle
    final glowPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 1.25, glowPaint);

    final softCircle = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, softCircle);

    // Magnifying glass lens
    final lensBg = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.75, lensBg);

    // Magnifying glass rim
    final rimPaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius * 0.75, rimPaint);

    // Glass reflection
    final reflectPaint = Paint()
      ..color = const Color(0xFFDCFCE7).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;
    final reflectPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: radius * 0.65),
        -1.2,
        1.2,
      );
    canvas.drawPath(reflectPath, reflectPaint);

    // Empty basket outline inside lens
    final basketPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final basketPath = Path()
      ..moveTo(center.dx - radius * 0.4, center.dy - radius * 0.1)
      ..lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3)
      ..lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3)
      ..lineTo(center.dx + radius * 0.4, center.dy - radius * 0.1)
      ..close();
    canvas.drawPath(basketPath, basketPaint);

    // Basket handle
    final handlePath = Path()
      ..moveTo(center.dx - radius * 0.25, center.dy - radius * 0.1)
      ..quadraticBezierTo(center.dx, center.dy - radius * 0.45, center.dx + radius * 0.25, center.dy - radius * 0.1);
    canvas.drawPath(handlePath, basketPaint);

    // Magnifying glass handle
    final handlePaint = Paint()
      ..color = const Color(0xFF15803D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round;

    final startHandle = Offset(center.dx + radius * 0.55, center.dy + radius * 0.55);
    final endHandle = Offset(size.width * 0.88, size.height * 0.88);
    canvas.drawLine(startHandle, endHandle, handlePaint);

    // Floating sparkle
    final sparklePaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.78, size.height * 0.25), 4, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.18, size.height * 0.65), 3, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
