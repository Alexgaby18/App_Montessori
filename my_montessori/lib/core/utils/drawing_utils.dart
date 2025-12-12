import 'dart:math';
import 'package:flutter/material.dart';

class DrawingUtils {
  static List<Offset> normalizePoints(List<Offset> points, {int scaleTo = 256}) {
    if (points.isEmpty) return points;
    
    double minX = points.map((p) => p.dx).reduce(min);
    double minY = points.map((p) => p.dy).reduce(min);
    double maxX = points.map((p) => p.dx).reduce(max);
    double maxY = points.map((p) => p.dy).reduce(max);
    
    final w = maxX - minX;
    final h = maxY - minY;
    final size = max(w, h);
    
    if (size == 0) return points;
    
    final scale = scaleTo / size;
    
    return points.map((p) => Offset(
      (p.dx - minX) * scale,
      (p.dy - minY) * scale,
    )).toList();
  }

  static List<Offset> resamplePoints(List<Offset> points, int targetCount) {
    if (points.isEmpty || targetCount <= 1) return points;
    
    final distances = <double>[0.0];
    for (int i = 1; i < points.length; i++) {
      distances.add(distances.last + (points[i] - points[i - 1]).distance);
    }
    
    final total = distances.last;
    if (total == 0) return List.generate(targetCount, (_) => points[0]);
    
    return List.generate(targetCount, (k) {
      final target = total * k / (targetCount - 1);
      final index = distances.indexWhere((d) => d >= target);
      
      if (index <= 0) return points[0];
      
      final ratio = (target - distances[index - 1]) / (distances[index] - distances[index - 1]);
      return Offset(
        points[index - 1].dx + (points[index].dx - points[index - 1].dx) * ratio,
        points[index - 1].dy + (points[index].dy - points[index - 1].dy) * ratio,
      );
    });
  }

  static double dtwDistance(List<Offset> a, List<Offset> b) {
    final n = a.length;
    final m = b.length;
    final dtw = List.generate(n + 1, (_) => List<double>.filled(m + 1, double.infinity));
    dtw[0][0] = 0.0;
    
    for (int i = 1; i <= n; i++) {
      for (int j = 1; j <= m; j++) {
        final cost = (a[i - 1] - b[j - 1]).distance;
        dtw[i][j] = cost + min(min(dtw[i - 1][j], dtw[i][j - 1]), dtw[i - 1][j - 1]);
      }
    }
    
    final raw = dtw[n][m] / (n + m);
    return (1.0 - (raw / 0.8)).clamp(0.0, 1.0);
  }
}