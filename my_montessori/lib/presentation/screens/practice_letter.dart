import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/presentation/screens/practice_letter_ml.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class PracticeLetterScreen extends StatefulWidget {
  const PracticeLetterScreen({Key? key}) : super(key: key);

  @override
  State<PracticeLetterScreen> createState() => _PracticeLetterScreenState();
}

class _PracticeLetterScreenState extends State<PracticeLetterScreen> {
  bool _useMachineLearning = true;
  int _mlStartIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _useMachineLearning
              ? (_mlStartIndex >= 0 && _mlStartIndex < letters.length
                  ? 'Practicar letra ${letters[_mlStartIndex].char.toUpperCase()}'
                  : 'Practicar letras (ML)')
              : 'Practicar letras',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        centerTitle: true,
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
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () => setState(() => _useMachineLearning = !_useMachineLearning),
                      ),
                      IconButton(
                        iconSize: 44,
                        color: const Color.fromARGB(255, 55, 35, 28),
                        icon: const Icon(Icons.volume_up),
                        onPressed: () {
                          AudioService.instance.speak(
                            _useMachineLearning
                                ? 'Practica trazando la letra ${letters[_mlStartIndex].char.toUpperCase()}'
                                : 'Selecciona una letra para practicar',
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _useMachineLearning
                      ? PracticeLetterScreenML(
                              embedded: true,
                              initialIndex: _mlStartIndex,
                              onIndexChanged: (newIndex) => setState(() => _mlStartIndex = newIndex),
                            )
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 30),
                              Expanded(
                                child: GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 1.1,
                                  ),
                                  itemCount: letters.length,
                                  itemBuilder: (context, index) {
                                    final letter = letters[index];
                                    return ButtonLetter(
                                      letter: letter.char,
                                      onPressed: () {
                                        setState(() {
                                          _mlStartIndex = index;
                                          _useMachineLearning = true;
                                        });
                                        AudioService.instance.speakLetter(letter.char.toUpperCase());
                                      },
                                      size: 80.0,
                                    );
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 20, bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(30, 68, 194, 193),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color.fromARGB(100, 68, 194, 193),
                                    width: 1,
                                  ),
                                ),
                                
                              ),
                            ],
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