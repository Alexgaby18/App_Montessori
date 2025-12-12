import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  DigitalInkRecognizer? _recognizer;
  bool _isModelLoaded = false;

  Future<void> initializeModel(String languageCode) async {
    try {
      _recognizer = DigitalInkRecognizer(languageCode: languageCode);
      final modelManager = DigitalInkRecognizerModelManager();
      
      final bool isDownloaded = await modelManager.isModelDownloaded(languageCode);
      
      if (!isDownloaded) {
        print('📥 Descargando modelo de $languageCode...');
        await modelManager.downloadModel(languageCode);
      }
      
      _isModelLoaded = true;
      print('✅ Modelo de reconocimiento de tinta cargado correctamente');
      
    } catch (e) {
      print('❌ Error inicializando modelo: $e');
      _isModelLoaded = false;
    }
  }

  Future<List<RecognitionCandidate>> recognizeInk(
    Ink ink, {
    bool normalize = true,
    bool epochTimes = false,
  }) async {
    if (!_isModelLoaded || _recognizer == null) {
      throw Exception('Modelo no inicializado');
    }

    return await _recognizer!.recognize(ink);
  }

  bool get isModelLoaded => _isModelLoaded;

  Future<void> close() async {
    await _recognizer?.close();
  }
}