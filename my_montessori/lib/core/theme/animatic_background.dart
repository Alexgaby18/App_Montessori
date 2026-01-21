import 'package:flutter/material.dart';

// Usa la imagen 'assets/images/fondo.png' como fondo centrado y cuadrado.

class BackgroundAnimation extends StatelessWidget {
  const BackgroundAnimation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        // fondo fallback y la imagen cubriendo toda la pantalla
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 127, 179, 239),
          image: DecorationImage(
            image: AssetImage('assets/images/fondo.png'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
        ),
      ),
    );
  }
}
