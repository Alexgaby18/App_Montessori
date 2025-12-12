import 'package:flutter/material.dart';

class InkPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double strokeWidth;
  
  InkPainter({
    required this.strokes,
    this.color = const Color.fromARGB(255, 68, 194, 193),
    this.strokeWidth = 8,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;
      
      final path = Path()
        ..moveTo(stroke.first.dx, stroke.first.dy);
      
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant InkPainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
           oldDelegate.color != color ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}