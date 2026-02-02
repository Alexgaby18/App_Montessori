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
  Letter(char: 'G', words: ['Gato', 'Goma', 'Gusano']),
  Letter(char: 'H', words: ['Hada', 'Helado', 'Hielo', 'Hola', 'Humo']),
  Letter(char: 'J', words: ['Jabón', 'Jefe', 'Jirafa', 'Joya', 'Jugo']),
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

// Map de sílabas por letra. Cada entrada usa la misma clase `Letter` donde
// `char` es la sílaba (ej. 'MA') y `words` son ejemplos cuyo pictograma mostrar.
const Map<String, List<Letter>> syllablesByLetter = {
  'M': [
    Letter(char: 'MA', words: ['Mamá', 'Mapa']),
    Letter(char: 'ME', words: ['Mesa', 'Medusa']),
    Letter(char: 'MI', words: ['Miel', 'Mina']),
    Letter(char: 'MO', words: ['Mono', 'Mochila']),
    Letter(char: 'MU', words: ['Muñeca', 'Mundo']),
  ],
  'P': [
    Letter(char: 'PA', words: ['Papá', 'Pala']),
    Letter(char: 'PE', words: ['Pez', 'Perro']),
    Letter(char: 'PI', words: ['Pipa', 'Pie']),
    Letter(char: 'PO', words: ['Pomo', 'Pollito']),
    Letter(char: 'PU', words: ['Puma', 'Pulpo']),
  ],
  'L': [
    Letter(char: 'LA', words: ['Lápiz', 'Lata']),
    Letter(char: 'LE', words: ['León', 'Leche']),
    Letter(char: 'LI', words: ['Lima', 'Libro']),
    Letter(char: 'LO', words: ['Lobo', 'Lomo']),
    Letter(char: 'LU', words: ['Luna', 'Lupa']),
  ],
  'S': [
    Letter(char: 'SA', words: ['Sapo', 'Sandía']),
    Letter(char: 'SE', words: ['Serpiente', 'Seis']),
    Letter(char: 'SI', words: ['Silla', 'Siete']),
    Letter(char: 'SO', words: ['Sol', 'Sopa']),
    Letter(char: 'SU', words: ['Suma', 'Suéter']),
  ],
  'T': [
    Letter(char: 'TA', words: ['Taza', 'Tambor']),
    Letter(char: 'TE', words: ['Tele', 'Teléfono']),
    Letter(char: 'TI', words: ['Tijera', 'Tigre']),
    Letter(char: 'TO', words: ['Tortuga', 'Toro']),
    Letter(char: 'TU', words: ['Tubo', 'Tulipán']),
  ],
  'D': [
    Letter(char: 'DA', words: ['Dado', 'Dardo']),
    Letter(char: 'DE', words: ['Dedo', 'Delfín']),
    Letter(char: 'DI', words: ['Dino', 'Diente']),
    Letter(char: 'DO', words: ['Dos', 'Domino']),
    Letter(char: 'DU', words: ['Dulce', 'Duende']),
  ],
  'N': [
    Letter(char: 'NA', words: ['Naranja', 'Nave']),
    Letter(char: 'NE', words: ['Negro', 'Nevera']),
    Letter(char: 'NI', words: ['Nido', 'Niño']),
    Letter(char: 'NO', words: ['Nota', 'Noche']),
    Letter(char: 'NU', words: ['Nube', 'Nudo']),
  ],
  'R': [
    Letter(char: 'RA', words: ['Rana', 'Rata']),
    Letter(char: 'RE', words: ['Reloj', 'Reno']),
    Letter(char: 'RI', words: ['Risa', 'Río']),
    Letter(char: 'RO', words: ['Rosa', 'Roca']),
    Letter(char: 'RU', words: ['Rueda', 'Ruleta']),
  ],
  'F':[
    Letter(char: 'FA', words: ['Faro', 'Falda']),
    Letter(char: 'FE', words: ['Feliz', 'Feria']),
    Letter(char: 'FI', words: ['Fideo', 'Fiesta']),
    Letter(char: 'FO', words: ['Foca', 'Foco']),
    Letter(char: 'FU', words: ['Fuego', 'Futbol']),
  ],
  'B':[
    Letter(char: 'BA', words: ['Ballena', 'Barco']),
    Letter(char: 'BE', words: ['Bebé', 'Beso']),
    Letter(char: 'BI', words: ['Bicicleta', 'Billete']),
    Letter(char: 'BO', words: ['Boca', 'Bola']),
    Letter(char: 'BU', words: ['Burro', 'Búho']),
  ],
  'V':[
    Letter(char: 'VA', words: ['Vaca', 'Vaso']),
    Letter(char: 'VE', words: ['Vela', 'Ventana']),
    Letter(char: 'VI', words: ['Vino', 'Vida']),
    Letter(char: 'VO', words: ['Volcán', 'Volar']),
    Letter(char: 'VU', words: ['Vuelo', 'Vuelta']),
  ],
  'G':[
    Letter(char: 'GA', words: ['Gato', 'Gafas']),
    Letter(char: 'GE', words: ['Genio', 'Gente']),
    Letter(char: 'GI', words: ['Girasol', 'Gigante']),
    Letter(char: 'GO', words: ['Goma', 'Gol']),
    Letter(char: 'GU', words: ['Guitarra', 'Guante']),
  ],
  'H':[
    Letter(char: 'HA', words: ['Hada', 'Hacha']),
    Letter(char: 'HE', words: ['Helado', 'Hermana']),
    Letter(char: 'HI', words: ['Hielo', 'Higo']),
    Letter(char: 'HO', words: ['Hoja', 'Hormiga']),
    Letter(char: 'HU', words: ['Humo', 'Huella']),
  ],
  'J':[
    Letter(char: 'JA', words: ['Jabón', 'Jarra']),
    Letter(char: 'JE', words: ['Jefe', 'Jeringa']),
    Letter(char: 'JI', words: ['Jirafa', 'Jinete']),
    Letter(char: 'JO', words: ['Joya', 'Joven']),
    Letter(char: 'JU', words: ['Jugo', 'Juguete']),
  ],
  // Añade más letras/sílabas según necesites...
};