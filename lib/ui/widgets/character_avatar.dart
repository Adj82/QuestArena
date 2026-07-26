import 'package:flutter/material.dart';

// ─── Character Data Model ───────────────────────────────────────────────────

enum CharacterGender { female, male }

class CharacterData {
  final String id;
  final String name;
  final CharacterGender gender;
  final String description;
  // Skin / hair / clothing color seeds
  final Color skinColor;
  final Color hairColor;
  final Color accentColor;     // clothing / accessory highlight
  final Color bgColor;         // avatar background circle color
  final AvatarStyle style;

  const CharacterData({
    required this.id,
    required this.name,
    required this.gender,
    required this.description,
    required this.skinColor,
    required this.hairColor,
    required this.accentColor,
    required this.bgColor,
    required this.style,
  });
}

enum AvatarStyle {
  f1NerdyGlasses,     // female 1 — olive skin, black hair red highlights, black tee, glasses
  f2SouthAsianKurta,  // female 2 — south asian, wavy hair, kurta
  f3CurlyBunWhite,    // female 3 — light skin, curly bun, white shirt
  m1PunjabiTurban,    // male 1 — fair skin, turban, white tee, blue jacket
  m2OliveGlasses,     // male 2 — olive skin, black hair, glasses, black tee
  m3DarkKurta,        // male 3 — darker skin, curly hair, off-white kurta
}

// ─── Character Catalog ──────────────────────────────────────────────────────

const List<CharacterData> kCharacters = [
  CharacterData(
    id: 'f1',
    name: 'Nova',
    gender: CharacterGender.female,
    description: 'Tech genius with style',
    skinColor: Color(0xFFB5895A),  // olive
    hairColor: Color(0xFF1A1A1A),  // black
    accentColor: Color(0xFFFF2D55), // red highlights
    bgColor: Color(0xFF1A1030),
    style: AvatarStyle.f1NerdyGlasses,
  ),
  CharacterData(
    id: 'f2',
    name: 'Arya',
    gender: CharacterGender.female,
    description: 'Warrior from the east',
    skinColor: Color(0xFF8D5524),  // south asian
    hairColor: Color(0xFF2C1810),  // deep brown-black
    accentColor: Color(0xFF00BCD4), // teal kurta
    bgColor: Color(0xFF0A1525),
    style: AvatarStyle.f2SouthAsianKurta,
  ),
  CharacterData(
    id: 'f3',
    name: 'Lyra',
    gender: CharacterGender.female,
    description: 'Precision over power',
    skinColor: Color(0xFFF5D5C0),  // light
    hairColor: Color(0xFFD4A060),  // warm blonde-brown curly
    accentColor: Color(0xFFE8E8E8), // white shirt
    bgColor: Color(0xFF0F1A20),
    style: AvatarStyle.f3CurlyBunWhite,
  ),
  CharacterData(
    id: 'm1',
    name: 'Veer',
    gender: CharacterGender.male,
    description: 'Unbreakable spirit',
    skinColor: Color(0xFFD4A87A),  // fair
    hairColor: Color(0xFF1A0800),  // dark under turban
    accentColor: Color(0xFF2979FF), // blue jacket
    bgColor: Color(0xFF0A1530),
    style: AvatarStyle.m1PunjabiTurban,
  ),
  CharacterData(
    id: 'm2',
    name: 'Zane',
    gender: CharacterGender.male,
    description: 'Cold logic, hot streak',
    skinColor: Color(0xFFB5895A),  // olive
    hairColor: Color(0xFF1A1A1A),  // black
    accentColor: Color(0xFF212121), // black tee
    bgColor: Color(0xFF151015),
    style: AvatarStyle.m2OliveGlasses,
  ),
  CharacterData(
    id: 'm3',
    name: 'Ryo',
    gender: CharacterGender.male,
    description: 'Ancient wisdom, digital mind',
    skinColor: Color(0xFF6B3A2A),  // darker
    hairColor: Color(0xFF1A0800),  // dark brown curly
    accentColor: Color(0xFFF5F0E0), // off-white kurta
    bgColor: Color(0xFF100A00),
    style: AvatarStyle.m3DarkKurta,
  ),
];

