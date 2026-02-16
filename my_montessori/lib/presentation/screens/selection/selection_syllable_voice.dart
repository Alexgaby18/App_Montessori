import 'dart:math';

import 'package:flutter/material.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';

class SelectionSyllableVoiceScreen extends StatefulWidget {
  final int index;
  final bool initialIsUppercase;

  const SelectionSyllableVoiceScreen({
    Key? key,
    required this.index,
    this.initialIsUppercase = true,
  }) : super(key: key);

  @override
  State<SelectionSyllableVoiceScreen> createState() => _SelectionSyllableVoiceScreenState();
}

class _SelectionSyllableVoiceScreenState extends State<SelectionSyllableVoiceScreen> {
  final _random = Random();
  late final List<Letter> _syllableEntries;
  late final int _entryIndex;
  late final Letter _currentEntry;
  late List<Letter> _options;
  bool _locked = false;
  bool _isUppercase = true;

  @override
  void initState() {
    super.initState();
    _syllableEntries = _allSyllableEntries();
    _entryIndex = _syllableEntries.isEmpty
        ? 0
        : widget.index.clamp(0, _syllableEntries.length - 1);
    _currentEntry = _syllableEntries.isEmpty
        ? const Letter(char: '', words: [''])
        : _syllableEntries[_entryIndex];
    _isUppercase = widget.initialIsUppercase;
    _buildOptions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _playInstruction();
    });
  }

  List<Letter> _allSyllableEntries() {
    final list = <Letter>[];
    for (final group in syllablesByLetter.values) {
      list.addAll(group);
    }
    return list;
  }

  void _buildOptions() {
    final pool = List<Letter>.from(_syllableEntries);
    pool.removeWhere((entry) => entry.char == _currentEntry.char);

    final chosen = <Letter>[_currentEntry];
    while (chosen.length < 12 && pool.isNotEmpty) {
      final idx = _random.nextInt(pool.length);
      chosen.add(pool.removeAt(idx));
    }

    _options = chosen.toList();
    _options.shuffle(_random);
  }

  void _playInstruction() {
    final displaySyllable = _isUppercase
        ? _currentEntry.char.toUpperCase()
        : _currentEntry.char.toLowerCase();
    AudioService.instance.speak('Selecciona la silaba $displaySyllable');
  }

  Future<void> _onOptionPressed(Letter selected) async {
    if (_locked) return;

    if (selected.char == _currentEntry.char) {
      setState(() => _locked = true);
      try {
        await AudioService.instance.speak('Muy bien');
        await Future.delayed(const Duration(milliseconds: 600));
        await AudioService.instance.speak(_isUppercase
            ? _currentEntry.char.toUpperCase()
            : _currentEntry.char.toLowerCase());

        await Future.delayed(const Duration(milliseconds: 600));
        final hasNext = _entryIndex < _syllableEntries.length - 1;
        if (hasNext) {
          final nextIndex = _entryIndex + 1;
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SelectionSyllableVoiceScreen(
                index: nextIndex,
                initialIsUppercase: _isUppercase,
              ),
            ),
          );
        } else {
          await AudioService.instance.speak('Has completado todas las silabas');
          if (mounted) Navigator.pop(context);
        }
      } finally {
        if (mounted) setState(() => _locked = false);
      }
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

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final buttonSize = isTablet ? 100.0 : 80.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona la silaba'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        elevation: 0,
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
                  icon: const Text(
                    'Aa',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 55, 35, 28),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  onPressed: _playInstruction,
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 140),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: AbsorbPointer(
                      absorbing: _locked,
                      child: Opacity(
                        opacity: _locked ? 0.6 : 1.0,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _options.length,
                          itemBuilder: (context, index) {
                            final option = _options[index];
                            final displaySyllable = _isUppercase
                                ? option.char.toUpperCase()
                                : option.char.toLowerCase();
                            return ButtonLetter(
                              letter: displaySyllable,
                              size: buttonSize,
                              onPressed: () => _onOptionPressed(option),
                            );
                          },
                        ),
                      ),
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
