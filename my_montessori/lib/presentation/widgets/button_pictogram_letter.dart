import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/constans/typography.dart';

class ButtonPictogramLetters extends StatelessWidget {
  final Future<File?> pictogramFuture; 
  final double size;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double borderRadius;
  final String letters;
  final bool isListening;

  const ButtonPictogramLetters({
    Key? key,
    required this.pictogramFuture,
    this.size = 64.0,
    required this.onPressed,
    this.isListening = false,
    this.backgroundColor = Colors.white,
    this.borderColor = const Color(0xFFB7C2D7),
    this.borderWidth = 1.5,
    this.shadowColor = const Color(0xFFB7C2D7),
    this.borderRadius = 8.0,
    required this.letters,
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
          onTap: () async {
            // No hablar si se está escuchando (evita hacer trampa en reconocimiento)
            if (!isListening) {
              await AudioService.instance.speak(letters);
            }
            onPressed();
          },
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * 0.08),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FutureBuilder<File?>(
                    future: pictogramFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasData && snapshot.data != null) {
                        return Image.file(
                          snapshot.data!,
                          width: size * 0.55,
                          height: size * 0.55,
                          fit: BoxFit.contain,
                        );
                      } else {
                        return const Icon(Icons.error, color: Colors.red);
                      }
                    },
                  ),
                  const SizedBox(height: 2.0),
                  RichText(
                    text: TypographyConstants().coloredText(
                      letters,
                      baseStyle: TextStyle(
                        fontFamily: 'Andika',
                        fontSize: size * 0.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
