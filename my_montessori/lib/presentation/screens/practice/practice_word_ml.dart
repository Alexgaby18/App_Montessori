import 'dart:math';

import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/services/ml_service.dart';
import 'package:my_montessori/presentation/widgets/ink_painter.dart';

class PracticeWordScreenML extends StatefulWidget {
  final bool embedded;
  final int initialIndex;
  final bool initialIsUppercase;
  final ValueChanged<int>? onIndexChanged;

  const PracticeWordScreenML({
    Key? key,
    this.embedded = false,
    this.initialIndex = 0,
    this.initialIsUppercase = true,
    this.onIndexChanged,
  }) : super(key: key);

  @override
  State<PracticeWordScreenML> createState() => _PracticeWordScreenMLState();
}

class _PracticeWordScreenMLState extends State<PracticeWordScreenML> {
  final MLService _mlService = MLService();
  final GlobalKey _canvasKey = GlobalKey();

  int _index = 0;
  bool _isUppercase = true;
  bool _checking = false;
  bool _isModelLoaded = false;

  List<Offset> _currentPoints = [];
  List<List<Offset>> _strokes = [];

  DateTime? _currentStrokeStart;
  List<int> _currentStrokeTimes = [];
  final List<List<int>> _strokesTimes = [];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, words.isNotEmpty ? words.length - 1 : 0);
    _isUppercase = widget.initialIsUppercase;
    _initializeModel();
    if (words.isEmpty) {
      _index = -1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _announceCurrentWord();
    });
  }

  @override
  void didUpdateWidget(covariant PracticeWordScreenML oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsUppercase != widget.initialIsUppercase) {
      setState(() => _isUppercase = widget.initialIsUppercase);
    }
    if (oldWidget.initialIndex != widget.initialIndex) {
      setState(() => _index = widget.initialIndex.clamp(0, words.isNotEmpty ? words.length - 1 : 0));
    }
  }

  Future<void> _initializeModel() async {
    try {
      await _mlService.initializeModel('es');
      if (!mounted) return;
      setState(() => _isModelLoaded = _mlService.isModelLoaded);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isModelLoaded = false);
      _speakSafe('Modelo no disponible, intenta de nuevo');
    }
  }

  @override
  void dispose() {
    _mlService.close();
    super.dispose();
  }

  void _announceCurrentWord() {
    if (_index < 0 || _index >= words.length) return;
    final word = _displayWord(words[_index].text);
    try {
      AudioService.instance.speak('Practica escribiendo la palabra $word');
    } catch (_) {}
  }

  String _displayWord(String text) => _isUppercase ? text.toUpperCase() : text.toLowerCase();

  void _startStroke(Offset p) {
    setState(() {
      _currentPoints = [p];
      _currentStrokeStart = DateTime.now();
      _currentStrokeTimes = [0];
      _strokes.add(_currentPoints);
      _strokesTimes.add(_currentStrokeTimes);
    });
  }

  void _addPoint(Offset p) {
    final now = DateTime.now();
    final t = _currentStrokeStart != null ? now.difference(_currentStrokeStart!).inMilliseconds : 0;
    _currentPoints.add(p);
    _currentStrokeTimes.add(t);
    setState(() {});
  }

  void _endStroke() {
    setState(() {
      _currentPoints = [];
      _currentStrokeStart = null;
      _currentStrokeTimes = [];
    });
  }

  void _clearDrawing() {
    setState(() {
      _strokes = [];
      _strokesTimes.clear();
      _currentPoints = [];
      _currentStrokeTimes = [];
      _currentStrokeStart = null;
    });
  }

  Future<void> _onCheck() async {
    if (_index < 0 || _strokes.isEmpty) return;

    setState(() => _checking = true);

    final targetWord = words[_index].text;
    final targetNorm = _normalizeWord(targetWord);
    bool passed = false;
    String? recognizedText;

    try {
      if (_isModelLoaded) {
        final candidates = await _recognizeCandidates();
        if (candidates.isNotEmpty) {
          recognizedText = candidates.first.text;
        }

        for (final c in candidates) {
          final norm = _normalizeWord(c.text);
          if (norm == targetNorm) {
            passed = true;
            break;
          }
        }
      }
    } catch (_) {
      passed = false;
    }

    if (passed) {
      final nextIndex = (_index + 1) % words.length;
      await _speakSafe('¡Excelente! Has escrito $targetWord correctamente');
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _index = nextIndex;
        _strokes = [];
      });
      widget.onIndexChanged?.call(_index);
      await Future.delayed(const Duration(milliseconds: 400));
      _announceCurrentWord();
    } else {
      final feedback = recognizedText != null && recognizedText.isNotEmpty
          ? 'Has escrito "$recognizedText". Intenta escribir "$targetWord"'
          : 'Intenta escribir $targetWord';
      await _speakSafe(feedback);
    }

    if (mounted) {
      setState(() => _checking = false);
    }
  }

  Future<List<RecognitionCandidate>> _recognizeCandidates() async {
    final ink = _buildInk(normalize: true, scaleTo: 256);
    return _mlService.recognizeInk(ink);
  }

  Ink _buildInk({required bool normalize, int scaleTo = 256}) {
    final allPts = <Offset>[];
    for (final s in _strokes) {
      allPts.addAll(s);
    }

    double minX = double.infinity, minY = double.infinity, maxX = -double.infinity, maxY = -double.infinity;
    if (allPts.isNotEmpty) {
      for (final p in allPts) {
        if (p.dx < minX) minX = p.dx;
        if (p.dy < minY) minY = p.dy;
        if (p.dx > maxX) maxX = p.dx;
        if (p.dy > maxY) maxY = p.dy;
      }
    } else {
      minX = minY = 0;
      maxX = maxY = 1;
    }

    final w = maxX - minX;
    final h = maxY - minY;
    final size = (w > h) ? w : h;
    final sx = (size == 0) ? 1.0 : (scaleTo / size);
    final sy = sx;

    final ink = Ink();
    for (int si = 0; si < _strokes.length; si++) {
      final stroke = _strokes[si];
      final times = (_strokesTimes.length > si) ? _strokesTimes[si] : List<int>.filled(stroke.length, 0);
      if (stroke.length < 2) continue;
      final strokePoints = <StrokePoint>[];
      for (int i = 0; i < stroke.length; i++) {
        final p = stroke[i];
        double x = p.dx;
        double y = p.dy;
        if (normalize) {
          x = (p.dx - minX) * sx;
          y = (p.dy - minY) * sy;
        }
        final t = (i < times.length) ? times[i] : 0;
        strokePoints.add(StrokePoint(x: x, y: y, t: t));
      }
      final st = Stroke();
      st.points = strokePoints;
      ink.strokes.add(st);
    }
    return ink;
  }

  String _normalizeWord(String input) {
    var out = input.trim().toUpperCase();
    final map = {
      'Á': 'A', 'À': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ñ': 'N', 'Ç': 'C',
    };
    map.forEach((k, v) => out = out.replaceAll(k, v));
    out = out.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return out;
  }

  Future<void> _speakSafe(String text) async {
    try {
      await AudioService.instance.speak(text);
    } catch (_) {}
  }

  Widget _buildCanvas(double width, double height) {
    final targetWord = _index >= 0 ? _displayWord(words[_index].text) : '?';

    return GestureDetector(
      onPanStart: (details) {
        final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          _startStroke(box.globalToLocal(details.globalPosition));
        }
      },
      onPanUpdate: (details) {
        final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          _addPoint(box.globalToLocal(details.globalPosition));
        }
      },
      onPanEnd: (_) => _endStroke(),
      child: Container(
        key: _canvasKey,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    targetWord,
                    style: TextStyle(
                      fontSize: height * 0.90,
                      letterSpacing: 25.0,
                      color: Colors.grey.withOpacity(0.15),
                      fontWeight: FontWeight.w300,
                      fontFamily: 'DancingScript',
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: InkPainter(strokes: _strokes),
              ),
            ),
            if (!_isModelLoaded)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Cargando modelo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_index < 0) {
      return const Center(child: Text('No hay palabras definidas'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasHeight = min(constraints.maxHeight * 0.90, 450.0);
                final canvasWidth = constraints.maxWidth;
                return Center(
                  child: SizedBox(
                    width: canvasWidth,
                    height: canvasHeight,
                    child: _buildCanvas(canvasWidth, canvasHeight),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _clearDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _checking || _strokes.isEmpty ? null : _onCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 194, 193),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline,
                          size: 28,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) {
      return _buildContent();
    }

    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practicar palabras')),
        body: const Center(child: Text('No hay palabras definidas')),
      );
    }

    final currentWord = _displayWord(words[_index].text);

    return Scaffold(
      appBar: AppBar(
        title: Text('Practicar palabra $currentWord'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        actions: [
          IconButton(
            iconSize: 44,
            color: const Color.fromARGB(255, 55, 35, 28),
            tooltip: _isUppercase ? 'Cambiar a minúsculas' : 'Cambiar a mayúsculas',
            onPressed: () => setState(() => _isUppercase = !_isUppercase),
            icon: const Text(
              'Aa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 55, 35, 28)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _announceCurrentWord,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}
