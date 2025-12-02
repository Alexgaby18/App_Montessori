// ...existing code...
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

  const CompleteLetterScreen({Key? key, required this.index, this.word = ''}) : super(key: key);

  @override
  State<CompleteLetterScreen> createState() => _CompleteLetterScreenState();
}

class _CompleteLetterScreenState extends State<CompleteLetterScreen> {
  late final Letter _letterObj;
  late final String _word; // palabra en mayúsculas sin espacios
  late List<String?> _slots;
  late List<String> _pool; // letras disponibles (shuffled)

  @override
  void initState() {
    super.initState();
    _letterObj = letters[widget.index];
    _word = (widget.word.isNotEmpty ? widget.word : _letterObj.words.first).toUpperCase();
    _slots = List<String?>.filled(_word.length, null);
    // pool: letras de la palabra + algunas letras extras opcionalmente
    _pool = _word.split('');
    // agregar letras extra (vocales) para opciones
    _pool.addAll(['A', 'E', 'I', 'O', 'U']);
    _pool = _pool.map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    _pool.shuffle(Random());
  }

  void _onCorrectComplete() {
    AudioService.instance.speak('¡Muy bien!'); // o reproducir asset
    // animación / navegar / marcar como completado...
  }

  bool get _isComplete => _slots.every((s) => s != null && s!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final hasPrev = widget.index > 0;
    final hasNext = widget.index < letters.length - 1;
    final prevIndex = (widget.index - 1).clamp(0, letters.length - 1);
    final nextIndex = (widget.index + 1).clamp(0, letters.length - 1);

    // ahora usamos pictogramFile (Future<File?>) en vez de asset directo
    final Future mainPictogramFuture = _letterObj.pictogramFile(_letterObj.words.first);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 174, 220, 235),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.black87),
            onPressed: () {
              // instrucción de la actividad
              AudioService.instance.speak('Toca las letras para completar la palabra');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),

                // pictograma grande: usamos FutureBuilder para el File devuelto por pictogramFile()
                Center(
                  child: FutureBuilder(
                    future: mainPictogramFuture,
                    builder: (context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 220,
                          height: 220,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final file = snapshot.data;
                      return Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: Container(
                          width: 220,
                          height: 220,
                          padding: const EdgeInsets.all(12),
                          child: (file != null)
                              ? Image.file(file, fit: BoxFit.contain)
                              : Image.asset('assets/images/pictogram_letters/${_letterObj.char.toLowerCase()}/${_letterObj.words.first.toLowerCase().replaceAll(' ', '_')}.png', fit: BoxFit.contain),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                // palabra objetivo: slots (DragTargets)
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

                const SizedBox(height: 18),

                // pool de letras (draggables). Para cada palabra de la lista usamos pictogramFile(word)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _pool.map((letter) => _buildDraggableTile(letter)).toList(),
                  ),
                ),

                const Spacer(),

                // flechas navegación abajo (opcional)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (hasPrev)
                        IconButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: prevIndex)),
                          ),
                          icon: const Icon(Icons.arrow_back_ios),
                        )
                      else
                        const SizedBox(width: 48),
                      if (hasNext)
                        IconButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => CompleteLetterScreen(index: nextIndex)),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlot(int index) {
    final content = _slots[index];
    return DragTarget<String>(
      onWillAccept: (data) => data != null,
      onAccept: (data) async {
        setState(() {
          _slots[index] = data;
          // quitar una instancia de esa letra del pool para que no se reutilice
          final removed = _pool.indexOf(data);
          if (removed != -1) _pool.removeAt(removed);
        });
        // si correcto en esa posición, reproducir sonido de la letra
        if (_slots[index] == _word[index]) {
          await AudioService.instance.playLetterSound(_slots[index]!);
        } else {
          // opcional: reproducir feedback de error
          await AudioService.instance.speak('Intenta de nuevo');
        }

        if (_isComplete) {
          // comprobar si la palabra es correcta
          final formed = _slots.join();
          if (formed == _word) {
            _onCorrectComplete();
          } else {
            // si no es correcta, reset parcial o permitir corrección
            await AudioService.instance.speak('No coincide, intenta otra vez');
          }
        }
      },
      builder: (context, candidateData, rejectedData) {
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
              content ?? '',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(String letter) {
    // reutiliza ButtonLetter visual y comportamiento al pulsar (reproduce sonido)
    final tile = SizedBox(
      width: 64,
      height: 64,
      child: ButtonLetter(
        letter: letter,
        onPressed: () => AudioService.instance.playLetterSound(letter),
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