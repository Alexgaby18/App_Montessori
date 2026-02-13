import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class ConnectSyllableScreen extends StatefulWidget {
  const ConnectSyllableScreen({Key? key}) : super(key: key);

  @override
  State<ConnectSyllableScreen> createState() => _ConnectSyllableScreenState();
}

class _ConnectSyllableScreenState extends State<ConnectSyllableScreen> {
  final _random = Random();
  bool _isUppercase = true;

  late final List<Letter> _syllableEntries;

  // Cache de futures para evitar recargas
  final Map<int, Future<File?>> _pictogramFuturesCache = {};
  final Map<int, String> _entryWord = {};

  // indices dentro de `_syllableEntries`
  late List<int> _optionsIdx;

  // orden visual (listas de posiciones 0..n-1 que referencian posiciones en _optionsIdx)
  late List<int> _leftOrder;
  late List<int> _rightOrder;

  // keys para calcular posiciones
  final _stackKey = GlobalKey();
  final List<GlobalKey> _leftKeys = [];
  final List<GlobalKey> _rightKeys = [];

  // conexion confirmada por entryIdx -> true
  final Map<int, bool> _connected = {};
  int _completedConnections = 0;

  // dragging state: si el usuario esta arrastrando desde leftPos
  int? _draggingLeftPos;
  Offset? _draggingLocalOffset; // offset local relativo al stack

  @override
  void initState() {
    super.initState();
    _syllableEntries = _allSyllableEntries();
    _initializeGame();
  }

  List<Letter> _allSyllableEntries() {
    final list = <Letter>[];
    for (final group in syllablesByLetter.values) {
      list.addAll(group);
    }
    return list;
  }

  void _initializeGame() {
    final n = _syllableEntries.length;
    final Set<int> picked = {};
    while (picked.length < 3 && picked.length < n) {
      picked.add(_random.nextInt(n));
    }
    _optionsIdx = picked.toList();

    _leftOrder = List<int>.generate(_optionsIdx.length, (i) => i);
    _rightOrder = List<int>.generate(_optionsIdx.length, (i) => i);
    _leftOrder.shuffle(_random);
    _rightOrder.shuffle(_random);

    _leftKeys.clear();
    _rightKeys.clear();
    _connected.clear();
    _entryWord.clear();
    _pictogramFuturesCache.clear();

    for (int i = 0; i < _optionsIdx.length; i++) {
      final entryIdx = _optionsIdx[i];
      final entry = _syllableEntries[entryIdx];
      final words = entry.words;
      final chosen = words.isNotEmpty ? words[_random.nextInt(words.length)] : '';

      _leftKeys.add(GlobalKey());
      _rightKeys.add(GlobalKey());
      _connected[entryIdx] = false;
      _entryWord[entryIdx] = chosen;

      if (chosen.isNotEmpty) {
        _pictogramFuturesCache[entryIdx] = entry.pictogramFile(chosen);
      }
    }

    _completedConnections = 0;
  }

  String _getEntryWord(int entryIdx) {
    final entry = _syllableEntries[entryIdx];
    if (_entryWord.containsKey(entryIdx) && _entryWord[entryIdx]!.isNotEmpty) {
      return _entryWord[entryIdx]!;
    }
    return entry.words.isNotEmpty ? entry.words.first : '';
  }

  Future<File?> _getCachedPictogramFuture(int entryIdx) {
    if (_pictogramFuturesCache.containsKey(entryIdx)) {
      return _pictogramFuturesCache[entryIdx]!;
    }

    final entry = _syllableEntries[entryIdx];
    final word = _getEntryWord(entryIdx);
    if (word.isEmpty) return Future.value(null);

    final future = entry.pictogramFile(word);
    _pictogramFuturesCache[entryIdx] = future;
    return future;
  }

  // maneja aceptacion (drop) en pictograma: data es optPos
  Future<void> _onAccept(int optPos) async {
    final entryIdx = _optionsIdx[optPos];

    // Verificar si ya esta conectado
    if (_connected[entryIdx] == true) return;

    setState(() {
      _connected[entryIdx] = true;
      _completedConnections++;
    });

    final entry = _syllableEntries[entryIdx];
    final displaySyllable = _isUppercase ? entry.char.toUpperCase() : entry.char.toLowerCase();
    final wordText = _getEntryWord(entryIdx);

    await AudioService.instance.speak(displaySyllable);
    await Future.delayed(const Duration(milliseconds: 200));
    if (wordText.isNotEmpty) {
      await AudioService.instance.speak(wordText);
    }

    if (_completedConnections >= _optionsIdx.length) {
      await Future.delayed(const Duration(seconds: 1));
      _loadNewWords();
    }
  }

