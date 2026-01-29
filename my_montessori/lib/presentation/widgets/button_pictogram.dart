import 'dart:math' as math;
import 'package:flutter/material.dart';

class ButtonPictogram extends StatelessWidget {
  final String assetPath;
  final double size;
  final double minSize;
  final double? maxSize;
  final double maxScreenFraction;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double borderRadius;
  final double elevation;

  const ButtonPictogram({
    Key? key,
    required this.assetPath,
    this.size = 32.0,
    this.minSize = 20.0,
    this.maxSize,
    this.maxScreenFraction = 0.25,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFB7C2D7),
    this.borderWidth = 1.5,
    this.shadowColor = const Color(0xFFB7C2D7),
    this.borderRadius = 12.0,
    this.elevation = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = MediaQuery.of(context).size.width;
      final maxByScreen = screenWidth * maxScreenFraction;
      final allowedMax = math.min(maxSize ?? double.infinity, maxByScreen);
      final effectiveSize = math.max(minSize, math.min(size, allowedMax));
      debugPrint('ButtonPictogram effectiveSize: $effectiveSize');

      final padding = effectiveSize * 0.08;

      // Hacer que el área completa disponible sea pulsable (útil en tablets)
      return SizedBox.expand(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(borderRadius),
            onTap: onPressed,
            child: Center(
              child: SizedBox(
                width: effectiveSize,
                height: effectiveSize,
                child: Material(
                  color: backgroundColor,
                  elevation: elevation,
                  shadowColor: shadowColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    side: BorderSide(color: borderColor, width: borderWidth),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(assetPath),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}