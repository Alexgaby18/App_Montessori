import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/screens/practice/practice_word_ml.dart';
import 'package:my_montessori/presentation/widgets/button_word.dart';

class PracticeWordScreen extends StatefulWidget {
  const PracticeWordScreen({Key? key}) : super(key: key);

  @override
  State<PracticeWordScreen> createState() => _PracticeWordScreenState();
}

class _PracticeWordScreenState extends State<PracticeWordScreen> {
  bool _useMachineLearning = true;
  int _mlStartIndex = 0;
  bool _isUppercase = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = (_mlStartIndex >= 0 && _mlStartIndex < words.length)
        ? (_isUppercase ? words[_mlStartIndex].text.toUpperCase() : words[_mlStartIndex].text.toLowerCase())
        : 'palabras';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _useMachineLearning ? 'Practicar la palabra $currentWord' : 'Practicar palabras',
        ),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        iconSize: 44,
                        color: const Color.fromARGB(255, 55, 35, 28),
                        tooltip: _isUppercase ? 'Cambiar a minúsculas' : 'Cambiar a mayúsculas',
                        onPressed: () => setState(() => _isUppercase = !_isUppercase),
                        icon: const Text(
                          'Aa',
                          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 55, 35, 28)),
                        ),
                      ),
                      IconButton(
                        iconSize: 44,
                        color: const Color.fromARGB(255, 55, 35, 28),
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          if (_useMachineLearning) {
                            AudioService.instance.speak('Practica escribiendo la palabra $currentWord');
                          } else {
                            AudioService.instance.speak('Selecciona una palabra para practicar');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _useMachineLearning
                      ? PracticeWordScreenML(
                          embedded: true,
                          initialIndex: _mlStartIndex,
                          initialIsUppercase: _isUppercase,
                          onIndexChanged: (newIndex) => setState(() => _mlStartIndex = newIndex),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ListView.builder(
                            itemCount: words.length,
                            itemBuilder: (context, index) {
                              final word = words[index].text;
                              final display = _isUppercase ? word.toUpperCase() : word.toLowerCase();
                              return ButtonWord(
                                text: display,
                                onPressed: () {
                                  setState(() {
                                    _mlStartIndex = index;
                                    _useMachineLearning = true;
                                  });
                                  AudioService.instance.speak(word);
                                },
                              );
                            },
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
