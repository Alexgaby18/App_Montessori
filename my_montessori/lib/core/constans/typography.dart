import 'package:flutter/material.dart';

class TypographyConstants {
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Andika',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Andika',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: 'Andika',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Andika',
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  TextSpan coloredText(String text, {TextStyle? baseStyle}) {
    const vowels = 'aeiouAEIOUáéíóúÁÉÍÓÚ';
    final TextStyle defaultStyle = baseStyle ?? 
    const TextStyle(fontFamily: 'Andika', fontSize: 18, fontWeight: FontWeight.bold);
    List<TextSpan> spans = [];
    for (var char in text.split('')) {
      if (vowels.contains(char)) {
        spans.add(TextSpan(
          text: char,
          style: defaultStyle.copyWith(color: Color.fromARGB(255, 66, 170, 233)),
        ));
      } else {
        spans.add(TextSpan(
          text: char,
          style: defaultStyle.copyWith(color: Color.fromARGB(255, 237, 53, 79)),
        ));
      }
    }
    return TextSpan(children: spans);
  }
}