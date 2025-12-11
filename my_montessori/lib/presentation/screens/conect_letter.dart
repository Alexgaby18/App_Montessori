import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_letter.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram_letter.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';

class ConnectLetterScreen extends StatefulWidget {
  const ConnectLetterScreen({Key? key}) : super(key: key);

  @override
  State<ConnectLetterScreen> createState() => _ConnectLetterScreenState();
}

class _ConnectLetterScreenState extends State<ConnectLetterScreen> {
  final _random = Random();
  
  // Cache de futures para evitar recargas
  final Map<int, Future<File?>> _pictogramFuturesCache = {};

  // índices dentro de `words`
  late List<int> _optionsIdx;

  // orden visual (listas de posiciones 0..n-1 que referencian posiciones en _optionsIdx)
  late List<int> _leftOrder;
  late List<int> _rightOrder;

  // keys para calcular posiciones
  final _stackKey = GlobalKey();
  final List<GlobalKey> _leftKeys = [];
  final List<GlobalKey> _rightKeys = [];

  // conexión confirmada por wordIdx -> true
  final Map<int, bool> _connected = {};
  int _completedConnections = 0;

  // dragging state: si el usuario está arrastrando desde leftPos (posición visual en columna izquierda)
  int? _draggingLeftPos;
  Offset? _draggingLocalOffset; // offset local relativo al stack

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Precargar todos los pictogramas al iniciar
    _preloadAllPictograms();
  }

  void _initializeGame() {
    final n = words.length;
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
    for (int i = 0; i < _optionsIdx.length; i++) {
      _leftKeys.add(GlobalKey());
      _rightKeys.add(GlobalKey());
      _connected[_optionsIdx[i]] = false;
    }
    _completedConnections = 0;
  }

  // Método para precargar todos los pictogramas
  void _preloadAllPictograms() {
    for (final word in words) {
      if (!_pictogramFuturesCache.containsKey(words.indexOf(word))) {
        _pictogramFuturesCache[words.indexOf(word)] = word.pictogramFile();
      }
    }
  }

  // Método para obtener el Future del pictograma (usando cache)
  Future<File?> _getCachedPictogramFuture(int wordIdx) {
    // Si ya tenemos el future cachead, usarlo
    if (_pictogramFuturesCache.containsKey(wordIdx)) {
      return _pictogramFuturesCache[wordIdx]!;
    }
    
    // Si no, crearlo y cachearlo
    final word = words[wordIdx];
    final future = word.pictogramFile();
    _pictogramFuturesCache[wordIdx] = future;
    return future;
  }

  // obtiene centro de widget por GlobalKey relativo al stack
  Offset? _centerOfKey(GlobalKey key) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || box == null) return null;
    final topLeftGlobal = box.localToGlobal(Offset.zero);
    final topLeftLocal = stackBox.globalToLocal(topLeftGlobal);
    return topLeftLocal + box.size.center(Offset.zero);
  }

  // maneja aceptación (drop) en pictograma: data es optPos (posición visual 0..n-1 que refiere a _optionsIdx)
  Future<void> _onAccept(int optPos) async {
    final wordIdx = _optionsIdx[optPos];
    
    // Verificar si ya está conectado
    if (_connected[wordIdx] == true) return;
    
    setState(() {
      _connected[wordIdx] = true;
      _completedConnections++;
    });

    // hablar letra (primera letra) y luego la palabra
    final wordText = words[wordIdx].text;
    final letter = wordText.substring(0, 1).toUpperCase();
    await AudioService.instance.speakLetter(letter);
    await Future.delayed(const Duration(milliseconds: 200));
    await AudioService.instance.speak(wordText);

    // Verificar si se completaron todas las conexiones
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
    if (words.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Relaciona letras y pictogramas')),
        body: const Center(child: Text('No hay palabras definidas')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Conecta las letras'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        elevation: 0,
      ),
      body: Stack(
        key: _stackKey, // Añadido key al Stack principal
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
                AudioService.instance.speak('Une las letras con los pictogramas correspondientes');
              },
            ),
          ),
          SafeArea(
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              final leftX = width * 0.12;
              final rightX = width * 0.68;

              return Stack(
                children: [
                  // painter: líneas fijas + línea dinámica al arrastrar
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

                  // columna izquierda: letras (Draggable)
                  Positioned(
                    left: leftX - 10,
                    top: 120,
                    bottom: 120,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_leftOrder.length, (i) {
                        final optPos = _leftOrder[i];
                        final wordIdx = _optionsIdx[optPos];
                        final wText = words[wordIdx].text;
                        final letter = wText.substring(0, 1).toUpperCase();

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
                                  width: 64, 
                                  height: 64, 
                                  child: ButtonLetter(
                                    letter: letter, 
                                    onPressed: () {}, 
                                    size: 64
                                  )
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.25, 
                              child: ButtonLetter(
                                letter: letter, 
                                onPressed: () {}, 
                                size: 64
                              )
                            ),
                            child: GestureDetector(
                              onTap: () async {
                                await AudioService.instance.speakLetter(letter);
                                await Future.delayed(const Duration(milliseconds: 150));
                                await AudioService.instance.speak(wText);
                              },
                              child: ButtonLetter(letter: letter, onPressed: () {}, size: 100),
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
                        final wordIdx = _optionsIdx[optPos];
                        final wordObj = words[wordIdx];
                        
                        // Usar el método cacheado para obtener el future
                        final pictogramFuture = _getCachedPictogramFuture(wordIdx);

                        return Container(
                          key: _rightKeys[i],
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: DragTarget<int>(
                            onWillAccept: (data) => true,
                            onAccept: (dataOptPos) async {
                              if (dataOptPos == optPos) {
                                await _onAccept(optPos);
                              } else {
                                final drWordIdx = _optionsIdx[dataOptPos];
                                await AudioService.instance.speak(words[drWordIdx].text);
                              }
                              setState(() {
                                _draggingLeftPos = null;
                                _draggingLocalOffset = null;
                              });
                            },
                            builder: (context, candidateData, rejectedData) {
                              final isConnected = _connected[wordIdx] ?? false;
                              return Opacity(
                                opacity: isConnected ? 0.9 : 1.0,
                                child: ButtonPictogramLetters(
                                  pictogramFuture: pictogramFuture,
                                  size: 100.0,
                                  letters: wordObj.text.toUpperCase(),
                                  onPressed: () async {
                                    await AudioService.instance.speak(wordObj.text);
                                  },
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
        ],
      ),
    );
  }
}

/// Painter que dibuja líneas fijas entre pares y línea dinámica durante arrastre.
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

  // simple deep-equality para Map<int, bool>
  bool _mapEquals(Map<int, bool> a, Map<int, bool> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // paleta de colores para líneas (se repite si hay más)
    final palette = <Color>[
      const Color(0xFFEF5350), // rojo
      const Color(0xFF42A5F5), // azul
      const Color(0xFF66BB6A), // verde
      const Color(0xFFFFA726), // naranja
      const Color(0xFFAB47BC), // morado
      const Color(0xFF26C6DA), // cian
    ];

    final basePaint = Paint()
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // dibujar líneas fijas (con color por pareja)
    for (int leftPos = 0; leftPos < leftOrder.length; leftPos++) {
      final optPos = leftOrder[leftPos];
      final rightPos = rightOrder.indexOf(optPos);
      if (rightPos == -1) continue;

      final leftKey = leftKeys[leftPos];
      final rightKey = rightKeys[rightPos];

      final leftCenter = _centerOf(leftKey);
      final rightCenter = _centerOf(rightKey);
      if (leftCenter == null || rightCenter == null) continue;

      final optionWordIdx = optionsIdx[optPos];
      final isConnected = connected[optionWordIdx] ?? false;

      final color = palette[optPos % palette.length];
      basePaint.color = isConnected ? color : color.withOpacity(0);

      final cp1 = Offset(leftCenter.dx + 40, leftCenter.dy);
      final cp2 = Offset(rightCenter.dx - 40, rightCenter.dy);
      final path = Path()
        ..moveTo(leftCenter.dx, leftCenter.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, rightCenter.dx, rightCenter.dy);

      canvas.drawPath(path, basePaint);
    }

    // dibujar línea dinámica si se está arrastrando
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
    // repintar si cambió el dragging, o el contenido del mapa connected,
    // o si cambiaron las órdenes (por seguridad comparamos por contenido).
    if (oldDelegate.draggingLeftPos != draggingLeftPos) return true;
    if (oldDelegate.draggingLocalOffset != draggingLocalOffset) return true;
    if (!_mapEquals(oldDelegate.connected, connected)) return true;

    // comparar leftOrder / rightOrder por contenido
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