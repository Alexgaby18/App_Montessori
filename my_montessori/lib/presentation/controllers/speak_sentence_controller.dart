import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:my_montessori/core/services/audio_service.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';

class SpeakSentenceController extends ChangeNotifier {
  final SentencePictograms sentence;
  final List<SentencePictograms> sentences;
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

  double _confidence = -1.0;
  double get confidence => _confidence;

  Timer? _resultTimer;
  bool _disposed = false;

  SpeakSentenceController({
    required this.sentence,
    required this.sentences,
    this.onAdvance,
    this.onComplete,
    double? confidenceThreshold,
  }) : confidenceThreshold = confidenceThreshold ?? 0.5 {
    _speech = stt.SpeechToText();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
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

  String _normalize(String input) {
    var out = input;
    const accents = '\u00e1\u00e9\u00ed\u00f3\u00fa\u00c1\u00c9\u00cd\u00d3\u00da\u00f1\u00d1\u00fc\u00dc';
    const replacements = 'aeiouAEIOUnNuU';
    for (int i = 0; i < accents.length; i++) {
      out = out.replaceAll(accents[i], replacements[i]);
    }
    out = out.toLowerCase();
    out = out.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
    return out;
  }

  double _tokenMatchRatio(String recognized, String expected) {
    final expectedTokens = expected.isEmpty ? <String>[] : expected.split(' ');
    if (expectedTokens.isEmpty) return 0.0;
    final recognizedTokens = recognized.isEmpty ? <String>[] : recognized.split(' ');
    int matches = 0;
    for (final token in expectedTokens) {
      if (recognizedTokens.contains(token)) {
        matches++;
      }
    }
    return matches / expectedTokens.length;
  }

  bool get isLastResultCorrect {
    if (_lastResult.isEmpty) return false;
    final normalizedExpected = _normalize(sentence.text);
    if (normalizedExpected.isEmpty) return false;
    final normalizedResult = _normalize(_lastResult);

    final containsMatch = normalizedResult.contains(normalizedExpected);
    if (containsMatch) {
      if (_confidence < 0.0) return true;
      return _confidence >= confidenceThreshold;
    }

    final ratio = _tokenMatchRatio(normalizedResult, normalizedExpected);
    if (ratio >= 0.7) {
      if (_confidence < 0.0) return true;
      return _confidence >= confidenceThreshold;
    }

    return false;
  }

  bool get isLastResultWrong => _lastResult.isNotEmpty && !isLastResultCorrect;

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
        _confidence = result.confidence ?? _confidence;
        _level = result.finalResult ? 0.0 : (_speech.isListening ? _level : 0.0);
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
    final ok = isLastResultCorrect;
    if (ok) {
      await AudioService.instance.speak('Muy bien!');
      await Future.delayed(const Duration(milliseconds: 400));
      await AudioService.instance.speak(sentence.text);

      final int idx = sentences.indexWhere((s) => s.text == sentence.text);
      final bool hasNext = idx >= 0 && idx < sentences.length - 1;
      await Future.delayed(const Duration(milliseconds: 600));
      if (hasNext) {
        onAdvance?.call(idx + 1);
        return;
      }
      onComplete?.call();
      return;
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

  @override
  void dispose() {
    _disposed = true;
    _resultTimer?.cancel();
    _speech.stop();
    super.dispose();
  }
}
