import 'package:flutter/material.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class HardLearnLetterScreen extends StatefulWidget {
  final int index; // index de la letra en la lista `letters`
  final bool initialIsUppercase;

  const HardLearnLetterScreen({
    Key? key,
    required this.index,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<HardLearnLetterScreen> createState() => _HardLearnLetterScreenState();
}

class _HardLearnLetterScreenState extends State<HardLearnLetterScreen> {
  bool isUppercase = true;
  bool _useMachineLearning = false; // por defecto mostrar selector de letra

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar grid embebido cuando _useMachineLearning == false

    void _openSyllablePicker(String letterChar) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SyllablePickerScreen(letterChar: letterChar, initialIsUppercase: isUppercase)),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizeButtonLetter = isTablet ? 280.0 : 180.0;
    final sizePictogram = isTablet ? 220.0 : 120.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;
    String displayChar() => isUppercase ? '' : '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Elige una letra'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 100.0, 30.0, 30.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.1,
                ),
                itemCount: syllables.length,
                itemBuilder: (c, i) {
                  final l = syllables[i];
                  final display = isUppercase ? l.char : l.char.toLowerCase();
                  return ButtonLetter(
                    letter: display,
                    size: 80.0,
                    onPressed: () => _openSyllablePicker(l.char),
                  );
                },
              ),
            ), 
          ),
         
          // icono volumen (a la derecha) -- dibujado encima del contenido
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
                const SizedBox(width: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SyllablePickerScreen extends StatefulWidget {
  final String letterChar;
  final bool initialIsUppercase;

  const SyllablePickerScreen({Key? key, required this.letterChar, this.initialIsUppercase = true}) : super(key: key);

  @override
  State<SyllablePickerScreen> createState() => _SyllablePickerScreenState();
}

class _SyllablePickerScreenState extends State<SyllablePickerScreen> {
  late bool isUppercase;

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  String displayChar() => isUppercase ? widget.letterChar : widget.letterChar.toLowerCase();

  @override
  Widget build(BuildContext context) {
    final sylls = syllablesByLetter[widget.letterChar] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('Sílabas de ${widget.letterChar}'), 
      backgroundColor: const Color.fromARGB(255, 68, 194, 193),),
      body: Stack(
        children: [
          const BackgroundAnimation(),
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
                    AudioService.instance.speak("Toca la Sílaba ${displayChar()}");
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 100, 30, 30),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: sylls.length,
              itemBuilder: (c, i) {
                final s = sylls[i];
                final label = isUppercase ? s.char : s.char.toLowerCase();
                return ButtonLetter(
                  letter: label,
                  size: 80,
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SyllableLearnScreen(letterChar: widget.letterChar, syllableIndex: i, initialIsUppercase: isUppercase)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SyllableLearnScreen extends StatefulWidget {
  final String letterChar;
  final int syllableIndex;
  final bool initialIsUppercase;

  const SyllableLearnScreen({Key? key, required this.letterChar, required this.syllableIndex, this.initialIsUppercase = true}) : super(key: key);

  @override
  State<SyllableLearnScreen> createState() => _SyllableLearnScreenState();
}

class _SyllableLearnScreenState extends State<SyllableLearnScreen> {
  bool isUppercase = true;

  @override
  void initState() {
    super.initState();
    isUppercase = widget.initialIsUppercase;
  }

  @override
  Widget build(BuildContext context) {
    final syllList = syllablesByLetter[widget.letterChar] ?? [];
    if (widget.syllableIndex < 0 || widget.syllableIndex >= syllList.length) {
      return Scaffold(body: Center(child: Text('Sílaba no encontrada')));
    }
    final current = syllList[widget.syllableIndex];
    final bool hasPrev = widget.syllableIndex > 0;
    final bool hasNext = widget.syllableIndex < syllList.length - 1;
    final int prevIndex = widget.syllableIndex - 1;
    final int nextIndex = widget.syllableIndex + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final sizeButtonLetter = isTablet ? 280.0 : 180.0;
    final sizePictogram = isTablet ? 220.0 : 120.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;
    String displayChar() => isUppercase ? current.char.toUpperCase() : current.char.toLowerCase();

    return Scaffold(
      appBar: AppBar(title: Text('Aprende ${current.char}'),
      backgroundColor: const Color.fromARGB(255, 68, 194, 193),),
      body: Stack(
        children: [
          const BackgroundAnimation(),
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
                    AudioService.instance.speak("Toca la Sílaba ${displayChar()}");
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
                        child: ButtonLetter(letter: displayChar(), onPressed: () {}, size: sizeButtonLetter),
                      ),
                const SizedBox(height: 24),
                // Flechas para navegar entre sílabas de la misma letra
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasPrev)
                        IconButton(
                          color: const Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SyllableLearnScreen(letterChar: widget.letterChar, syllableIndex: prevIndex, initialIsUppercase: isUppercase)),
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
                            MaterialPageRoute(builder: (_) => SyllableLearnScreen(letterChar: widget.letterChar, syllableIndex: nextIndex, initialIsUppercase: isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isTablet ? 60 : 30,
                      runSpacing: isTablet ? 60 : 30,
                      children: current.words.map((word) {
                        final displayWord = isUppercase ? word.toUpperCase() : word.toLowerCase();
                        return ButtonPictogramLetters(
                          pictogramFuture: current.pictogramFile(word),
                          letters: displayWord,
                          onPressed: () {},
                          size: sizePictogram,
                        );
                      }).toList(),
                    ),
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
