import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';

class SpeakWordController extends ChangeNotifier {
  final Word word;
  final List<Word> words;
  final void Function(int nextIndex)? onAdvance;
  final VoidCallback? onComplete;
  final double confidenceThreshold;

  late stt.SpeechToText _speech;
  bool _available = false;
  bool get available => _available;

  bool _listening = false;
  bool get listening => _listening;

  String _lastResult = '';
  String get lastResult => _lastResult;

  double _level = 0.0;
  double get level => _level;

  Timer? _resultTimer;

  double _confidence = 0.0;
  double get confidence => _confidence;

  bool _disposed = false;

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  bool get isLastResultCorrect {
    if (_lastResult.isEmpty) return false;
    final normalizedExpected = _normalize(word.text);
    final tokens = _lastResult.split(RegExp(r"\s+"))
        .map((t) => _normalize(t))
        .toList();
    final tokenMatch = tokens.contains(normalizedExpected);
    final containsMatch = _normalize(_lastResult).contains(normalizedExpected);
    if (tokenMatch) return true;

    // Si confidence está disponible (>= 0) usamos el umbral configurado
    if (_confidence >= 0.0) {
      if (containsMatch && _confidence >= confidenceThreshold) return true;
    } else {
      // confidence no disponible en algunos entornos (valor -1). Usar fallback:
      if (containsMatch) {
        debugPrint('SpeakWordController: confidence unavailable, accepting containsMatch fallback');
        return true;
      }
    }

    // Fallback adicional: comparar por distancia de edición con cada token
    try {
      if (normalizedExpected.isNotEmpty) {
        double minNorm = tokens
            .map((t) {
              final d = _levenshtein(t, normalizedExpected);
              final denom = max(t.length, normalizedExpected.length);
              return denom == 0 ? 0.0 : d / denom;
            })
            .fold<double>(1.0, (prev, cur) => cur < prev ? cur : prev);
        // aceptar si la distancia normalizada es baja (<= 0.35)
        if (minNorm <= 0.35) {
          debugPrint('SpeakWordController: accepted by Levenshtein fallback (norm=$minNorm)');
          return true;
        }
      }
    } catch (e) {
      // no bloquear por errores en fallback
    }

    return false;
  }

  bool get isLastResultWrong => _lastResult.isNotEmpty && !isLastResultCorrect;

  // Levenshtein distance (iterative DP)
  int _levenshtein(String a, String b) {
    final la = a.length;
    final lb = b.length;
    if (la == 0) return lb;
    if (lb == 0) return la;
    List<int> prev = List<int>.generate(lb + 1, (i) => i);
    List<int> cur = List<int>.filled(lb + 1, 0);
    for (int i = 1; i <= la; i++) {
      cur[0] = i;
      for (int j = 1; j <= lb; j++) {
        final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
        cur[j] = min(min(cur[j - 1] + 1, prev[j] + 1), prev[j - 1] + cost);
      }
      final temp = prev;
      prev = cur;
      cur = temp;
    }
    return prev[lb];
  }

  SpeakWordController({required this.word, required this.words, this.onAdvance, this.onComplete, double? confidenceThreshold})
      : confidenceThreshold = confidenceThreshold ?? 0.5 {
    _speech = stt.SpeechToText();
  }

  Future<void> init() async {
    try {
      final available = await _speech.initialize(onStatus: _onStatus, onError: _onError);
      _available = available;
    } catch (_) {
      _available = false;
    }
    _safeNotify();
  }

  void _onStatus(String status) {
    if (status == 'done' || status == 'notListening') {
      _listening = false;
      _safeNotify();
    }
  }

  void _onError(dynamic error) {
    _listening = false;
    _safeNotify();
  }

  String _normalize(String s) {
    final map = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u',
      'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U'
    };
    var out = s;
    map.forEach((k, v) => out = out.replaceAll(k, v));
    return out.toLowerCase().trim();
  }

  bool _matches(String recognized, String expected) {
    final r = _normalize(recognized);
    final e = _normalize(expected);
    return r.contains(e) || r == e;
  }

  Future<void> startListening() async {
    if (!_available) {
      await init();
      if (!_available) {
        AudioService.instance.speak('No se puede acceder al reconocimiento de voz');
        return;
      }
    }

    _lastResult = '';
    _listening = true;
    notifyListeners();

    await _speech.listen(
      onResult: (result) {
        _lastResult = result.recognizedWords;
        _confidence = (result.confidence ?? _confidence);
        _level = result.finalResult ? 0.0 : (_speech.isListening ? _level : 0.0);
        // debug para desarrollo
        debugPrint('SpeakWordController onResult -> recognized="${_lastResult}", confidence=${_confidence.toStringAsFixed(2)}');
        _safeNotify();
        if (result.finalResult) {
          _evaluateResult(result.recognizedWords);
        }
      },
      listenMode: stt.ListenMode.confirmation,
      localeId: 'es_ES',
      onSoundLevelChange: (level) {
        _level = level;
        _safeNotify();
      },
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _listening = false;
    _safeNotify();
  }

  Future<void> _evaluateResult(String recognized) async {
    _confidence = _confidence; // mantener último valor disponible
    final ok = _matches(recognized, word.text) || isLastResultCorrect;
    debugPrint('SpeakWordController _evaluateResult -> recognized="$recognized", confidence=${_confidence.toStringAsFixed(2)}, ok=$ok');
    if (ok) {
      await AudioService.instance.speak('¡Muy bien!');
      await Future.delayed(const Duration(milliseconds: 400));
      await AudioService.instance.speak(word.text);

      final int idx = words.indexWhere((w) => w.text == word.text);
      final bool hasNext = idx >= 0 && idx < words.length - 1;
      await Future.delayed(const Duration(milliseconds: 600));
      if (hasNext) {
        onAdvance?.call(idx + 1);
        return;
      } else {
        onComplete?.call();
        return;
      }
    } else {
      await AudioService.instance.speak('Intenta de nuevo');
    }

    _resultTimer?.cancel();
    _resultTimer = Timer(const Duration(seconds: 2), () {
      _lastResult = '';
      _safeNotify();
    });
    _safeNotify();
  }

  void speakInstruction() {
    AudioService.instance.speak('Lee la palabra ${word.text}');
  }

  @override
  void dispose() {
    _disposed = true;
    _resultTimer?.cancel();
    _speech.stop();
    super.dispose();
  }
}
