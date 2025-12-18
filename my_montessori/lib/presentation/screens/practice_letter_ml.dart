import 'dart:math';
import 'package:flutter/material.dart' hide Ink;
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/services/ml_service.dart';
import 'package:my_montessori/core/utils/drawing_utils.dart';
import 'package:my_montessori/presentation/widgets/ink_painter.dart';

class PracticeLetterScreenML extends StatefulWidget {
  final bool embedded;
  final int initialIndex; // nuevo índice inicial
  final ValueChanged<int>? onIndexChanged;
  const PracticeLetterScreenML({Key? key, this.embedded = false, this.initialIndex = 0, this.onIndexChanged}) : super(key: key);
  @override
  State<PracticeLetterScreenML> createState() => _PracticeLetterScreenMLState();
}

class _PracticeLetterScreenMLState extends State<PracticeLetterScreenML> {
  int _index = 0;
  List<Offset> _currentPoints = [];
  List<List<Offset>> _strokes = [];
  bool _checking = false;
  bool _isModelLoaded = false;
  DigitalInkRecognizer? _recognizer;
  
  // Para el modelo de español
  static const String _modelLanguage = 'es';
  
  // Umbral de confianza para aceptar la letra
  static const double _confidenceThreshold = 0.7;

  // key para referenciar el RenderBox del canvas y convertir coordenadas
  final GlobalKey _canvasKey = GlobalKey();

