import 'package:flutter/material.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class LearnSentenceScreen extends StatefulWidget {
  final int index;
  final bool initialIsUppercase;

  const LearnSentenceScreen({Key? key, required this.index, this.initialIsUppercase = true}) : super(key: key);

  @override
  State<LearnSentenceScreen> createState() => _LearnSentenceScreenState();
}

class _LearnSentenceScreenState extends State<LearnSentenceScreen> {
  bool isUppercase = true;

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  @override
  Widget build(BuildContext context) {
    final total = sentencePictograms.length;
    final currentIndex = widget.index.clamp(0, total - 1);
    final current = sentencePictograms[currentIndex];
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < total - 1;
    final prevIndex = currentIndex - 1;
    final nextIndex = currentIndex + 1;

    final shortestSide = MediaQuery.of(context).size.shortestSide;
    // Detecta tablet por el lado más corto para que la orientación no cambie
    // la clasificación (evita que landscape en móvil se considere tablet).
    final isTablet = shortestSide >= 600;
    final sizePictogram = isTablet ? 220.0 : 140.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;

    String displaySentence() => isUppercase ? current.text.toUpperCase() : current.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprende oraciones'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),

          // iconos arriba (Aa y volumen)
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  tooltip: 'Reproducir oración',
                  onPressed: () => AudioService.instance.speak(current.text),
                ),
              ],
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),

                // Pictogramas por palabra
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isTablet ? 60 : 30,
                      runSpacing: isTablet ? 60 : 30,
                      children: current.tokens.map((t) {
                        final displayWord = isUppercase ? t.token.toUpperCase() : t.token.toLowerCase();
                        return ButtonPictogramLetters(
                          pictogramFuture: t.pictogramFile(),
                          letters: displayWord,
                          onPressed: () async {
                          },
                          size: sizePictogram,
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Flechas prev/next
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasPrev)
                        IconButton(
                          color: const Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LearnSentenceScreen(index: prevIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_back_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                      if (hasNext)
                        IconButton(
                          color: const Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LearnSentenceScreen(index: nextIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
