import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/typography.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class ButtonLetter extends StatelessWidget {
  final String letter;
  final VoidCallback onPressed;
  final double size;

  const ButtonLetter({
    Key? key,
    required this.letter,
    required this.onPressed,
    this.size = 64.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: () async {
          // reproduce audio pregrabado para la letra (o fallback fonético)
          await AudioService.instance.playLetterSound(letter);
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFB7C2D7)),
          shadowColor: const Color(0xFFB7C2D7),
          elevation: 4,
          padding: EdgeInsets.zero, // evita que el padding rompa el cuadrado
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // esquinas redondeadas opcionales
          ),
        ),
        child: Center(
          child: RichText(
            text: TypographyConstants().coloredText(
              letter,
              baseStyle: TextStyle(
                fontFamily: 'Andika',
                fontSize: size * 0.6,
                fontWeight: FontWeight.bold,
              )
            ),
          ),
        ),
      ),
    );
  }
}
