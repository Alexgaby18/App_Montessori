import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/presentation/screens/practice_letter_ml.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';

class PracticeLetterScreen extends StatefulWidget {
  const PracticeLetterScreen({Key? key}) : super(key: key);

  @override
  State<PracticeLetterScreen> createState() => _PracticeLetterScreenState();
}

class _PracticeLetterScreenState extends State<PracticeLetterScreen> {
  bool _useMachineLearning = true;

  @override
  Widget build(BuildContext context) {
    if (_useMachineLearning) {
      return PracticeLetterScreenML();
    }

    // Versión alternativa (opcional)
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practicar letras'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              setState(() {
                _useMachineLearning = !_useMachineLearning;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Grid de letras para práctica simple
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  return ButtonLetter(
                    letter: letter.char,
                    onPressed: () {
                      // Aquí podrías navegar a una pantalla simple de práctica
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}