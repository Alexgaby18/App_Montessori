import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/presentation/controllers/speak_word_controller.dart';

class SpeakWordScreen extends StatefulWidget {
  final Word word;
  const SpeakWordScreen({Key? key, required this.word}) : super(key: key);

  @override
  State<SpeakWordScreen> createState() => _SpeakWordScreenState();
}

class _SpeakWordScreenState extends State<SpeakWordScreen> {
  late SpeakWordController _controller;
  late VoidCallback _controllerListener;
  late Future<File?> _pictogramFuture;

  void _onAdvanceTo(int nextIndex) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SpeakWordScreen(word: words[nextIndex])),
    );
  }

  void _onComplete() {
    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _controller = SpeakWordController(word: widget.word, words: words, onAdvance: _onAdvanceTo, onComplete: _onComplete);
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener);
    _controller.init();
    _pictogramFuture = widget.word.pictogramFile();
  }

  @override
  void didUpdateWidget(covariant SpeakWordScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.word.text != widget.word.text) {
      _pictogramFuture = widget.word.pictogramFile();
    }
  }

  void _startListening() => _controller.startListening();

  void _stopListening() => _controller.stopListening();

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use cached future to avoid reloading pictogram on every setState
    final Future<File?> pictogramFuture = _pictogramFuture;

    final int currentIndex = words.indexWhere((w) => w.text == widget.word.text);
    final bool hasPrev = currentIndex > 0;
    final bool hasNext = currentIndex < words.length - 1;
    final int prevIndex = currentIndex - 1;
    final int nextIndex = currentIndex + 1;

    final bool correct = _controller.isLastResultCorrect;
    final bool wrong = _controller.isLastResultWrong;

    return Scaffold(
      appBar: AppBar(
        title: Text('Lee la palabra'),
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
                AudioService.instance.speak('Lee la palabra ${widget.word.text}');
              },
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: ButtonPictogramLetters(
                    pictogramFuture: pictogramFuture,
                    size: 200.0,
                    onPressed: () {
                    },
                    letters: widget.word.text.toUpperCase(),
                  ),
                ),
                const SizedBox(height: 24),
                // navegación opcional abajo
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
                            MaterialPageRoute(builder: (_) => SpeakWordScreen(word: words[prevIndex])),
                          ),
                          icon: const Icon(Icons.arrow_back_ios),
                        )
                      else
                        const SizedBox(width: 48),
                      if (hasNext)
                        IconButton(
                          color: const Color.fromARGB(255, 55, 35, 28),
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => SpeakWordScreen(word: words[nextIndex])),
                          ),
                          icon: const Icon(Icons.arrow_forward_ios),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                // resultado reconocido
                if (_controller.lastResult.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        _controller.lastResult.toUpperCase(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: correct ? Colors.green : (wrong ? Colors.red : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (correct)
                        const Icon(Icons.check_circle, color: Colors.green, size: 48)
                      else if (wrong)
                        const Icon(Icons.cancel, color: Colors.red, size: 48),
                    ],
                  ),

                const SizedBox(height: 28),

                // mic button
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (_controller.listening) {
                        _stopListening();
                      } else {
                        _startListening();
                      }
                    },
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _controller.listening ? const Color.fromARGB(255, 76, 175, 80) : const Color.fromARGB(255, 33, 150, 243),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _controller.listening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
