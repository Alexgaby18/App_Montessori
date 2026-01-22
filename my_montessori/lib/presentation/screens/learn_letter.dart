import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/typography.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class LearnLetterScreen extends StatefulWidget {
  final int index; // index de la letra en la lista `letters`
  final bool initialIsUppercase;

  const LearnLetterScreen({
    Key? key,
    required this.index,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<LearnLetterScreen> createState() => _LearnLetterScreenState();
}

class _LearnLetterScreenState extends State<LearnLetterScreen> {
  bool isUppercase = true;

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = letters[widget.index];
    final bool hasPrev = widget.index > 0;
    final bool hasNext = widget.index < letters.length - 1;
    final int prevIndex = widget.index - 1;
    final int nextIndex = widget.index + 1;
    String displayChar() => isUppercase ? currentLetter.char.toUpperCase() : currentLetter.char.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Aprende la letra ${currentLetter.char}'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),

          // icono volumen (a la derecha)
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón para alternar mayúsculas/minúsculas
                IconButton(
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  tooltip: isUppercase ? 'Cambiar a minúsculas' : 'Cambiar a mayúsculas',
                  onPressed: () => setState(() => isUppercase = !isUppercase),
                  icon: Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 55, 35, 28),
                    ),
                  ),
                ),

                const SizedBox(width: 6),

                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  tooltip: 'Reproducir sonido',
                  onPressed: () {
                    AudioService.instance.speak("Toca la letra ${displayChar()}");
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Center(
                  child: ButtonLetter(
                    letter: displayChar(),
                    onPressed: () {}, // por ejemplo reproducir sonido de la letra
                    size: 180.0,
                  ),
                ),
                const SizedBox(height: 20),

                // Flechas: izquierda oculta en la primera letra
                // navegación opcional abajo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8, ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasPrev)
                        IconButton(
                          color: Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LearnLetterScreen(index: prevIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: const Icon(Icons.arrow_back_ios),
                        )
                      else
                        const SizedBox(width: 48),
                      if (hasNext)
                        IconButton(
                          color: Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LearnLetterScreen(index: nextIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
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
                        final displayWord = isUppercase ? word.toUpperCase() : word.toLowerCase();
                        return ButtonPictogramLetters(
                          pictogramFuture: currentLetter.pictogramFile(word),
                          letters: displayWord,
                          onPressed: () {
                            // Si está en minúsculas, avanzar a la siguiente letra manteniendo minúsculas
                            if (!isUppercase && hasNext) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => LearnLetterScreen(index: nextIndex, initialIsUppercase: false)),
                              );
                              return;
                            }
                            // acción por defecto: reproducir palabra (implementa según tu servicio de audio)
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
