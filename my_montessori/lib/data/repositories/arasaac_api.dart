import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ArasaacApi {
  static final Map<String, File?> _memoryCache = {};
  static final Map<String, Future<File?>> _futureCache = {};

  static Future<File?> fetchPictogram(String keyword) async {
    // Si ya tenemos el archivo en caché, retornarlo
    if (_memoryCache.containsKey(keyword)) {
      return _memoryCache[keyword];
    }

    // Si ya hay un Future en curso, no crear otro
    if (_futureCache.containsKey(keyword)) {
      return _futureCache[keyword];
    }

    // Crear nuevo Future y cachearlo
    final future = _fetchPictogramInternal(keyword);
    _futureCache[keyword] = future;
    
    // Cuando se complete, mover de futureCache a memoryCache
    final result = await future;
    _memoryCache[keyword] = result;
    _futureCache.remove(keyword);
    
    return result;
  }

  static Future<File?> _fetchPictogramInternal(String keyword) async {
    try {
      final searchUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/es/search/$keyword");
      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) return null;

      final List<dynamic> pictogramas = jsonDecode(searchResponse.body);
      if (pictogramas.isEmpty) return null;

      final pictogramId = pictogramas[0]["_id"];
      if (pictogramId == null) return null;

      final imageUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/$pictogramId?download=true");
      final imageResponse = await http.get(imageUrl);
      if (imageResponse.statusCode != 200) return null;

      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/$keyword.png';
      final file = File(filePath);
      await file.writeAsBytes(imageResponse.bodyBytes);

      return file;
    } catch (e) {
      print("Error al descargar pictograma: $e");
      return null;
    }
  }

  // Método para precargar todos los pictogramas necesarios
  static void preloadPictograms(List<String> keywords) {
    for (final keyword in keywords) {
      if (!_memoryCache.containsKey(keyword) && !_futureCache.containsKey(keyword)) {
        fetchPictogram(keyword);
      }
    }
  }
}