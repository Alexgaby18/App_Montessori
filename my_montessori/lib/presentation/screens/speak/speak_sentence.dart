import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/presentation/controllers/speak_sentence_controller.dart';

class SpeakSentenceScreen extends StatefulWidget {
  final int index;
  final bool initialIsUppercase;

  const SpeakSentenceScreen({Key? key, required this.index, this.initialIsUppercase = true}) : super(key: key);

  @override
  State<SpeakSentenceScreen> createState() => _SpeakSentenceScreenState();
}

class _SpeakSentenceScreenState extends State<SpeakSentenceScreen> {
  late SpeakSentenceController _controller;
  late VoidCallback _controllerListener;
  bool _isUppercase = true;

  void _onAdvanceTo(int nextIndex) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SpeakSentenceScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
    );
  }

  void _onComplete() {
    if (mounted) Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _isUppercase = widget.initialIsUppercase;

    final currentIndex = _safeIndex(widget.index, sentencePictograms.length);
    final current = sentencePictograms.isEmpty ? null : sentencePictograms[currentIndex];

    _controller = SpeakSentenceController(
      sentence: current ?? SentencePictograms(text: '', tokens: []),
      sentences: sentencePictograms,
      onAdvance: _onAdvanceTo,
      onComplete: _onComplete,
    );
    _controllerListener = () => setState(() {});
    _controller.addListener(_controllerListener);
    _controller.init();
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _controller.dispose();
    super.dispose();
  }

  int _safeIndex(int index, int total) {
    if (total <= 0) return 0;
    return index.clamp(0, total - 1);
  }

  void _startListening() => _controller.startListening();

  void _stopListening() => _controller.stopListening();

  @override
  Widget build(BuildContext context) {
    if (sentencePictograms.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Lee la oracion'),
          backgroundColor: const Color.fromARGB(255, 68, 194, 193),
          elevation: 0,
        ),
        body: const Center(child: Text('No hay oraciones definidas')),
      );
    }

    final total = sentencePictograms.length;
    final currentIndex = _safeIndex(widget.index, total);
    final current = sentencePictograms[currentIndex];
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex < total - 1;
    final prevIndex = currentIndex - 1;
    final nextIndex = currentIndex + 1;

    final shortestSide = MediaQuery.of(context).size.shortestSide;
    final isTablet = shortestSide >= 600;
    final sizePictogram = isTablet ? 220.0 : 140.0;
    final sizeIcon = isTablet ? 48.0 : 24.0;

    final bool correct = _controller.isLastResultCorrect;
    final bool wrong = _controller.isLastResultWrong;

    String displaySentence() => _isUppercase ? current.text.toUpperCase() : current.text.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lee la oracion'),
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
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  iconSize: 44,
                  color: const Color.fromARGB(255, 55, 35, 28),
                  tooltip: 'Reproducir oracion',
                  onPressed: () => AudioService.instance.speak('Lee la oracion ${displaySentence()}'),
                ),
              ],
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 100),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: isTablet ? 60 : 30,
                      runSpacing: isTablet ? 60 : 30,
                      children: current.tokens.map((t) {
                        final displayWord = _isUppercase ? t.token.toUpperCase() : t.token.toLowerCase();
                        return ButtonPictogramLetters(
                          pictogramFuture: t.pictogramFile(),
                          letters: displayWord,
                          onPressed: () async {},
                          size: sizePictogram,
                          isListening: _controller.listening,
                        );
                      }).toList(),
                    ),
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
                            MaterialPageRoute(builder: (_) => SpeakSentenceScreen(index: prevIndex, initialIsUppercase: _isUppercase)),
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
                            MaterialPageRoute(builder: (_) => SpeakSentenceScreen(index: nextIndex, initialIsUppercase: _isUppercase)),
                          ),
                          icon: Icon(Icons.arrow_forward_ios, size: sizeIcon),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),
                if (_controller.lastResult.isNotEmpty)
                  Column(
                    children: [
                      Text(
                        _controller.lastResult.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: correct ? Colors.green : (wrong ? Colors.red : Colors.black),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (correct)
                        Icon(Icons.check_circle, color: Colors.green, size: isTablet ? 64 : 48)
                      else if (wrong)
                        Icon(Icons.cancel, color: Colors.red, size: isTablet ? 64 : 48),
                    ],
                  ),
                const SizedBox(height: 20),
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
                      width: isTablet ? 140 : 96,
                      height: isTablet ? 140 : 96,
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
                          size: isTablet ? 68 : 44,
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