  // para timestamps
  DateTime? _currentStrokeStart;
  List<int> _currentStrokeTimes = []; // ms desde _currentStrokeStart por cada punto
  final List<List<int>> _strokesTimes = []; // tiempos por cada stroke

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, letters.isNotEmpty ? letters.length - 1 : 0);
    _initializeModel();
    if (letters.isEmpty) {
      _index = -1;
    }
    // Anunciar la letra al abrir la pantalla (embedded o no)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_index >= 0 && _index < letters.length) {
        try {
          AudioService.instance.speakLetter(letters[_index].char.toUpperCase());
        } catch (_) {}
      }
    });
  }

  Future<void> _initializeModel() async {
    try {
      // 1. Código del modelo (español)
      const languageCode = 'es'; // BCP-47 Code
      
      // 2. Crear el reconocedor (API CORRECTA según documentación)
      _recognizer = DigitalInkRecognizer(languageCode: languageCode);
      
      // 3. Crear el gestor de modelos
      final modelManager = DigitalInkRecognizerModelManager();
      
      // 4. Verificar si el modelo ya está descargado
      final bool isDownloaded = await modelManager.isModelDownloaded(languageCode);
      
      if (!isDownloaded) {
        // Descargar el modelo si no está disponible
        print('📥 Descargando modelo de español...');
        await modelManager.downloadModel(languageCode);
      }
      
      setState(() {
        _isModelLoaded = true;
      });
      
      print('✅ Modelo de reconocimiento de tinta cargado correctamente');
      
    } catch (e, stackTrace) {
      print('❌ Error inicializando modelo: $e');
      print('Stack trace: $stackTrace');
      
      // Fallback a comparación local
      _speakSafe('Modelo no disponible, usando verificación básica');
    }
  }

  @override
  void dispose() {
    _recognizer?.close();
    super.dispose();
  }

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
    // añadimos punto + tiempo sin forzar setState cada vez (throttle opcional)
    _currentPoints.add(p);
    _currentStrokeTimes.add(t);
    // si quieres reducir repaints, llama setState menos frecuentemente,
    // pero aquí mantenemos la actualización por simplicidad:
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

    final currentLetter = letters[_index].char.toUpperCase();
    bool passed = false;
    String? recognizedText;

    try {
      if (_isModelLoaded && _recognizer != null) {
        // Usar Google ML Kit para reconocimiento
        passed = await _checkWithGoogleML(currentLetter);
      } else {
        // Fallback a comparación local
        passed = await _checkWithLocalComparison(currentLetter);
      }
    } catch (e) {
      print('Error en verificación: $e');
      // Usar método local como último recurso
      passed = await _checkWithLocalComparison(currentLetter);
    }

    if (passed) {
      // Felicitación y luego anunciar la siguiente letra sin cortar audio
      final nextIndex = (_index + 1) % letters.length;
      await _speakSafe('¡Excelente! Has escrito la letra $currentLetter correctamente');
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _index = nextIndex;
        _strokes = [];
      });

      // Notify parent (so AppBar title updates when embedded)
      try {
        widget.onIndexChanged?.call(_index);
      } catch (_) {}

      // Give the UI a short moment to update before speaking the next letter
      await Future.delayed(const Duration(milliseconds: 400));

      try {
        await AudioService.instance.speakLetter(letters[_index].char.toUpperCase());
      } catch (_) {}
    } else {
      final feedback = recognizedText != null
          ? 'Has escrito "${recognizedText}". Intenta escribir "${currentLetter}"'
          : 'Intenta de nuevo la letra $currentLetter';
      await _speakSafe(feedback);
    }

    setState(() => _checking = false);
  }

    // Reconocimiento con Google ML Kit (función)
    Future<bool> _checkWithGoogleML(String targetLetter) async {
    // helper para crear Ink
    Ink _buildInk({required bool normalize, required bool epochTimes, int scaleTo = 256}) {
      final allPts = <Offset>[];
      for (final s in _strokes) allPts.addAll(s);
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
            x = ((p.dx - minX) * sx);
            y = ((p.dy - minY) * sy);
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

    try {
      final variants = [
        {'name': 'norm-epoch', 'normalize': true, 'epoch': true},
        {'name': 'norm-relative', 'normalize': true, 'epoch': false},
        {'name': 'raw-relative', 'normalize': false, 'epoch': false},
      ];

      final tgt = _normalize(targetLetter);

      for (final v in variants) {
        final name = v['name'] as String;
        final normalize = v['normalize'] as bool;
        final epoch = v['epoch'] as bool;

        final ink = _buildInk(normalize: normalize, epochTimes: epoch, scaleTo: 256);
        print('MLDBG: trying variant=$name ...');
        final candidates = await _recognizer!.recognize(ink);

        if (candidates.isEmpty) {
          print('MLDBG: variant=$name -> no candidates');
          continue;
        }

        // Log candidatos (texto y score, aunque score puede ser 0.0)
        for (int i = 0; i < candidates.length; i++) {
          final c = candidates[i];
          print('MLDBG: variant=$name candidate[$i] text="${c.text}" score=${c.score}');
        }

        // Comprueba candidatos basados en texto normalizado
        for (final c in candidates) {
          final norm = _normalize(c.text);
          // 1) coincidencia exacta
          if (norm == tgt) {
            print('MLDBG: ACCEPT variant=$name exact text match: "${c.text}"');
            return true;
          }
          // 2) primera letra coincide
          if (norm.isNotEmpty && norm[0] == tgt[0]) {
            print('MLDBG: ACCEPT variant=$name first-letter match: "${c.text}"');
            return true;
          }
          // 3) contiene la letra objetivo en cualquier posición
          if (norm.contains(tgt)) {
            print('MLDBG: ACCEPT variant=$name contains-target: "${c.text}"');
            return true;
          }
        }

        print('MLDBG: variant=$name -> not accepted by text rules, trying next');
      }

      print('MLDBG: no variant accepted the input by text rules');
      return false;
    } catch (e, st) {
      print('MLDBG: exception in _checkWithGoogleML: $e\n$st');
      return false;
    }
  }

  Future<bool> _checkWithLocalComparison(String targetLetter) async {
    // Método de fallback usando comparación de forma
    final template = _letterTemplatePoints(targetLetter);
    final drawn = _mergeAndNormalizeStrokes(_strokes, template.length);
    final score = DrawingUtils.dtwDistance(template, drawn);
    return score >= 0.62;
  }

  bool _areLettersSimilar(String recognized, String target) {
    // Lista de letras que pueden confundirse
    final similarPairs = {
      'I': ['L', '1'],
      'L': ['I', '1'],
      '1': ['I', 'L'],
      'O': ['0', 'Q'],
      'Q': ['O', '0'],
      '0': ['O', 'Q'],
      'S': ['5'],
      '5': ['S'],
      'B': ['8'],
      '8': ['B'],
    };
    
    return similarPairs[target]?.contains(recognized) ?? false;
  }

  Future<void> _speakSafe(String text) async {
    try {
      await AudioService.instance.speak(text);
    } catch (_) {}
  }

  String _normalize(String s) {
    var out = s.trim().toUpperCase();
    final map = {
      'Á': 'A', 'À': 'A', 'Â': 'A', 'Ä': 'A',
      'É': 'E', 'È': 'E', 'Ê': 'E', 'Ë': 'E',
      'Í': 'I', 'Ì': 'I', 'Î': 'I', 'Ï': 'I',
      'Ó': 'O', 'Ò': 'O', 'Ô': 'O', 'Ö': 'O',
      'Ú': 'U', 'Ù': 'U', 'Û': 'U', 'Ü': 'U',
      'Ñ': 'N', 'Ç': 'C',
    };
    map.forEach((k, v) {
      out = out.replaceAll(k, v);
    });
    return out;
  }

  // Métodos auxiliares para el fallback local
  List<Offset> _letterTemplatePoints(String letter) {
    final L = letter.toUpperCase();
    switch (L) {
      case 'A':
        return [
          Offset(0.1, 0.9),
          Offset(0.5, 0.1),
          Offset(0.9, 0.9),
          Offset(0.25, 0.55),
          Offset(0.75, 0.55),
        ];
      case 'B':
        return [
          Offset(0.2, 0.1),
          Offset(0.2, 0.9),
          Offset(0.2, 0.5),
          Offset(0.7, 0.3),
          Offset(0.7, 0.7),
        ];
      case 'C':
        return [
          Offset(0.8, 0.2),
          Offset(0.4, 0.2),
          Offset(0.2, 0.5),
          Offset(0.4, 0.8),
          Offset(0.8, 0.8),
        ];
      default:
        return [
          Offset(0.5, 0.1),
          Offset(0.5, 0.9),
        ];
    }
  }
  List<Offset> _mergeAndNormalizeStrokes(List<List<Offset>> strokes, int targetN) {
    if (strokes.isEmpty) return List.generate(targetN, (i) => Offset(0.5, 0.5));
    final pts = <Offset>[];
    for (final s in strokes) pts.addAll(s);
    
    double minX = pts.map((p) => p.dx).reduce(min);
    double minY = pts.map((p) => p.dy).reduce(min);
    double maxX = pts.map((p) => p.dx).reduce(max);
    double maxY = pts.map((p) => p.dy).reduce(max);
    
    final w = maxX - minX;
    final h = maxY - minY;
    final size = max(w, h);
    
    if (size == 0) return List.generate(targetN, (i) => Offset(0.5, 0.5));
    
    final norm = pts.map((p) => Offset(
      (p.dx - minX) / size,
      (p.dy - minY) / size,
    )).toList();
    
    return DrawingUtils.resamplePoints(norm, targetN);
  }

  Widget _buildCanvas(double width, double height) {
    final targetLetter = _index >= 0 ? letters[_index].char.toUpperCase() : '?';
    
    return GestureDetector(
      onPanStart: (details) {
        final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final local = box.globalToLocal(details.globalPosition);
          _startStroke(local);
        } else {
          // fallback (muy improbable): usar contexto actual
          final box2 = context.findRenderObject() as RenderBox;
          _startStroke(box2.globalToLocal(details.globalPosition));
        }
      },
      onPanUpdate: (details) {
        final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final local = box.globalToLocal(details.globalPosition);
          _addPoint(local);
        } else {
          final box2 = context.findRenderObject() as RenderBox;
          _addPoint(box2.globalToLocal(details.globalPosition));
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
            // Letra guía
            Center(
              child: Text(
                targetLetter,
                style: TextStyle(
                  fontSize: min(width, height) * 0.6,
                  color: Colors.grey.withOpacity(0.15),
                  fontWeight: FontWeight.w300,
                  fontFamily: 'DancingScript',
                ),
              ),
            ),
            
            // Dibujo del usuario
            Positioned.fill(
              child: CustomPaint(
                painter: InkPainter(strokes: _strokes),
              ),
            ),
            
            // Indicador de carga del modelo
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
                      Text(
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
      return Center(child: const Text('No hay letras definidas'));
    }
    final currentLetter = letters[_index].char.toUpperCase();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // // Indicador de progreso
          // LinearProgressIndicator(
          //   value: _index / letters.length,
          //   backgroundColor: Colors.grey[200],
          //   valueColor: AlwaysStoppedAnimation<Color>(
          //     const Color.fromARGB(255, 68, 194, 193),
          //   ),
          //   minHeight: 8,
          //   borderRadius: BorderRadius.circular(4),
          // ),
          // const SizedBox(height: 8),
          
          // // Contador de letras
          // Text(
          //   'Letra ${_index + 1} de ${letters.length}',
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //     color: Colors.grey[600],
          //     fontSize: 14,
          //   ),
          // ),
          // const SizedBox(height: 16),
          
          // Área de dibujo
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = min(constraints.maxWidth, constraints.maxHeight * 0.8);
                return Center(
                  child: SizedBox(
                    width: size,
                    height: size,
                    child: _buildCanvas(size, size),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          
          // Botones de acción
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Borrar'),
                  onPressed: _clearDrawing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: _checking
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: _checking
                      ? const Text('Verificando...')
                      : const Text('Verificar'),
                  onPressed: _checking || _strokes.isEmpty ? null : _onCheck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 68, 194, 193),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
    // Si está embebido, devolvemos solo el contenido sin Scaffold
    if (widget.embedded) {
      return _buildContent();
    }

    if (_index < 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Practicar letras')),
        body: const Center(child: Text('No hay letras definidas')),
      );
    }
    
    final currentLetter = letters[_index].char.toUpperCase();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Practicar letra $currentLetter'),
        backgroundColor: const Color.fromARGB(255, 68, 194, 193),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () async {
              try {
                await AudioService.instance.speakLetter(currentLetter);
                await Future.delayed(const Duration(milliseconds: 300));
                await AudioService.instance.speak('Practica trazando la letra $currentLetter');
              } catch (_) {}
            },
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
}