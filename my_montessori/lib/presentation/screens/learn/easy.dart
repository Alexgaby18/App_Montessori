import 'package:flutter/material.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class EasyLearnLetterScreen extends StatefulWidget {
  final int index; // index de la letra en la lista `letters`
  final bool initialIsUppercase;

  const EasyLearnLetterScreen({
    Key? key,
    required this.index,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<EasyLearnLetterScreen> createState() => _EasyLearnLetterScreenState();
}

class _EasyLearnLetterScreenState extends State<EasyLearnLetterScreen> {
  bool isUppercase = true;

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  @override
  Widget build(BuildContext context) {
    final currentLetter = vowels[widget.index];
    final bool hasPrev = widget.index > 0;
    final bool hasNext = widget.index < vowels.length - 1;
    final int prevIndex = widget.index - 1;
    final int nextIndex = widget.index + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizeButtonLetter = isTablet ? 280.0 : 180.0;
    final sizePictogram = isTablet ? 220.0 : 120.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;
    String displayChar() => isUppercase ? currentLetter.char.toUpperCase() : currentLetter.char.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text('Aprende la Vocal ${currentLetter.char}'),
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
                    size: sizeButtonLetter,
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
                            MaterialPageRoute(builder: (_) => EasyLearnLetterScreen(index: prevIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_back_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                      if (hasNext)
                        IconButton(
                          color: Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => EasyLearnLetterScreen(index: nextIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon:  Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Lista de pictogramas: filtrar para mostrar solo vocales
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Builder(builder: (context) {
                      // Mostrar las palabras que empiezan por la vocal actual
                      String _normChar(String ch) {
                        if (ch.isEmpty) return '';
                        const accents = 'áéíóúÁÉÍÓÚñÑüÜ';
                        const replacements = 'aeiouAEIOUnNuU';
                        final idx = accents.indexOf(ch);
                        if (idx != -1) return replacements[idx];
                        return ch;
                      }

                      final vowelWords = currentLetter.words.where((w) {
                        final s = w.trim();
                        if (s.isEmpty) return false;
                        final first = _normChar(s[0]).toLowerCase();
                        final letter = _normChar(currentLetter.char).toLowerCase();
                        return first == letter;
                      }).toList();

                      return Wrap(
                        alignment: WrapAlignment.center,
                        spacing: isTablet ? 60 : 30,
                        runSpacing: isTablet ? 60 : 30,
                        children: vowelWords.map((word) {
                          final displayWord = isUppercase ? word.toUpperCase() : word.toLowerCase();
                          return ButtonPictogramLetters(
                            pictogramFuture: currentLetter.pictogramFile(word),
                            letters: displayWord,
                            onPressed: () {
                              if (!isUppercase && hasNext) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => EasyLearnLetterScreen(index: nextIndex, initialIsUppercase: false)),
                                );
                                return;
                              }
                              // acción por defecto: reproducir palabra (implementa según tu servicio de audio)
                            },
                            size: sizePictogram,
                          );
                        }).toList(),
                      );
                    }),
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