  void _loadNewWords() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final sizePictogram = isTablet ? 140.0 : 100.0;

    if (_syllableEntries.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relaciona silabas y pictogramas')),
        body: const Center(child: Text('No hay silabas definidas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conecta silabas'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        elevation: 0,
      ),
      body: Stack(
        key: _stackKey,
        children: [
          const BackgroundAnimation(),

          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final leftX = width * 0.12;
              final rightX = width * 0.68;

              return Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ConnectLinesPainter(
                        stackKey: _stackKey,
                        leftKeys: _leftKeys,
                        rightKeys: _rightKeys,
                        leftOrder: _leftOrder,
                        rightOrder: _rightOrder,
                        optionsIdx: _optionsIdx,
                        connected: _connected,
                        draggingLeftPos: _draggingLeftPos,
                        draggingLocalOffset: _draggingLocalOffset,
                      ),
                    ),
                  ),

                  // columna izquierda: silabas (Draggable)
                  Positioned(
                    left: leftX - 10,
                    top: 120,
                    bottom: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_leftOrder.length, (i) {
                        final optPos = _leftOrder[i];
                        final entryIdx = _optionsIdx[optPos];
                        final entry = _syllableEntries[entryIdx];
                        final displaySyllable = _isUppercase ? entry.char.toUpperCase() : entry.char.toLowerCase();
                        final wordText = _getEntryWord(entryIdx);

                        return Container(
                          key: _leftKeys[i],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Draggable<int>(
                            data: optPos,
                            onDragStarted: () {
                              setState(() {
                                _draggingLeftPos = i;
                              });
                            },
                            onDragEnd: (_) {
                              setState(() {
                                _draggingLeftPos = null;
                                _draggingLocalOffset = null;
                              });
                            },
                            onDragUpdate: (details) {
                              final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
                              if (stackBox != null) {
                                final local = stackBox.globalToLocal(details.globalPosition);
                                setState(() {
                                  _draggingLocalOffset = local;
                                });
                              }
                            },
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.95,
                                child: SizedBox(
                                  width: sizePictogram,
                                  height: sizePictogram,
                                  child: ButtonLetter(
                                    letter: displaySyllable,
                                    onPressed: () {},
                                    size: sizePictogram,
                                  ),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25,
                              child: ButtonLetter(
                                letter: displaySyllable,
                                onPressed: () {},
                                size: sizePictogram,
                              ),
                            ),
                            child: ButtonLetter(
                              letter: displaySyllable,
                              onPressed: () async {
                                if (wordText.isNotEmpty) {
                                  await Future.delayed(const Duration(milliseconds: 150));
                                  await AudioService.instance.speak(wordText);
                                }
                              },
                              size: sizePictogram,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // columna derecha: pictogramas (DragTarget)
                  Positioned(
                    left: rightX - 10,
                    top: 120,
                    bottom: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_rightOrder.length, (i) {
                        final optPos = _rightOrder[i];
                        final entryIdx = _optionsIdx[optPos];
                        final entry = _syllableEntries[entryIdx];
                        final wordText = _getEntryWord(entryIdx);
                        final displayWord = _isUppercase ? wordText.toUpperCase() : wordText.toLowerCase();
                        final pictogramFuture = _getCachedPictogramFuture(entryIdx);

                        return Container(
                          key: _rightKeys[i],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: DragTarget<int>(
                            onWillAccept: (data) => true,
                            onAccept: (dataOptPos) async {
                              if (dataOptPos == optPos) {
                                await _onAccept(optPos);
                              } else {
                                final drEntryIdx = _optionsIdx[dataOptPos];
                                final wrongWord = _getEntryWord(drEntryIdx);
                                if (wrongWord.isNotEmpty) {
                                  await AudioService.instance.speak(wrongWord);
                                }
                              }
                              setState(() {
                                _draggingLeftPos = null;
                                _draggingLocalOffset = null;
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isConnected = _connected[entryIdx] ?? false;
                              return Opacity(
                                opacity: isConnected ? 0.9 : 1.0,
                                child: ButtonPictogramLetters(
                                  pictogramFuture: pictogramFuture,
                                  size: sizePictogram,
                                  letters: displayWord,
                                  onPressed: () {},
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            }),
          ),

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
                    AudioService.instance.speak('Une las silabas con los pictogramas');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter que dibuja lineas fijas entre pares y linea dinamica durante arrastre.
class _ConnectLinesPainter extends CustomPainter {
  final GlobalKey stackKey;
  final List<GlobalKey> leftKeys;
  final List<GlobalKey> rightKeys;
  final List<int> leftOrder;
  final List<int> rightOrder;
  final List<int> optionsIdx;
  final Map<int, bool> connected;

  // dragging state
  final int? draggingLeftPos;
  final Offset? draggingLocalOffset;

  _ConnectLinesPainter({
    required this.stackKey,
    required this.leftKeys,
    required this.rightKeys,
    required this.leftOrder,
    required this.rightOrder,
    required this.optionsIdx,
    required this.connected,
    required this.draggingLeftPos,
    required this.draggingLocalOffset,
  });

  Offset? _centerOf(GlobalKey key) {
    final stackBox = stackKey.currentContext?.findRenderObject() as RenderBox?;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || box == null) return null;
    final topLeftGlobal = box.localToGlobal(Offset.zero);
    final topLeftLocal = stackBox.globalToLocal(topLeftGlobal);
    return topLeftLocal + box.size.center(Offset.zero);
  }

  bool _mapEquals(Map<int, bool> a, Map<int, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final palette = <Color>[
      const Color(0xFFEF5350),
      const Color(0xFF42A5F5),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFFAB47BC),
      const Color(0xFF26C6DA),
    ];

    final basePaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int leftPos = 0; leftPos < leftOrder.length; leftPos++) {
      final optPos = leftOrder[leftPos];
      final rightPos = rightOrder.indexOf(optPos);
      if (rightPos == -1) continue;

      final leftKey = leftKeys[leftPos];
      final rightKey = rightKeys[rightPos];

      final leftCenter = _centerOf(leftKey);
      final rightCenter = _centerOf(rightKey);
      if (leftCenter == null || rightCenter == null) continue;

      final optionEntryIdx = optionsIdx[optPos];
      final isConnected = connected[optionEntryIdx] ?? false;

      final color = palette[optPos % palette.length];
      basePaint.color = isConnected ? color : color.withOpacity(0);

      final cp1 = Offset(leftCenter.dx + 40, leftCenter.dy);
      final cp2 = Offset(rightCenter.dx - 40, rightCenter.dy);
      final path = Path()
        ..moveTo(leftCenter.dx, leftCenter.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, rightCenter.dx, rightCenter.dy);

      canvas.drawPath(path, basePaint);
    }

    if (draggingLeftPos != null && draggingLocalOffset != null) {
      final leftKey = leftKeys[draggingLeftPos!];
      final leftCenter = _centerOf(leftKey);
      final dragPoint = draggingLocalOffset!;
      if (leftCenter != null) {
        final optPos = leftOrder[draggingLeftPos!];
        final color = palette[optPos % palette.length];

        final dynamicPaint = Paint()
          ..strokeWidth = 6
          ..style = PaintingStyle.stroke
          ..color = color.withOpacity(0.95)
          ..strokeCap = StrokeCap.round;

        final cp1 = Offset(leftCenter.dx + 40, leftCenter.dy);
        final cp2 = Offset(dragPoint.dx - 40, dragPoint.dy);
        final path = Path()
          ..moveTo(leftCenter.dx, leftCenter.dy)
          ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, dragPoint.dx, dragPoint.dy);

        canvas.drawPath(path, dynamicPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConnectLinesPainter oldDelegate) {
    if (oldDelegate.draggingLeftPos != draggingLeftPos) return true;
    if (oldDelegate.draggingLocalOffset != draggingLocalOffset) return true;
    if (!_mapEquals(oldDelegate.connected, connected)) return true;

    if (oldDelegate.leftOrder.length != leftOrder.length) return true;
    for (int i = 0; i < leftOrder.length; i++) {
      if (oldDelegate.leftOrder[i] != leftOrder[i]) return true;
    }
    if (oldDelegate.rightOrder.length != rightOrder.length) return true;
    for (int i = 0; i < rightOrder.length; i++) {
      if (oldDelegate.rightOrder[i] != rightOrder[i]) return true;
    }

    return false;
  }
}
