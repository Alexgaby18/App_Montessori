import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/typography.dart';

class ButtonWord extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const ButtonWord({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // margen horizontal fijo (ajusta 24 según prefieras)
    const horizontalMargin = 24.0;
    // altura fija del botón
    const buttonHeight = 56.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 6),
      width: double.infinity, // ocupar el espacio disponible dentro del margen
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 4,
          minimumSize: const Size.fromHeight(buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: RichText(
          textAlign: TextAlign.center, // centra el texto dentro del botón
          text: TypographyConstants().coloredText(
            text,
            baseStyle: TextStyle(
              fontFamily: 'Andika',
              fontSize: width * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}