import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key, required this.onPressed});
  final VoidCallback? onPressed;

  static bool get supported => kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      style: OutlinedButton.styleFrom(backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF17345B), minimumSize: const Size(0, 56)),
      onPressed: onPressed,
      icon: const CustomPaint(size: Size(22, 22), painter: _GoogleMark()),
      label: const Text('Continuar com o Google', textAlign: TextAlign.center),
    ),
  );
}

class _GoogleMark extends CustomPainter {
  const _GoogleMark();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);
    void draw(Color color, Path path) => canvas.drawPath(path, Paint()..color = color);
    draw(const Color(0xFFEA4335), Path()..moveTo(24,9.5)..cubicTo(27.54,9.5,30.71,10.72,33.2,13.1)..lineTo(40.05,6.25)..cubicTo(35.9,2.38,30.47,0,24,0)..cubicTo(14.62,0,6.51,5.38,2.56,13.22)..lineTo(10.54,19.41)..cubicTo(12.43,13.72,17.74,9.5,24,9.5)..close());
    draw(const Color(0xFF4285F4), Path()..moveTo(46.98,24.55)..cubicTo(46.98,22.98,46.81,21.46,46.6,20)..lineTo(24,20)..lineTo(24,29.02)..lineTo(36.94,29.02)..cubicTo(36.36,31.98,34.69,34.5,32.18,36.2)..lineTo(39.91,42.2)..cubicTo(44.42,38.03,46.98,31.89,46.98,24.55)..close());
    draw(const Color(0xFFFBBC05), Path()..moveTo(10.54,28.59)..cubicTo(9.53,25.61,9.53,22.39,10.54,19.41)..lineTo(2.56,13.22)..cubicTo(-0.85,20,-0.85,28,2.56,34.78)..close());
    draw(const Color(0xFF34A853), Path()..moveTo(24,48)..cubicTo(30.48,48,35.93,45.87,39.91,42.2)..lineTo(32.18,36.2)..cubicTo(30.03,37.65,27.25,38.5,24,38.5)..cubicTo(17.74,38.5,12.43,34.28,10.54,28.59)..lineTo(2.56,34.78)..cubicTo(6.51,42.62,14.62,48,24,48)..close());
    canvas.restore();
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
