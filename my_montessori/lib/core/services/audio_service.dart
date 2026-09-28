import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

class AudioService {
  AudioService._internal() {
    _tts = FlutterTts();
    _player = AudioPlayer();
    _ttsReady = _configureTts();
  }

  static final AudioService instance = AudioService._internal();

  late final FlutterTts _tts;
  late final AudioPlayer _player;
  late final Future<void> _ttsReady;

  Future<void> _configureTts() async {
    final spanishVoiceAvailable = await _selectSpanishVoice();
    if (!spanishVoiceAvailable) {
      print('AudioService: no hay una voz TTS en español disponible');
    }
    await _tts.setPitch(1.15);
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    try {
      await _tts.awaitSpeakCompletion(true);
    } catch (_) {}
  }

  Future<bool> _selectSpanishVoice() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        final spanishVoices = voices.whereType<Map<dynamic, dynamic>>().where((
          voice,
        ) {
          final locale = voice['locale']
              ?.toString()
              .replaceAll('_', '-')
              .toLowerCase();
          return locale == 'es' || locale?.startsWith('es-') == true;
        }).toList();

        int voiceScore(Map<dynamic, dynamic> voice) {
          final locale = voice['locale']
              .toString()
              .replaceAll('_', '-')
              .toLowerCase();
          final voiceDetails =
              '${voice['gender'] ?? ''} '
                      '${voice['name'] ?? ''} ${voice['features'] ?? ''}'
                  .toLowerCase();
          final genderScore = voiceDetails.contains('female') ? -100 : 0;
          final localeScore = locale == 'es-es'
              ? 0
              : locale == 'es-mx'
              ? 1
              : 2;
          final networkScore = voice['network_required']?.toString() == '1'
              ? 10
              : 0;
          return genderScore + localeScore + networkScore;
        }

        spanishVoices.sort((a, b) => voiceScore(a).compareTo(voiceScore(b)));
        if (spanishVoices.isNotEmpty) {
          final voice = spanishVoices.first;
          final locale = voice['locale'].toString();
          final languageResult = await _tts.setLanguage(locale);
          final voiceResult = await _tts.setVoice({
            'name': voice['name'].toString(),
            'locale': locale,
          });
          if (languageResult == 1 && voiceResult == 1) {
            print(
              'AudioService: voz TTS seleccionada ${voice['name']} ($locale)',
            );
            return true;
          }
        }
      }

      for (final language in ['es-ES', 'es-MX', 'es']) {
        if (await _tts.isLanguageAvailable(language) == true &&
            await _tts.setLanguage(language) == 1) {
          return true;
        }
      }
    } catch (error) {
      print('AudioService: error al seleccionar voz española: $error');
    }
    return false;
  }

  static const Map<String, String> _phoneticFallback = {
    'A': 'ah',
    'B': 'buh',
    'C': 'kuh',
    'D': 'duh',
    'E': 'eh',
    'F': 'fff',
    'G': 'guh',
    'H': '',
    'I': 'ee',
    'J': 'juh',
    'K': 'kkk',
    'L': 'lll',
    'M': 'mmm',
    'N': 'nnn',
    'O': 'oh',
    'P': 'ppp',
    'Q': 'koo',
    'R': 'rrr',
    'S': 'sss',
    'T': 'ttt',
    'U': 'oo',
    'V': 'vvv',
    'W': 'wuh',
    'X': 'ks',
    'Y': 'yuh',
    'Z': 'zzz',
  };

  /// Habla cualquier texto por TTS
  Future<void> speak(String text) async {
    final normalizedText = text.toLowerCase();
    try {
      await _ttsReady;
      await _tts.stop();
      await _tts.speak(normalizedText);
    } catch (e) {
      // Loguear para diagnóstico
      print('AudioService.speak error (primero intento): $e');
      // Intentar un fallback de idioma (algunos motores TTS esperan diferentes códigos)
      try {
        await _tts.setLanguage('es');
        await _tts.speak(normalizedText);
      } catch (e2) {
        print('AudioService.speak error (fallback idioma): $e2');
      }
    }
  }

  /// Pronuncia una sílaba en español; la h inicial es muda.
  Future<void> speakSyllable(String syllable) async {
    final normalizedSyllable = syllable.trim().toLowerCase();
    if (normalizedSyllable.isEmpty) return;

    const spanishJPronunciation = {'je': 'ge', 'ji': 'gi'};
    final pronunciation =
        spanishJPronunciation[normalizedSyllable] ??
        (normalizedSyllable.startsWith('h')
            ? normalizedSyllable.substring(1)
            : normalizedSyllable);
    if (pronunciation.isNotEmpty) await speak(pronunciation);
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
