import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._internal() {
    _tts = FlutterTts();
    _tts.setLanguage('es-ES');
    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    // Configurar para que los futuros `speak` completen cuando termine la reproducción
    try {
      _tts.awaitSpeakCompletion(true);
    } catch (_) {}
    _player = AudioPlayer();
  }

  static final AudioService instance = AudioService._internal();

  late final FlutterTts _tts;
  late final AudioPlayer _player;

  static const Map<String, String> _phoneticFallback = {
    'A': 'ah', 'B': 'buh', 'C': 'kuh', 'D': 'duh', 'E': 'eh',
    'F': 'fff', 'G': 'guh', 'H': '', 'I': 'ee', 'J': 'juh',
    'K': 'kkk', 'L': 'lll', 'M': 'mmm', 'N': 'nnn', 'O': 'oh',
    'P': 'ppp', 'Q': 'koo', 'R': 'rrr', 'S': 'sss', 'T': 'ttt',
    'U': 'oo', 'V': 'vvv', 'W': 'wuh', 'X': 'ks', 'Y': 'yuh', 'Z': 'zzz',
  };

  /// Habla cualquier texto por TTS
  Future<void> speak(String text) async {
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  /// Helper: habla la letra tal como viene (ej. 'M' -> TTS pronunciará la letra)
  Future<void> speakLetter(String letter) async {
    if (letter.trim().isEmpty) return;
    // usamos directamente la letra desde la lista (por ejemplo 'M')
    await speak(letter.trim());
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
      await _player.stop();
    } catch (_) {}
  }

  /// Reproduce assets/audio/letters/{letter}.mp3 si existe.
  /// Si no existe, usa TTS con la tabla fonética.
  Future<void> playLetterSound(String letter) async {
    if (letter.isEmpty) return;
    final key = letter.trim()[0].toUpperCase();
    final assetPath = 'assets/audio/letters_sounds/${key.toLowerCase()}.mp3';

    try {
      // intenta cargar el asset (lanza excepción si no existe)
      await rootBundle.load(assetPath);
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (_) {
      final phon = _phoneticFallback[key] ?? key;
      await speak(phon);
    }
  }
}