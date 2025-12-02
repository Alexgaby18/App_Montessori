import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_montessori/data/repositories/arasaac_api.dart';

class Letter {
  final String char; // 'A'
  final List<String> words;

  const Letter({required this.char, required this.words});

  // Normaliza palabra para búsqueda en API
  String _slug(String s) {
    const accents = 'áéíóúÁÉÍÓÚñÑüÜ';
    const replacements = 'aeiouAEIOUnNuU';
    String out = s;
    for (int i = 0; i < accents.length; i++) {
      out = out.replaceAll(accents[i], replacements[i]);
    }
    out = out.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
    out = out.replaceAll(RegExp(r'_+'), '_').trim();
    if (out.startsWith('_')) out = out.substring(1);
    if (out.endsWith('_')) out = out.substring(0, out.length - 1);
    return out;
  }

  // 🔄 Ahora devuelve un Future<File?> con el pictograma descargado
  Future<File?> pictogramFile(String word) async {
    final slugWord = _slug(word);
    return await ArasaacApi.fetchPictogram(slugWord);
  }
}

// Lista ordenada de letras con sus palabras
const List<Letter> letters = [
  Letter(char: 'A', words: ['Abeja', 'Avión', 'Árbol', 'Anillo']),
  Letter(char: 'B', words: ['Barco', 'Boca', 'Ballena', 'Bebé']),
  Letter(char: 'C', words: ['Casa', 'Coche', 'Cama', 'Conejo']),
  Letter(char: 'D', words: ['Delfín', 'Dado', 'Diente', 'Dedo']),
  Letter(char: 'E', words: ['Elefante', 'Estrella', 'Escuela', 'Erizo']),
  Letter(char: 'F', words: ['Foca', 'Flor', 'Fruta', 'Fuego']),
  Letter(char: 'G', words: ['Gato', 'Globo', 'Guitarra', 'Gallo']),
  Letter(char: 'H', words: ['Helado', 'Hormiga', 'Huevo', 'Hacha']),
  Letter(char: 'I', words: ['Isla', 'Iglesia', 'Imán', 'Iglú']),
  Letter(char: 'J', words: ['Jirafa', 'Juguete', 'Jardín', 'Jamón']),
  Letter(char: 'K', words: ['Koala', 'Kilo', 'Kiwi', 'Kimono']),
  Letter(char: 'L', words: ['León', 'Luna', 'Libro', 'Lápiz']),
  Letter(char: 'M', words: ['Mamá', 'Mesa', 'Moto', 'Mono']),
  Letter(char: 'N', words: ['Nube', 'Naranja', 'Nariz', 'Nido']),
  Letter(char: 'O', words: ['Oso', 'Ojo', 'Oreja', 'Oveja']),
  Letter(char: 'P', words: ['Perro', 'Pato', 'Pelota', 'Papá']),
  Letter(char: 'Q', words: ['Queso', 'Quince', 'Quinto', 'Química']),
  Letter(char: 'R', words: ['Ratón', 'Rosa', 'Rueda', 'Rana']),
  Letter(char: 'S', words: ['Sol', 'Silla', 'Sopa', 'Saco']),
  Letter(char: 'T', words: ['Toro', 'Taza', 'Tren', 'Teléfono']),  
  Letter(char: 'U', words: ['Uva', 'Ukelele', 'Universo', 'Uno']),
  Letter(char: 'V', words: ['Vaca', 'Vaso', 'Verde', 'Volcán']),
  Letter(char: 'W', words: ['Whisky', 'Wifi', 'Web', 'Wok']),
  Letter(char: 'X', words: ['Xilófono', 'Taxi', 'Examen', 'Éxito']),
  Letter(char: 'Y', words: ['Yate', 'Yogur', 'Yoyo', 'Yegua']),
  Letter(char: 'Z', words: ['Zorro', 'Zapato', 'Zona', 'Pizza']),
];
