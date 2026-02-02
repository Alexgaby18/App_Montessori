import 'dart:io';
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
  Letter(char: 'E', words: ['Erizo', 'Estrella', 'Escuela', 'Elefante']),
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
  Letter(char: 'W', words: ['Wifi', 'Whisky', 'Web', 'Wok']),
  Letter(char: 'X', words: ['Taxi', 'Xilófono', 'Examen', 'Éxito']),
  Letter(char: 'Y', words: ['Yate', 'Yogur', 'Yoyo', 'Yegua']),
  Letter(char: 'Z', words: ['Zorro', 'Zapato', 'Zona', 'Pizza']),
];

const List<Letter> vowels = [
  Letter(char: 'A', words: ['Abeja', 'Avión', 'Árbol', 'Anillo']),
  Letter(char: 'E', words: ['Erizo', 'Estrella', 'Escuela', 'Elefante']),
  Letter(char: 'I', words: ['Isla', 'Iglesia', 'Imán', 'Iglú']),
  Letter(char: 'O', words: ['Oso', 'Ojo', 'Oreja', 'Oveja']),
  Letter(char: 'U', words: ['Uva', 'Ukelele', 'Universo', 'Uno']),
];

const List<Letter> syllables = [
  Letter(char: 'M', words: ['Mamá', 'Mesa', 'Miel', 'Mono', 'Muñeca']),
  Letter(char: 'P', words: ['Papa', 'Pera', 'Pipa', 'Pomo', 'Puma']),
  Letter(char: 'L', words: ['Lápiz', 'León', 'Lima', 'Lobo', 'Luna']),
  Letter(char: 'S', words: ['Sapo', 'Seda', 'Silla', 'Sol', 'Suma']),
  Letter(char: 'T', words: ['Taza', 'Tela', 'Tijera', 'Tortuga', 'Tubo']),
  Letter(char: 'N', words: ['Naranja', 'Nena', 'Nido', 'Nota', 'Nube']),
  Letter(char: 'D', words: ['Dado', 'Dedo', 'Dios', 'Dolor', 'Dulce']),
  Letter(char: 'R', words: ['Rana', 'Rey', 'Risa', 'Rosa', 'Rueda']),
  Letter(char: 'F', words: ['Faro', 'Feliz', 'Fideo', 'Foca', 'Fuma']),
  Letter(char: 'B', words: ['Barco', 'Beso', 'Billete', 'Boda', 'Burro']),
  Letter(char: 'V', words: ['Vaca', 'Ventana', 'Vino', 'Volcán', 'Vuelo']),
  Letter(char: 'C', words: ['Casa', 'Coco', 'Cuna']),
  Letter(char: 'Q', words: ['Queso', 'Quince']),
  Letter(char: 'G', words: ['Gato', 'Goma', 'Gusano']),
  Letter(char: 'H', words: ['Hada', 'Helado', 'Hielo', 'Hola', 'Humo']),
  Letter(char: 'J', words: ['Jabón', 'Jefe', 'Jirafa', 'Joya', 'Jugo']),
  Letter(char: 'Y', words: ['Yate', 'Yogur', 'Yoyo', 'Yegua']),
  Letter(char: 'Z', words: ['Zapato', 'Zebra', 'Zinc', 'Zorro', 'Zumo']),
];

// wrapper para exponer palabras sueltas a la UI
class Word {
  final String text;
  final Letter parent; // referencia a la letra a la que pertenece
  const Word({required this.text, required this.parent});

  // si tu Letter ya tiene pictogramFile(word) que devuelve Future<File?>:
  Future<File?> pictogramFile() => parent.pictogramFile(text);

  @override
  String toString() => 'Word(text: $text, parent: ${parent.char})';
}

// Genera la lista de palabras a partir de `letters` 
final List<Word> words = [
  for (final l in letters)
    for (final w in l.words) Word(text: w, parent: l),
];

final List<Word> vowelWords = [
  for (final l in vowels)
    for (final w in l.words) Word(text: w, parent: l),
];

final List<Word> syllableWords = [
  for (final l in syllables)
    for (final w in l.words) Word(text: w, parent: l),
];