// ─── Avatar Painter ─────────────────────────────────────────────────────────

class AvatarPainter extends CustomPainter {
  final CharacterData character;
  final bool isGrayscale;
  AvatarPainter(this.character, {this.isGrayscale = false});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Use a single layer for grayscale if needed, or apply to individual paints
    // Applying to individual paints is generally more performant than saveLayer
    final filter = isGrayscale ? const ColorFilter.mode(Colors.grey, BlendMode.saturation) : null;

    // Clip to circle
    canvas.clipRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(r)));

    // Background gradient
    final bgPaint = Paint()
      ..shader = RadialGradient(colors: [
        character.bgColor.withValues(alpha: 1.0),
        const Color(0xFF0A0A14),
      ]).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
      ..colorFilter = filter;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // TRON grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..colorFilter = filter;
    for (double y = 0; y <= size.height; y += size.height / 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    switch (character.style) {
      case AvatarStyle.f1NerdyGlasses:
        _drawF1(canvas, size, cx, cy, filter);
      case AvatarStyle.f2SouthAsianKurta:
        _drawF2(canvas, size, cx, cy, filter);
      case AvatarStyle.f3CurlyBunWhite:
        _drawF3(canvas, size, cx, cy, filter);
      case AvatarStyle.m1PunjabiTurban:
        _drawM1(canvas, size, cx, cy, filter);
      case AvatarStyle.m2OliveGlasses:
        _drawM2(canvas, size, cx, cy, filter);
      case AvatarStyle.m3DarkKurta:
        _drawM3(canvas, size, cx, cy, filter);
    }
  }

  Paint _fill(Color c, [ColorFilter? f]) => Paint()..color = c..style = PaintingStyle.fill..colorFilter = f;
  Paint _stroke(Color c, double w, [ColorFilter? f]) => Paint()..color = c..style = PaintingStyle.stroke..strokeWidth = w..strokeCap = StrokeCap.round..colorFilter = f;

  void _drawEars(Canvas canvas, Size s, double cx, double cy, Color skin, ColorFilter? f) {
    final earWidth = s.width * 0.07;
    final earHeight = s.height * 0.12;
    final earY = cy - s.height * 0.05;
    
    // Left Ear
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - s.width * 0.23, earY), width: earWidth, height: earHeight), _fill(skin, f));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - s.width * 0.23, earY), width: earWidth * 0.6, height: earHeight * 0.6), _fill(skin.withValues(alpha: 0.7), f));

    // Right Ear
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.23, earY), width: earWidth, height: earHeight), _fill(skin, f));
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + s.width * 0.23, earY), width: earWidth * 0.6, height: earHeight * 0.6), _fill(skin.withValues(alpha: 0.7), f));
  }

  void _drawHead(Canvas canvas, Size s, double cx, double cy, Color skin, ColorFilter? f) {
    final headPath = Path()
      ..moveTo(cx, cy - s.height * 0.32)
      ..cubicTo(cx + s.width * 0.24, cy - s.height * 0.32, cx + s.width * 0.26, cy + s.height * 0.05, cx, cy + s.height * 0.18)
      ..cubicTo(cx - s.width * 0.26, cy + s.height * 0.05, cx - s.width * 0.24, cy - s.height * 0.32, cx, cy - s.height * 0.32)
      ..close();
    canvas.drawPath(headPath, _fill(skin, f));
  }

  void _drawNostrils(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final nPaint = _stroke(Colors.black.withValues(alpha: 0.1), 1, f);
    canvas.drawPath(Path()..moveTo(cx - 3, cy + 3)..quadraticBezierTo(cx - 5, cy + 5, cx - 2, cy + 6), nPaint);
    canvas.drawPath(Path()..moveTo(cx + 3, cy + 3)..quadraticBezierTo(cx + 5, cy + 5, cx + 2, cy + 6), nPaint);
  }

  void _drawEyes(Canvas canvas, Size s, double cx, double cy, Color irisColor, bool isFemale, ColorFilter? f) {
    void drawEye(double ex, double ey) {
      final eyeW = s.width * 0.10;
      final eyeH = s.height * 0.06;
      final rect = Rect.fromCenter(center: Offset(ex, ey), width: eyeW, height: eyeH);
      
      // Sclera
      canvas.drawOval(rect, _fill(Colors.white, f));
      // Iris
      canvas.drawCircle(Offset(ex, ey), eyeH * 0.45, _fill(irisColor, f));
      // Pupil
      canvas.drawCircle(Offset(ex, ey), eyeH * 0.25, _fill(const Color(0xFF1A1A1A), f));
      // Shine
      canvas.drawCircle(Offset(ex - 2, ey - 2), eyeH * 0.1, _fill(Colors.white, f));
      // Upper eyelid
      canvas.drawArc(rect, 3.14, 3.14, false, _stroke(Colors.black.withValues(alpha: 0.2), 1, f));

      // Eyebrows
      final browY = ey - s.height * 0.06;
      if (isFemale) {
        final bPath = Path()..moveTo(ex - eyeW * 0.6, browY)..quadraticBezierTo(ex, browY - 5, ex + eyeW * 0.6, browY);
        canvas.drawPath(bPath, _stroke(const Color(0xFF2A2A2A), 1.5, f));
      } else {
        canvas.drawLine(Offset(ex - eyeW * 0.5, browY), Offset(ex + eyeW * 0.5, browY), _stroke(const Color(0xFF2A2A2A), 2, f));
      }
    }

    drawEye(cx - s.width * 0.12, cy - s.height * 0.05);
    drawEye(cx + s.width * 0.12, cy - s.height * 0.05);
  }

  void _drawMouth(Canvas canvas, Size s, double cx, double cy, bool smile, ColorFilter? f) {
    final mPath = Path();
    final mY = cy + s.height * 0.08;
    final mW = s.width * 0.15;
    
    mPath.moveTo(cx - mW / 2, mY);
    // Upper lip
    mPath.quadraticBezierTo(cx, mY - 2, cx + mW / 2, mY);
    // Lower curve
    mPath.quadraticBezierTo(cx, mY + (smile ? 8 : 4), cx - mW / 2, mY);
    mPath.close();
    
    canvas.drawPath(mPath, _fill(const Color(0xFF8D4A3A).withValues(alpha: 0.8), f));
  }

  void _drawHairVolume(Canvas canvas, Path hairPath, Color hairColor, Size s, ColorFilter? f) {
    canvas.drawPath(hairPath, _fill(hairColor, f));
    
    // Highlight streak
    final hPath = Path()
      ..moveTo(s.width * 0.4, s.height * 0.25)
      ..cubicTo(s.width * 0.5, s.height * 0.22, s.width * 0.6, s.height * 0.22, s.width * 0.7, s.height * 0.28);
    canvas.drawPath(hPath, _stroke(Colors.white.withValues(alpha: 0.15), 3, f));
  }

  void _drawBeardTexture(Canvas canvas, Rect beardArea, ColorFilter? f) {
    final bPaint = _stroke(Colors.black.withValues(alpha: 0.25), 1, f);
    for (int i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(beardArea.left + i * 5, beardArea.top + 2),
        Offset(beardArea.left + i * 5 + 4, beardArea.top + 8),
        bPaint
      );
    }
  }

  // ── F1: Nerdy glasses, olive skin, black hair w/ red highlights, black tee ──
  void _drawF1(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final hair = character.hairColor;
    final red  = character.accentColor;

    // body
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.35, s.width * 0.76, s.height * 0.5), _fill(const Color(0xFF111111), f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF4E342E), true, f);
    _drawMouth(canvas, s, cx, cy, true, f);

    // hair base
    final hairPath = Path()
      ..moveTo(cx - s.width * 0.26, cy - s.height * 0.10)
      ..cubicTo(cx - s.width * 0.28, cy - s.height * 0.45, cx + s.width * 0.28, cy - s.height * 0.45, cx + s.width * 0.26, cy - s.height * 0.10)
      ..close();
    _drawHairVolume(canvas, hairPath, hair, s, f);

    // highlight streaks
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(Offset(cx - s.width * (0.18 - i * 0.03), cy - s.height * 0.38), Offset(cx - s.width * (0.20 - i * 0.03), cy - s.height * 0.12), _stroke(red, s.width * 0.012, f));
    }

    // Glasses glow + frames
    final gY = cy - s.height * 0.05;
    final glowRect = RRect.fromRectAndRadius(Rect.fromLTWH(cx - s.width * 0.22, gY - s.height * 0.07, s.width * 0.44, s.height * 0.14), const Radius.circular(6));
    canvas.drawRRect(glowRect, _fill(red.withValues(alpha: 0.15), f));
    
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s.width * 0.195, gY - s.height * 0.055, s.width * 0.16, s.height * 0.10), const Radius.circular(4)), _stroke(const Color(0xFF222222), 1.5, f));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s.width * 0.035, gY - s.height * 0.055, s.width * 0.16, s.height * 0.10), const Radius.circular(4)), _stroke(const Color(0xFF222222), 1.5, f));
    canvas.drawLine(Offset(cx - s.width * 0.035, gY), Offset(cx + s.width * 0.035, gY), _stroke(const Color(0xFF222222), 1.5, f));
  }

  void _drawF2(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final hair = character.hairColor;
    final teal = character.accentColor;
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.32, s.width * 0.76, s.height * 0.5), _fill(teal.withValues(alpha: 0.85), f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF2E7D32), true, f);
    _drawMouth(canvas, s, cx, cy, true, f);

    final wPath = Path()
      ..moveTo(cx - s.width * 0.25, cy - s.height * 0.08)
      ..cubicTo(cx - s.width * 0.35, cy - s.height * 0.35, cx + s.width * 0.35, cy - s.height * 0.35, cx + s.width * 0.25, cy - s.height * 0.08)
      ..close();
    _drawHairVolume(canvas, wPath, hair, s, f);
  }

  void _drawF3(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final hair = character.hairColor;
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.34, s.width * 0.76, s.height * 0.5), _fill(const Color(0xFFE8E8E8), f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF1565C0), true, f);
    _drawMouth(canvas, s, cx, cy, true, f);

    final bunPath = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy - s.height * 0.36), radius: s.width * 0.15));
    _drawHairVolume(canvas, bunPath, hair, s, f);
  }

  void _drawM1(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final blue = character.accentColor;
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.32, s.width * 0.76, s.height * 0.5), _fill(blue, f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF4E342E), false, f);
    _drawMouth(canvas, s, cx, cy, false, f);

    const tColor1 = Color(0xFFFF8C00); // Main Saffron
    final turbanPath = Path()
      ..moveTo(cx - s.width * 0.28, cy - s.height * 0.12)
      // Front wrap layers
      ..quadraticBezierTo(cx - s.width * 0.32, cy - s.height * 0.35, cx - s.width * 0.1, cy - s.height * 0.52)
      // Conical top
      ..quadraticBezierTo(cx, cy - s.height * 0.58, cx + s.width * 0.1, cy - s.height * 0.52)
      // Back wrap layers
      ..quadraticBezierTo(cx + s.width * 0.32, cy - s.height * 0.35, cx + s.width * 0.28, cy - s.height * 0.12)
      ..close();
    canvas.drawPath(turbanPath, _fill(tColor1, f));
    
    // Turban wrap folds (diagonal realistic wraps)
    final foldPaint = _stroke(Colors.black.withValues(alpha: 0.12), 1.2, f);
    for (int i = 0; i < 5; i++) {
      canvas.drawPath(Path()
        ..moveTo(cx - s.width * 0.25, cy - s.height * (0.15 + i * 0.08))
        ..quadraticBezierTo(cx, cy - s.height * (0.2 + i * 0.08), cx + s.width * 0.25, cy - s.height * (0.25 + i * 0.08)), foldPaint);
    }
    // Gold pin (Khanda-inspired circular pin)
    canvas.drawCircle(Offset(cx, cy - s.height * 0.35), 5, _fill(const Color(0xFFFFD700), f));
    canvas.drawCircle(Offset(cx, cy - s.height * 0.35), 6, _stroke(const Color(0xFFB8860B), 1, f));
    
    final beardArea = Rect.fromLTWH(cx - s.width * 0.15, cy + s.height * 0.05, s.width * 0.3, s.height * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(beardArea, const Radius.circular(8)), _fill(const Color(0xFF2A1400).withValues(alpha: 0.4), f));
    _drawBeardTexture(canvas, beardArea, f);
  }

  void _drawM2(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final hair = character.hairColor;
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.34, s.width * 0.76, s.height * 0.5), _fill(const Color(0xFF111111), f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF37474F), false, f);
    _drawMouth(canvas, s, cx, cy, false, f);

    final hairPath = Path()
      ..moveTo(cx - s.width * 0.24, cy - s.height * 0.15)
      ..cubicTo(cx - s.width * 0.2, cy - s.height * 0.42, cx + s.width * 0.2, cy - s.height * 0.42, cx + s.width * 0.24, cy - s.height * 0.15)
      ..close();
    _drawHairVolume(canvas, hairPath, hair, s, f);

    final gY = cy - s.height * 0.05;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s.width * 0.22, gY - s.height * 0.07, s.width * 0.44, s.height * 0.14), const Radius.circular(4)), _fill(character.accentColor.withValues(alpha: 0.15), f));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - s.width * 0.205, gY - s.height * 0.055, s.width * 0.175, s.height * 0.105), const Radius.circular(3)), _stroke(const Color(0xFF333333), 2, f));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx + s.width * 0.030, gY - s.height * 0.055, s.width * 0.175, s.height * 0.105), const Radius.circular(3)), _stroke(const Color(0xFF333333), 2, f));
    canvas.drawLine(Offset(cx - s.width * 0.030, gY), Offset(cx + s.width * 0.030, gY), _stroke(const Color(0xFF333333), 2, f));
  }

  void _drawM3(Canvas canvas, Size s, double cx, double cy, ColorFilter? f) {
    final skin = character.skinColor;
    final hair = character.hairColor;
    final cream = character.accentColor;
    canvas.drawRect(Rect.fromLTWH(cx - s.width * 0.38, cy + s.height * 0.32, s.width * 0.76, s.height * 0.5), _fill(cream, f));
    
    _drawEars(canvas, s, cx, cy, skin, f);
    _drawHead(canvas, s, cx, cy, skin, f);
    _drawNostrils(canvas, s, cx, cy, f);
    _drawEyes(canvas, s, cx, cy, const Color(0xFF5D4037), false, f);
    _drawMouth(canvas, s, cx, cy, false, f);

    final hPath = Path()..addOval(Rect.fromCenter(center: Offset(cx, cy - s.height * 0.25), width: s.width * 0.5, height: s.height * 0.3));
    _drawHairVolume(canvas, hPath, hair, s, f);
    
    final beardArea = Rect.fromLTWH(cx - s.width * 0.18, cy + s.height * 0.02, s.width * 0.36, s.height * 0.16);
    canvas.drawPath(Path()..addRRect(RRect.fromRectAndRadius(beardArea, const Radius.circular(10))), _fill(const Color(0xFF1A0E00).withValues(alpha: 0.7), f));
    _drawBeardTexture(canvas, beardArea, f);
  }

  @override
  bool shouldRepaint(covariant AvatarPainter oldDelegate) => 
    oldDelegate.character.id != character.id || oldDelegate.isGrayscale != isGrayscale;
}

// ─── Avatar Widget ──────────────────────────────────────────────────────────

class CharacterAvatar extends StatelessWidget {
  final CharacterData character;
  final double size;
  final bool showGlow;
  final bool showBorder;
  final bool isGrayscale;

  const CharacterAvatar({
    super.key,
    required this.character,
    this.size = 56,
    this.showGlow = false,
    this.showBorder = true,
    this.isGrayscale = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AvatarPainter(character, isGrayscale: isGrayscale),
      size: Size(size, size),
    );
  }
}
