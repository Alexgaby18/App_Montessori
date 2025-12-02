import 'package:flutter/material.dart';

class ButtonPictogram extends StatelessWidget {
  final String assetPath;
  final double size;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double borderRadius;

  const ButtonPictogram({
    Key? key,
    required this.assetPath,
    this.size = 64.0,
    required this.onPressed,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFB7C2D7),
    this.borderWidth = 1.5,
    this.shadowColor = const Color(0xFFB7C2D7),
    this.borderRadius = 12.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        elevation: 6.0,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onTap: onPressed,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Image.asset(
                assetPath,
                width: size * 0.99,
                height: size * 0.99,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}