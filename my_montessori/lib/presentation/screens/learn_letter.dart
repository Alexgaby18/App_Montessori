import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/typography.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class LearnLetterScreen extends StatelessWidget {
  final int index; // index de la letra en la lista `letters`

  const LearnLetterScreen({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLetter = letters[index];
    final bool hasPrev = index > 0;
    final bool hasNext = index < letters.length - 1;
    final int prevIndex = index - 1;
    final int nextIndex = index + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('Learn Letter ${currentLetter.char}'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),

          // icono volumen (a la derecha)
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: 44,
              color: const Color.fromARGB(255, 55, 35, 28),
              onPressed: () {
                AudioService.instance.speak('Toca la letra o las imágenes para escuchar su nombre');
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: ButtonLetter(
                    letter: currentLetter.char,
                    onPressed: () {}, // por ejemplo reproducir sonido de la letra
                    size: 180.0,
                  ),
                ),
                const SizedBox(height: 20),

                // Flechas: izquierda oculta en la primera letra
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (hasPrev)
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LearnLetterScreen(index: prevIndex),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 40,
                        padding: const EdgeInsets.all(25),
                        color: const Color.fromARGB(255, 55, 35, 28),
                      )
                    else
                      const SizedBox(width: 72), // mantener espacio para composición

                    if (hasNext)
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LearnLetterScreen(index: nextIndex),
                            ),
                          );
                        },
                        icon: const Icon(Icons.arrow_forward),
                        iconSize: 40,
                        padding: const EdgeInsets.all(25),
                        color: const Color.fromARGB(255, 55, 35, 28),
                      )
                    else
                      const SizedBox(width: 72),
                  ],
                ),

                const SizedBox(height: 10),

                // Lista de pictogramas generada automáticamente desde currentLetter.words
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 30,
                      runSpacing: 30,
                      children: currentLetter.words.map((word) {
                        return ButtonPictogramLetters(
                          pictogramFuture: currentLetter.pictogramFile(word),
                          letters: word.toUpperCase(),
                          onPressed: () {
                            // acción al tocar un pictograma (ej. reproducir palabra)
                          },
                          size: 120,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
