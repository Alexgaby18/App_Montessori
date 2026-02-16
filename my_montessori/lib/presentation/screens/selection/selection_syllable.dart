import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/presentation/widgets/button_word.dart';

class SelectionSyllableScreen extends StatefulWidget {
  final int index; // indice de la silaba en la lista aplanada
  final bool initialIsUppercase;

  const SelectionSyllableScreen({
    Key? key,
    required this.index,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<SelectionSyllableScreen> createState() => _SelectionSyllableScreenState();
}

class _SelectionSyllableScreenState extends State<SelectionSyllableScreen> {
  late final List<Letter> _syllableEntries;
  late final Letter _currentEntry;
  late final int _entryIndex;
  late final String _entryWord;
  late List<Letter> _options;
  final _random = Random();
  bool _locked = false; // evita pulsaciones mientras se procesa
  late final Future<File?> pictogramFuture;
  bool _isUppercase = true;

  @override
  void initState() {
    super.initState();
    _syllableEntries = _allSyllableEntries();
    _entryIndex = _syllableEntries.isEmpty ? 0 : widget.index.clamp(0, _syllableEntries.length - 1);
    _currentEntry = _syllableEntries.isEmpty ? const Letter(char: '', words: ['']) : _syllableEntries[_entryIndex];
    _entryWord = _currentEntry.words.isNotEmpty ? _currentEntry.words[_random.nextInt(_currentEntry.words.length)] : '';
    _isUppercase = widget.initialIsUppercase;
    _buildOptions();
    // Guardar el Future una sola vez para que no se recree en cada build
    pictogramFuture = _entryWord.isNotEmpty ? _currentEntry.pictogramFile(_entryWord) : Future.value(null);
  }

  List<Letter> _allSyllableEntries() {
    final list = <Letter>[];
    for (final group in syllablesByLetter.values) {
      list.addAll(group);
    }
    return list;
  }

  void _buildOptions() {
    // Construye lista de opciones: silaba correcta + 2 distractores aleatorios
    final List<Letter> pool = List<Letter>.from(_syllableEntries);
    pool.removeWhere((entry) => entry.char == _currentEntry.char);

    final List<Letter> chosen = [_currentEntry];
    while (chosen.length < 3 && pool.isNotEmpty) {
      final idx = _random.nextInt(pool.length);
      final candidate = pool.removeAt(idx);
      if (chosen.any((entry) => entry.char == candidate.char)) continue;
      chosen.add(candidate);
    }

    _options = chosen.toList();
    _options.shuffle(_random);
  }

  Future<void> _onOptionPressed(Letter selected) async {
    if (_locked) return;

    final displaySyllable = _isUppercase ? _currentEntry.char.toUpperCase() : _currentEntry.char.toLowerCase();
    final displayWord = _isUppercase ? _entryWord.toUpperCase() : _entryWord.toLowerCase();

    if (selected.char == _currentEntry.char) {
      // respuesta correcta: bloquear la UI para evitar pulsaciones mientras se procesa
      setState(() => _locked = true);
      try {
        await AudioService.instance.speak('¡Muy bien!');
        await Future.delayed(const Duration(milliseconds: 800));
        await AudioService.instance.speak(displaySyllable); // repetir la silaba
        // avanzar automaticamente despues de una pausa corta
        await Future.delayed(const Duration(milliseconds: 600));
        final hasNext = _entryIndex < _syllableEntries.length - 1;
        if (hasNext) {
          final nextIndex = _entryIndex + 1;
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SelectionSyllableScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
          );
        } else {
          await AudioService.instance.speak('¡Has completado todas las silabas!');
          if (mounted) Navigator.pop(context);
        }
      } finally {
        if (mounted) setState(() => _locked = false);
      }
    } else {
      // incorrecto: solo dar feedback de audio, sin bloquear ni atenuar toda la UI
      final selectedSyllable = _isUppercase ? selected.char.toUpperCase() : selected.char.toLowerCase();
      await AudioService.instance.speak(selectedSyllable);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_syllableEntries.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Selecciona la silaba'),
          backgroundColor: const Color.fromARGB(255, 68, 194, 193),
          elevation: 0,
        ),
        body: const Center(child: Text('No hay silabas definidas')),
      );
    }

    final bool hasPrev = _entryIndex > 0;
    final bool hasNext = _entryIndex < _syllableEntries.length - 1;
    final int prevIndex = _entryIndex - 1;
    final int nextIndex = _entryIndex + 1;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizePictogram = isTablet ? 280.0 : 220.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;
    final displaySyllable = _isUppercase ? _currentEntry.char.toUpperCase() : _currentEntry.char.toLowerCase();
    final displayWord = _isUppercase ? _entryWord.toUpperCase() : _entryWord.toLowerCase();
    // `pictogramFuture` ya esta inicializado en initState

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona la silaba'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        elevation: 0,
      ),
      body: Stack(
        children: [
          const BackgroundAnimation(),

          // boton volumen (instruccion) + Aa
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
                    AudioService.instance.speak('Selecciona la silaba $displaySyllable');
                  },
                ),
              ],
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
                    size: sizePictogram,
                    onPressed: () async {},
                    letters: displayWord,
                  ),
                ),

                // navegacion opcional abajo
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
                            MaterialPageRoute(builder: (_) => SelectionSyllableScreen(index: prevIndex, initialIsUppercase: _isUppercase)),
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
                            MaterialPageRoute(builder: (_) => SelectionSyllableScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // botones de opciones
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: _options.map((opt) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: AbsorbPointer(
                          absorbing: _locked, // bloquea la interaccion cuando true
                          child: Opacity(
                            opacity: _locked ? 0.6 : 1.0, // atenue visualmente cuando bloqueado
                            child: ButtonWord(
                              text: _isUppercase ? opt.char.toUpperCase() : opt.char.toLowerCase(),
                              onPressed: () => _onOptionPressed(opt),
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
