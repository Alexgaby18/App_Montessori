import 'dart:io';
import 'dart:convert'; // 👈 necesario para jsonDecode
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ArasaacApi {
  static Future<File?> fetchPictogram(String keyword) async {
    try {
      // 🔎 Buscar pictogramas por palabra clave
      final searchUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/es/search/$keyword");
      final searchResponse = await http.get(searchUrl);

      if (searchResponse.statusCode != 200) return null;

      // ✅ Parsear JSON correctamente
      final List<dynamic> pictogramas = jsonDecode(searchResponse.body);
      if (pictogramas.isEmpty) return null;

      final pictogramId = pictogramas[0]["_id"]; // 👈 igual que en tu HTML
      if (pictogramId == null) return null;

      // 📥 Descargar imagen PNG
      final imageUrl = Uri.parse("https://api.arasaac.org/v1/pictograms/$pictogramId?download=false");
      final imageResponse = await http.get(imageUrl);
      if (imageResponse.statusCode != 200) return null;

      // 📂 Guardar en caché local
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
}
