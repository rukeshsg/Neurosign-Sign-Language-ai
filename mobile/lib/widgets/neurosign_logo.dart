import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../core/theme.dart';

class NeuroSignLogo extends StatelessWidget {
  const NeuroSignLogo({
    super.key,
    this.size = 112,
    this.showWordmark = true,
    this.centered = true,
  });

  final double size;
  final bool showWordmark;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _NeuroSignMarkPainter(
          primary: Theme.of(context).colorScheme.primary,
          text: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : NeuroColors.ink,
        ),
      ),
    );

    if (!showWordmark) return mark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        mark,
        const SizedBox(height: 12),
        RichText(
          textAlign: centered ? TextAlign.center : TextAlign.start,
          text: TextSpan(
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(letterSpacing: 0),
            children: [
              TextSpan(
                text: 'Neuro',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : NeuroColors.ink,
                ),
              ),
              const TextSpan(
                  text: 'Sign', style: TextStyle(color: NeuroColors.sage)),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.appTagline,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );

    return content;
  }
}

class _NeuroSignMarkPainter extends CustomPainter {
  const _NeuroSignMarkPainter({
    required this.primary,
    required this.text,
  });

  final Color primary;
  final Color text;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final softStroke = Paint()
      ..color = primary.withValues(alpha: 0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.024
      ..strokeCap = StrokeCap.round;

    final neuralPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;

    final arcRect = Rect.fromLTWH(size.width * 0.08, size.height * 0.08,
        size.width * 0.72, size.height * 0.72);
    canvas.drawArc(arcRect, -1.65, 4.65, false, softStroke);

    final hand = Path()
      ..moveTo(size.width * 0.12, size.height * 0.66)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.56,
          size.width * 0.48, size.height * 0.65)
      ..quadraticBezierTo(size.width * 0.58, size.height * 0.70,
          size.width * 0.67, size.height * 0.60)
      ..quadraticBezierTo(size.width * 0.73, size.height * 0.52,
          size.width * 0.82, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.78, size.height * 0.76,
          size.width * 0.52, size.height * 0.82)
      ..quadraticBezierTo(size.width * 0.30, size.height * 0.86,
          size.width * 0.18, size.height * 0.74)
      ..lineTo(size.width * 0.12, size.height * 0.66);
    canvas.drawPath(hand, stroke);

    final brain = Path()
      ..moveTo(size.width * 0.36, size.height * 0.42)
      ..cubicTo(size.width * 0.22, size.height * 0.40, size.width * 0.22,
          size.height * 0.24, size.width * 0.35, size.height * 0.25)
      ..cubicTo(size.width * 0.38, size.height * 0.12, size.width * 0.56,
          size.height * 0.14, size.width * 0.56, size.height * 0.27)
      ..cubicTo(size.width * 0.69, size.height * 0.28, size.width * 0.70,
          size.height * 0.45, size.width * 0.57, size.height * 0.47)
      ..cubicTo(size.width * 0.52, size.height * 0.56, size.width * 0.40,
          size.height * 0.54, size.width * 0.36, size.height * 0.42);
    canvas.drawPath(brain, stroke);

    canvas.drawLine(Offset(size.width * 0.46, size.height * 0.18),
        Offset(size.width * 0.46, size.height * 0.52), softStroke);
    canvas.drawLine(Offset(size.width * 0.34, size.height * 0.32),
        Offset(size.width * 0.55, size.height * 0.44), softStroke);
    canvas.drawCircle(Offset(size.width * 0.35, size.height * 0.31),
        size.width * 0.025, neuralPaint);
    canvas.drawCircle(Offset(size.width * 0.46, size.height * 0.43),
        size.width * 0.021, neuralPaint);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 0.44),
        size.width * 0.019, neuralPaint);

    final wave = Path()
      ..moveTo(size.width * 0.66, size.height * 0.40)
      ..lineTo(size.width * 0.72, size.height * 0.40)
      ..lineTo(size.width * 0.75, size.height * 0.34)
      ..lineTo(size.width * 0.80, size.height * 0.49)
      ..lineTo(size.width * 0.85, size.height * 0.30)
      ..lineTo(size.width * 0.91, size.height * 0.43);
    canvas.drawPath(wave, stroke);
  }

  @override
  bool shouldRepaint(covariant _NeuroSignMarkPainter oldDelegate) {
    return primary != oldDelegate.primary || text != oldDelegate.text;
  }
}
