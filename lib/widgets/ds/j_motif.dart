import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// يبني مسار النجمة الثمانية (زخرفة النجمة الثمانية) داخل مربع [size].
///
/// [innerRatio] هو نسبة نصف القطر الداخلي إلى الخارجي؛ كلما صغر حَدّت الأشعة.
Path eightPointStarPath(Size size, {double innerRatio = 0.52}) {
  final center = Offset(size.width / 2, size.height / 2);
  final outer = math.min(size.width, size.height) / 2;
  final inner = outer * innerRatio;

  const points = 8;
  const step = math.pi / points; // نصف زاوية القطاع
  final path = Path();
  for (var i = 0; i < points * 2; i++) {
    final radius = i.isEven ? outer : inner;
    // نبدأ من الأعلى حتى تقف النجمة على رأس لا على ضلع.
    final angle = -math.pi / 2 + i * step;
    final point = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    if (i == 0) {
      path.moveTo(point.dx, point.dy);
    } else {
      path.lineTo(point.dx, point.dy);
    }
  }
  return path..close();
}

/// نجمة ثمانية مفردة — تُستخدم كعلامة زخرفية في زوايا البطاقات وبين العناوين.
class JStar extends StatelessWidget {
  const JStar({
    super.key,
    this.size = 16,
    this.color = AppColors.gold,
    this.filled = true,
    this.strokeWidth = 1.2,
  });

  final double size;
  final Color color;

  /// ممتلئة أم مرسومة بخط فقط.
  final bool filled;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _StarPainter(
          color: color,
          filled: filled,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  const _StarPainter({
    required this.color,
    required this.filled,
    required this.strokeWidth,
  });

  final Color color;
  final bool filled;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(eightPointStarPath(size), paint);
  }

  @override
  bool shouldRepaint(_StarPainter old) =>
      old.color != color ||
      old.filled != filled ||
      old.strokeWidth != strokeWidth;
}

/// خلفية الزخرفة الإسلامية: شبكة نجوم ثمانية بشفافية منخفضة جداً.
///
/// تُلفّ حول محتوى الشاشة لتعطي الملمس القماشي المزخرف الذي يميّز الهوية،
/// من غير أن تزاحم النص. تُرسم بـ[CustomPaint] لا بصورة، فتبقى حادة على أي كثافة.
class JMotifBackground extends StatelessWidget {
  const JMotifBackground({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.opacity = 0.035,
    this.tile = 96,
    this.starSize = 46,
    this.background,
  });

  final Widget child;
  final Color color;
  final double opacity;

  /// المسافة بين مراكز النجوم.
  final double tile;

  /// قطر النجمة الواحدة.
  final double starSize;

  /// لون السطح تحت الزخرفة (الافتراضي خلفية الصفحة القماشية).
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: background ?? AppColors.bg),
      child: CustomPaint(
        painter: _MotifPainter(
          color: color.withValues(alpha: opacity),
          tile: tile,
          starSize: starSize,
        ),
        child: child,
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  const _MotifPainter({
    required this.color,
    required this.tile,
    required this.starSize,
  });

  final Color color;
  final double tile;
  final double starSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || tile <= 0) return;

    final paint = Paint()
      ..color = color
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final star = eightPointStarPath(Size.square(starSize));
    final rows = (size.height / tile).ceil() + 1;
    final cols = (size.width / tile).ceil() + 1;

    for (var row = 0; row < rows; row++) {
      // كل صف يُزاح نصف بلاطة فتتشابك النجوم كما في الزخرفة التقليدية.
      final dy = row * tile - starSize / 2;
      final shift = row.isOdd ? tile / 2 : 0.0;
      for (var col = 0; col < cols; col++) {
        final dx = col * tile + shift - starSize / 2;
        canvas.save();
        canvas.translate(dx, dy);
        canvas.drawPath(star, paint);
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_MotifPainter old) =>
      old.color != color || old.tile != tile || old.starSize != starSize;
}

/// شريط فاصل مزخرف: خط رفيع — نجمة — خط رفيع.
class JOrnamentDivider extends StatelessWidget {
  const JOrnamentDivider({
    super.key,
    this.color = AppColors.line,
    this.starColor = AppColors.gold,
  });

  final Color color;
  final Color starColor;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(child: Container(height: 1, color: color));
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: JStar(size: 12, color: starColor),
        ),
        line,
      ],
    );
  }
}
