import 'dart:developer' as console;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/screens/practice_letter.dart';
import 'package:my_montessori/presentation/screens/speak_word.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram.dart';
import 'package:my_montessori/presentation/screens/learn_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/presentation/screens/complete_letter.dart';
import 'package:my_montessori/presentation/screens/selection_word.dart';
import 'package:my_montessori/presentation/screens/conect_letter.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          children: [
            BackgroundAnimation(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Logo en la parte superior centrado
                  Container(
                    margin: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: SvgPicture.asset(
                      'assets/svg/Logo.svg', // Ajusta la ruta según tu logo
                      width: 140, // Ajusta el tamaño según necesites
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Grid de botones organizados en 2 columnas
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2, // 2 botones por fila
                      crossAxisSpacing: 40.0, // Espacio horizontal entre botones
                      mainAxisSpacing: 40.0, // Espacio vertical entre botones
                      padding: const EdgeInsets.all(40.0), // Espacio alrededor del grid
                      childAspectRatio: 1.0, // Relación aspecto cuadrado
                      children: [
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/aprender.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 68, 194, 193),
                          onPressed: () {
                            console.log('Aprender Pressed');
                            final idx = letters.indexWhere((l) => l.char == 'A');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => LearnLetterScreen(index: idx)));
                          },
                        ),
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/completar.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 66, 170, 223),
                          onPressed: () {
                            console.log('Completar Pressed');
                            final idx = letters.indexWhere((l) => l.char == 'A');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: idx)));
                          },
                        ),
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/unir.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 245, 163, 35),
                          onPressed: () {
                            console.log('Unir Pressed');
                            final idx = letters.indexWhere((l) => l.char == 'A');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ConnectLetterScreen()));
                          },
                        ),
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/seleccionar.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 234, 155, 184),
                          onPressed: () {
                            console.log('Seleccionar Pressed');
                            final idx = words.indexWhere((w) => w.text == 'Abeja');
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SelectionWordScreen(index: idx)));
                          },
                        ),
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/escribir.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 174, 128, 227),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PracticeLetterScreen()));
                            console.log('Escribir Pressed');
                          },
                        ),
                        ButtonPictogram(
                          assetPath: 'assets/images/pictogram_menu/leer.png',
                          size: 100.0,
                          backgroundColor: const Color.fromARGB(255, 215, 68, 57),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => SpeakWordScreen(word: words.first)));
                            console.log('Leer Pressed');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}