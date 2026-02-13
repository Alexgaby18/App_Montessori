import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';

class CompleteSyllablesScreen extends StatefulWidget {
  final int index; // indice en la lista `letters`
  final String word; // opcional: palabra objetivo (si no viene, usamos first)
  final bool initialIsUppercase;

  const CompleteSyllablesScreen({
    Key? key,
    required this.index,
    this.word = '',
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<CompleteSyllablesScreen> createState() => _CompleteSyllablesScreenState();
}

class _CompleteSyllablesScreenState extends State<CompleteSyllablesScreen> {
  static const _vowels = 'AEIOUÁÉÍÓÚÜ';

  late final Letter _syllableEntry;
  late final int _entryIndex;
  late final String _word;
  late final List<String> _syllables;
  late List<String?> _slots;
  late List<String> _pool;
  bool _isUppercase = true;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    final entries = _allSyllableEntries();
    _entryIndex = entries.isEmpty ? 0 : widget.index.clamp(0, entries.length - 1);
    _syllableEntry = entries.isEmpty ? const Letter(char: '', words: ['']) : entries[_entryIndex];
    final fallbackWord = _syllableEntry.words.isNotEmpty ? _syllableEntry.words.first : '';
    _word = (widget.word.isNotEmpty ? widget.word : fallbackWord).toUpperCase();
    _isUppercase = widget.initialIsUppercase;

    _syllables = _splitIntoSyllables(_word);
    _slots = List<String?>.generate(_syllables.length, (_) => null);
    _setupPool();
  }

  List<String> _splitIntoSyllables(String word) {
    final syllables = <String>[];
    var buffer = '';

    for (int i = 0; i < word.length; i++) {
      final ch = word[i];
      final isVowel = _vowels.contains(ch);
      final next = i + 1 < word.length ? word[i + 1] : '';
      final nextIsVowel = next.isNotEmpty && _vowels.contains(next);

      buffer += ch;
      if (isVowel && !nextIsVowel) {
        syllables.add(buffer);
        buffer = '';
      }
    }

    if (buffer.isNotEmpty) {
      if (syllables.isEmpty) {
        syllables.add(buffer);
      } else {
        syllables[syllables.length - 1] += buffer;
      }
    }

    return syllables.isEmpty ? [word] : syllables;
  }

  List<Letter> _allSyllableEntries() {
    final list = <Letter>[];
    for (final group in syllablesByLetter.values) {
      list.addAll(group);
    }
    return list;
  }

  List<String> _allSyllables() {
    final list = <String>[];
    for (final group in syllablesByLetter.values) {
      for (final s in group) {
        list.add(s.char.toUpperCase());
      }
    }
    return list;
  }

  void _setupPool() {
    final missingSyllables = List<String>.from(_syllables);
    final int targetSize = max(6, missingSyllables.length + 2);

    final allSyllables = _allSyllables();
    final Set<String> distractors = {};
    while (missingSyllables.length + distractors.length < targetSize && allSyllables.isNotEmpty) {
      final c = allSyllables[_random.nextInt(allSyllables.length)];
      if (!missingSyllables.contains(c)) distractors.add(c);
    }

    _pool = [...missingSyllables, ...distractors];
    _pool.shuffle(_random);
  }

  Future<void> _onCorrectComplete() async {
    await AudioService.instance.speak(_word);
    await Future.delayed(const Duration(milliseconds: 700));
    final total = _allSyllableEntries().length;
    final hasNext = total > 0 && _entryIndex < total - 1;
    if (hasNext) {
      final nextIndex = _entryIndex + 1;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CompleteSyllablesScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
      );
    } else {
      await AudioService.instance.speak('¡Has completado todas las letras!');
    }
  }

  bool get _isCompleted => _slots.every((s) => s != null && s!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final hasPrev = widget.index > 0;
    final total = _allSyllableEntries().length;
    final hasNext = total > 0 && _entryIndex < total - 1;
    final prevIndex = (_entryIndex - 1).clamp(0, total - 1);
    final nextIndex = (_entryIndex + 1).clamp(0, total - 1);
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizePictogram = isTablet ? 280.0 : 180.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completa por sílaba'),
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
                  tooltip: _isUppercase ? 'Cambiar a minúsculas' : 'Cambiar a mayúsculas',
                  onPressed: () => setState(() => _isUppercase = !_isUppercase),
                  icon: const Text('Aa', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 55, 35, 28))),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  onPressed: () {
                    AudioService.instance.speak('Completa la palabra por sílabas');
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
                    pictogramFuture: _syllableEntry.pictogramFile(_syllableEntry.words.first),
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
                              builder: (_) => CompleteSyllablesScreen(index: prevIndex, initialIsUppercase: _isUppercase),
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
                              builder: (_) => CompleteSyllablesScreen(index: nextIndex, initialIsUppercase: _isUppercase),
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
                    children: List.generate(_syllables.length, (i) {
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
                    children: _pool.map((syllable) => _buildDraggableTile(syllable)).toList(),
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
    final baseSize = isTablet ? 80.0 : 54.0;
    final width = baseSize * 1.4;

    return DragTarget<String>(
      onWillAccept: (data) => data != null && _slots[index] == null,
      onAccept: (data) async {
        if (data.toUpperCase() == _syllables[index]) {
          setState(() {
            _slots[index] = data;
            _pool.remove(data);
          });

          await AudioService.instance.speak(_isUppercase ? _syllables[index] : _syllables[index].toLowerCase());
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
          width: width,
          height: baseSize,
          decoration: BoxDecoration(
            color: content == null ? Colors.white : const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFB7C2D7), width: 1.8),
            boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 4, offset: Offset(1, 2))],
          ),
          child: Center(
            child: Text(
              display,
              style: TextStyle(fontSize: baseSize * 0.45, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableTile(String syllable) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final baseSize = isTablet ? 100.0 : 64.0;
    final width = baseSize * 1.4;
    final displaySyllable = _isUppercase ? syllable : syllable.toLowerCase();
    final tile = SizedBox(
      width: width,
      height: baseSize,
      child: ButtonLetter(
        letter: displaySyllable,
        onPressed: () {},
        size: baseSize,
      ),
    );

    return Draggable<String>(
      data: syllable,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(opacity: 0.95, child: SizedBox(width: width, height: baseSize, child: tile)),
      ),
      childWhenDragging: Opacity(opacity: 0.25, child: tile),
      child: tile,
    );
  }
}
