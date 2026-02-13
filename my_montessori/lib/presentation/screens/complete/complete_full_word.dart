import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';

class CompleteFullWordScreen extends StatefulWidget {
  final int index; // indice en la lista `letters`
  final String word; // opcional: palabra objetivo (si no viene, usamos first)
  final bool initialIsUppercase;

  const CompleteFullWordScreen({
    Key? key,
    required this.index,
    this.word = '',
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<CompleteFullWordScreen> createState() => _CompleteFullWordScreenState();
}

class _CompleteFullWordScreenState extends State<CompleteFullWordScreen> {
  late final Letter _letterObj;
  late final String _word; // palabra en mayusculas sin espacios
  late List<int> _missingIndexes;
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

    _missingIndexes = List<int>.generate(_word.length, (i) => i);
    _slots = List<String?>.generate(_word.length, (_) => null);
    _setupPool();
  }

  void _setupPool() {
    final alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final missingLetters = _missingIndexes.map((i) => _word[i]).toList();
    final int targetSize = max(6, missingLetters.length + 2);

    final Set<String> distractors = {};
    while (missingLetters.length + distractors.length < targetSize) {
      final c = alphabet[_random.nextInt(alphabet.length)];
      if (!missingLetters.contains(c)) distractors.add(c);
    }

    _pool = [...missingLetters, ...distractors];
    _pool.shuffle(_random);
  }

  Future<void> _onCorrectComplete() async {
    await AudioService.instance.speak(_word);
    await Future.delayed(const Duration(milliseconds: 700));
    final hasNext = widget.index < letters.length - 1;
    if (hasNext) {
      final nextIndex = widget.index + 1;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CompleteFullWordScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
      );
    } else {
      await AudioService.instance.speak('¡Has completado todas las letras!');
    }
  }

  bool get _isCompleted => _slots.every((s) => s != null && s!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final hasPrev = widget.index > 0;
    final hasNext = widget.index < letters.length - 1;
    final prevIndex = (widget.index - 1).clamp(0, letters.length - 1);
    final nextIndex = (widget.index + 1).clamp(0, letters.length - 1);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizePictogram = isTablet ? 280.0 : 180.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa la palabra'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),
          Positioned(
            right: 8,
            top: 8,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  tooltip: _isUppercase ? 'Cambiar a minusculas' : 'Cambiar a mayusculas',
                  onPressed: () => setState(() => _isUppercase = !_isUppercase),
                  icon: const Text('Aa', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 55, 35, 28))),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  onPressed: () {
                    AudioService.instance.speak('Completa toda la palabra');
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
                  child: ButtonPictogramLetters(
                    pictogramFuture: _letterObj.pictogramFile(_letterObj.words.first),
                    size: sizePictogram,
                    onPressed: () async {},
                    letters: _isUppercase ? _word : _word.toLowerCase(),
                  ),
                ),
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
                            MaterialPageRoute(
                              builder: (_) => CompleteFullWordScreen(index: prevIndex, initialIsUppercase: _isUppercase),
                            ),
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
                            MaterialPageRoute(
                              builder: (_) => CompleteFullWordScreen(index: nextIndex, initialIsUppercase: _isUppercase),
                            ),
                          ),
                          icon: Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizeButtonLetter = isTablet ? 80.0 : 54.0;

    return DragTarget<String>(
      onWillAccept: (data) => data != null && _slots[index] == null,
      onAccept: (data) async {
        if (data.toUpperCase() == _word[index]) {
          setState(() {
            _slots[index] = data;
            _pool.remove(data);
          });

          await AudioService.instance.speakLetter(_isUppercase ? _slots[index]! : _slots[index]!.toLowerCase());
          if (_isCompleted) {
            await _onCorrectComplete();
          }
        } else {
          await AudioService.instance.speak('Intenta de nuevo');
        }
      },
      builder: (context, candidateData, rejectedData) {
        final display = content == null ? '' : (_isUppercase ? content! : content!.toLowerCase());
        return Container(
          width: sizeButtonLetter,
          height: sizeButtonLetter,
          decoration: BoxDecoration(
            color: content == null ? Colors.white : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB7C2D7), width: 1.8),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(1, 2))],
          ),
          child: Center(
            child: Text(
              display,
              style: TextStyle(fontSize: sizeButtonLetter * 0.55, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(String letter) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizeButtonLetter = isTablet ? 100.0 : 64.0;
    final displayLetter = _isUppercase ? letter : letter.toLowerCase();
    final tile = SizedBox(
      width: sizeButtonLetter,
      height: sizeButtonLetter,
      child: ButtonLetter(
        letter: displayLetter,
        onPressed: () {},
        size: sizeButtonLetter,
      ),
    );

    return Draggable<String>(
      data: letter,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.95, child: SizedBox(width: sizeButtonLetter, height: sizeButtonLetter, child: tile)),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: tile),
      child: tile,
    );
  }
}
