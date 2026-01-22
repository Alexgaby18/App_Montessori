// ...existing code...
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';

class CompleteLetterScreen extends StatefulWidget {
  final int index; // índice en la lista `letters`
  final String word; // opcional: palabra objetivo (si no viene, usamos first)
  final int? targetIndex; // posición a completar (opcional)
  final bool initialIsUppercase;

  const CompleteLetterScreen({
    Key? key,
    required this.index,
    this.word = '',
    this.targetIndex,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<CompleteLetterScreen> createState() => _CompleteLetterScreenState();
}

class _CompleteLetterScreenState extends State<CompleteLetterScreen> {
  late final Letter _letterObj;
  late final String _word; // palabra en mayúsculas sin espacios
  late final int _targetIndex; // posición que el alumno debe completar
  late List<String?> _slots;
  late List<String> _pool; // letras disponibles (shuffled)
  bool _isUppercase = true;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _letterObj = letters[widget.index];
    _word = (widget.word.isNotEmpty ? widget.word : _letterObj.words.first).toUpperCase();
    _isUppercase = widget.initialIsUppercase;

    // Intentar usar la posición de la letra que estamos enseñando dentro de la palabra.
    // Ej: letra = 'X', palabra = 'TAXI' -> targetIndex = 2
    final teachingChar = _letterObj.char.toUpperCase();
    final found = _word.indexOf(teachingChar);
    if (found != -1) {
      _targetIndex = found;
    } else {
      // Si la letra no aparece en la palabra, elegimos una posición razonable
      _targetIndex = widget.targetIndex ?? _chooseFallbackTargetIndex(_word);
    }

    // inicializa slots: posición objetivo = null, resto muestran la letra
    _slots = List<String?>.generate(_word.length, (i) => i == _targetIndex ? null : _word[i]);
    // Pool: incluir la letra correcta + distractores aleatorios
    _setupPool();
  }

  // Heurística de reserva (no encontrada la letra en la palabra)
  // preferimos la primera consonante que NO sea la primera letra,
  // si no hay, elegimos la segunda letra, si no la primera.
  int _chooseFallbackTargetIndex(String word) {
    final vowels = 'AEIOUÁÉÍÓÚ';
    for (int i = 1; i < word.length; i++) {
      final ch = word[i];
      if (!vowels.contains(ch)) return i; // consonante no primera
    }
    if (word.length > 1) return 1;
    return 0;
  }

  void _setupPool() {
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final correct = _word[_targetIndex]; // correcto: la letra en la posición objetivo
    final Set<String> poolSet = {correct};

    while (poolSet.length < 6) {
      final c = alphabet[_random.nextInt(alphabet.length)];
      if (c != correct) poolSet.add(c);
    }

    _pool = poolSet.toList();
    _pool.shuffle(_random);
  }

  Future<void> _onCorrectComplete() async {
    // Repite la palabra al completar (usa speak para nombre de la palabra)
    await AudioService.instance.speak(_word);
    // breve pausa y avanzar automáticamente a la siguiente letra si existe
    await Future.delayed(const Duration(milliseconds: 700));
    final hasNext = widget.index < letters.length - 1;
    if (hasNext) {
      final nextIndex = widget.index + 1;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
      );
    } else {
      // fin de la lista: feedback final
      await AudioService.instance.speak('¡Has completado todas las letras!');
    }
  }

  bool get _isFirstSlotFilled => _slots[0] != null && _slots[0]!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final hasPrev = widget.index > 0;
    final hasNext = widget.index < letters.length - 1;
    final prevIndex = (widget.index - 1).clamp(0, letters.length - 1);
    final nextIndex = (widget.index + 1).clamp(0, letters.length - 1);

    final Future mainPictogramFuture = _letterObj.pictogramFile(_letterObj.words.first);

    return Scaffold(
      appBar: AppBar(
        title: Text('Completa la letra ${_letterObj.char}'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          // icono volumen (a la derecha) + Aa
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  tooltip: _isUppercase ? 'Cambiar a minúsculas' : 'Cambiar a mayúsculas',
                  onPressed: () => setState(() => _isUppercase = !_isUppercase),
                  icon: Text('Aa', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255,55,35,28))),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  onPressed: () {
                    AudioService.instance.speak("Completa la palabra con  la letra ${_letterObj.char}");
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),

                // pictograma grande usando ButtonPictogramLetters (muestra imagen + nombre)
                Center(
                  child: ButtonPictogramLetters(
                    pictogramFuture: _letterObj.pictogramFile(_letterObj.words.first),
                    size: 180.0,
                    onPressed: () async {
                    },
                    letters: _isUppercase ? _word : _word.toLowerCase(),
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
                            MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: prevIndex, initialIsUppercase: _isUppercase)),
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
                            MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // palabra objetivo: mostrada con la primera letra como DragTarget y el resto visibles
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_word.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildSlot(i),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 30),

                // pool de letras (draggables) en orden aleatorio (ya barajado en _setupPool)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 15,
                    runSpacing: 15,
                    alignment: WrapAlignment.center,
                    children: _pool.map((letter) => _buildDraggableTile(letter)).toList(),
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

  Widget _buildSlot(int index) {
    final content = _slots[index];
    // Si no es la posición objetivo, mostramos la letra fija del _word
    if (index != _targetIndex) {
      return Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFB7C2D7), width: 1.8),
          boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(1,2))],
        ),
        child: Center(
          child: Text(
            _isUppercase ? _word[index] : _word[index].toLowerCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      );
    }

    // Para la posición objetivo usamos DragTarget
    return DragTarget<String>(
      onWillAccept: (data) => data != null,
      onAccept: (data) async {
        if (data.toUpperCase() == _word[_targetIndex]) {
          setState(() {
            _slots[_targetIndex] = data;
            final removed = _pool.indexOf(data);
            if (removed != -1) _pool.removeAt(removed);
          });

          // decir el nombre de la letra (usa speakLetter) y luego repetir la palabra y avanzar
          await AudioService.instance.speakLetter(_isUppercase ? _slots[_targetIndex]! : _slots[_targetIndex]!.toLowerCase());
          await _onCorrectComplete();
        } else {
          // feedback de error breve
          await AudioService.instance.speak('Intenta de nuevo');
        }
      },
      builder: (context, candidateData, rejectedData) {
        final display = content == null ? '' : (_isUppercase ? content! : content!.toLowerCase());
        return Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: content == null ? Colors.white : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB7C2D7), width: 1.8),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(1,2))],
          ),
          child: Center(
            child: Text(
                display,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(String letter) {
    final displayLetter = _isUppercase ? letter : letter.toLowerCase();
    final tile = SizedBox(
      width: 64,
      height: 64,
      child: ButtonLetter(
        letter: displayLetter,
        // tocar tile solo pronuncia la letra (no cambia estado)
        onPressed: (){} ,
        size: 64,
      ),
    );

    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.95, child: SizedBox(width: 64, height: 64, child: tile)),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: tile),
      child: tile,
    );
  }
}
// ...existing code...