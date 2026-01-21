import 'dart:math';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_word.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class SelectionWordScreen extends StatefulWidget {
  final int index; // índice de la palabra en la lista `words`

  const SelectionWordScreen({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  State<SelectionWordScreen> createState() => _SelectionWordScreenState();
}

class _SelectionWordScreenState extends State<SelectionWordScreen> {
  late final Word currentWord;
  late List<Word> options;
  final _random = Random();
  bool _locked = false; // evita pulsaciones mientras se procesa
  late final Future<File?> pictogramFuture;

  @override
  void initState() {
    super.initState();
    currentWord = words[widget.index];
    _buildOptions();
    // Guardar el Future una sola vez para que no se recree en cada build
    pictogramFuture = currentWord.pictogramFile();
  }

  void _buildOptions() {
    // Construye lista de opciones: palabra correcta + 2 distractores aleatorios
    final List<Word> pool = List<Word>.from(words);
    pool.removeWhere((w) => w.text == currentWord.text);

    final Set<Word> chosen = {currentWord};
    while (chosen.length < 3 && pool.isNotEmpty) {
      final idx = _random.nextInt(pool.length);
      chosen.add(pool.removeAt(idx));
    }

    options = chosen.toList();
    options.shuffle(_random);
  }

  Future<void> _onOptionPressed(Word selected) async {
    if (_locked) return;

    if (selected.text == currentWord.text) {
      // respuesta correcta: bloquear la UI para evitar pulsaciones mientras se procesa
      setState(() => _locked = true);
      try {
        await AudioService.instance.speak('¡Muy bien!');
        await Future.delayed(const Duration(milliseconds: 800));
        await AudioService.instance.speak(currentWord.text); // repetir la palabra
        // avanzar automáticamente después de una pausa corta
        await Future.delayed(const Duration(milliseconds: 600));
        final hasNext = widget.index < words.length - 1;
        if (hasNext) {
          final nextIndex = widget.index + 1;
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SelectionWordScreen(index: nextIndex)),
          );
        } else {
          await AudioService.instance.speak('¡Has completado todas las palabras!');
          if (mounted) Navigator.pop(context);
        }
      } finally {
        if (mounted) setState(() => _locked = false);
      }
    } else {
      // incorrecto: sólo dar feedback de audio, sin bloquear ni atenuar toda la UI
      await AudioService.instance.speak(selected.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPrev = widget.index > 0;
    final bool hasNext = widget.index < words.length - 1;
    final int prevIndex = widget.index - 1;
    final int nextIndex = widget.index + 1;

    // `pictogramFuture` ya está inicializado en initState

    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona la palabra'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),

          // boton volumen (instruccion)
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: const Icon(Icons.volume_up),
              iconSize: 44,
              color: const Color.fromARGB(255, 55, 35, 28),
              onPressed: () {
                AudioService.instance.speak('Selecciona la palabra ${currentWord.text}');
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),

                // pictograma grande (usa tu widget que maneja Future<File?>)
                Center(
                  child: ButtonPictogramLetters(
                    pictogramFuture: pictogramFuture,
                    size: 200.0,
                    onPressed: () async {
                    },
                    letters: currentWord.text.toUpperCase(),
                  ),
                ),

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
                            MaterialPageRoute(builder: (_) => SelectionWordScreen(index: prevIndex)),
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
                            MaterialPageRoute(builder: (_) => SelectionWordScreen(index: nextIndex)),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // botones de opciones (estética similar a la imagen: tres botones verticales)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: options.map((opt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AbsorbPointer(
                          absorbing: _locked, // bloquea la interacción cuando true
                          child: Opacity(
                            opacity: _locked ? 0.6 : 1.0, // atenua visualmente cuando bloqueado
                            child: ButtonWord(
                              text: opt.text.toUpperCase(),
                              onPressed: () => _onOptionPressed(opt), // siempre no nulo
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const Spacer(),

              ],
            ),
          ),
        ],
      ),
    );
  }
}