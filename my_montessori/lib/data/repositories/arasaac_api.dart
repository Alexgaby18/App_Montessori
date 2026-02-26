import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ArasaacApi {
  static final Map<String, File?> _memoryCache = {};
  static final Map<String, Future<File?>> _futureCache = {};

  static String _canonicalKeyword(String keyword) {
    const accents = 'áéíóúÁÉÍÓÚñÑüÜ';
    const replacements = 'aeiouAEIOUnNuU';
    var out = keyword.trim();
    for (int i = 0; i < accents.length; i++) {
      out = out.replaceAll(accents[i], replacements[i]);
    }
    out = out.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    out = out.replaceAll(RegExp(r'_+'), '_');
    if (out.startsWith('_')) out = out.substring(1);
    if (out.endsWith('_')) out = out.substring(0, out.length - 1);
    return out;
  }

  static Future<File> _localFileFor(String canonicalKeyword) async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$canonicalKeyword.png');
  }

  static Future<File?> fetchPictogram(String keyword) async {
    final canonicalKeyword = _canonicalKeyword(keyword);

    // Si ya tenemos el archivo en caché, retornarlo
    if (_memoryCache.containsKey(canonicalKeyword)) {
      return _memoryCache[canonicalKeyword];
    }

    // Si ya existe en disco, usarlo sin volver a descargar
    final localFile = await _localFileFor(canonicalKeyword);
    if (await localFile.exists()) {
      _memoryCache[canonicalKeyword] = localFile;
      return localFile;
    }

    // Si ya hay un Future en curso, no crear otro
    if (_futureCache.containsKey(canonicalKeyword)) {
      return _futureCache[canonicalKeyword];
    }

    // Crear nuevo Future y cachearlo
    final future = _fetchPictogramInternal(canonicalKeyword);
    _futureCache[canonicalKeyword] = future;
    
    // Cuando se complete, mover de futureCache a memoryCache
    final result = await future;
    _memoryCache[canonicalKeyword] = result;
    _futureCache.remove(canonicalKeyword);
    
    return result;
  }

  static Future<File?> _fetchPictogramInternal(String canonicalKeyword) async {
    try {
      final searchUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/es/search/$canonicalKeyword");
      final searchResponse = await http.get(searchUrl);
      if (searchResponse.statusCode != 200) return null;

      final List<dynamic> pictogramas = jsonDecode(searchResponse.body);
      if (pictogramas.isEmpty) return null;

      final pictogramId = pictogramas[0]["_id"];
      if (pictogramId == null) return null;

      final imageUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/$pictogramId?download=true");
      final imageResponse = await http.get(imageUrl);
      if (imageResponse.statusCode != 200) return null;

      final file = await _localFileFor(canonicalKeyword);
      await file.writeAsBytes(imageResponse.bodyBytes);

      return file;
    } catch (e) {
      print("Error al descargar pictograma: $e");
      return null;
    }
  }

  // Método para precargar todos los pictogramas necesarios
  static Future<void> preloadPictograms(List<String> keywords) async {
    for (final keyword in keywords) {
      final canonicalKeyword = _canonicalKeyword(keyword);
      if (!_memoryCache.containsKey(canonicalKeyword) && !_futureCache.containsKey(canonicalKeyword)) {
        await fetchPictogram(canonicalKeyword);
      }
    }
  }
}