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
  Letter(char: 'Y', words: ['Yate', 'Yo', 'Yoyo', 'Yegua']),
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
    Letter(char: 'MA', words: ['Mamá', 'Mapa', 'Mariposa', 'Manzana']),
    Letter(char: 'ME', words: ['Mesa', 'Medusa', 'Melón', 'Mermelada']),
    Letter(char: 'MI', words: ['Mimo', 'Mina', 'Mira', 'Miel']),
    Letter(char: 'MO', words: ['Mono', 'Mochila', 'Mora', 'Móvil']),
    Letter(char: 'MU', words: ['Muñeca', 'Mundo', 'Música', 'Muleta']),
  ],
  'P': [
    Letter(char: 'PA', words: ['Papá', 'Pala', 'Pato', 'Pan']),
    Letter(char: 'PE', words: ['Pez', 'Perro', 'Pera', 'Pelota']),
    Letter(char: 'PI', words: ['Pipa', 'Pie', 'Pino', 'Pila']),
    Letter(char: 'PO', words: ['Pomo', 'Pollito', 'Poco', 'Pollo']),
    Letter(char: 'PU', words: ['Puma', 'Pulpo', 'Pudin', 'Pupila']),
  ],
  'L': [
    Letter(char: 'LA', words: ['Lápiz', 'Lata', 'Lago', 'Lámpara']),
    Letter(char: 'LE', words: ['Leer', 'Leche', 'Lente', 'León']),
    Letter(char: 'LI', words: ['Lima', 'Libro', 'Lija', 'Liso']),
    Letter(char: 'LO', words: ['Lobo', 'Lomo', 'Loco', 'Loro']),
    Letter(char: 'LU', words: ['Luna', 'Lupa', 'Luz', 'Luchar']),
  ],
  'S': [
    Letter(char: 'SA', words: ['Sapo', 'Sandía', 'Salsa', 'Saco']),
    Letter(char: 'SE', words: ['Seda', 'Seis', 'Sello', 'Serpiente']),
    Letter(char: 'SI', words: ['Silla', 'Siete', 'Sierra', 'Silo']),
    Letter(char: 'SO', words: ['Sol', 'Sopa', 'Sombra', 'Sofá']),
    Letter(char: 'SU', words: ['Suma', 'Suéter', 'Suerte', 'Susto']),
  ],
  'T': [
    Letter(char: 'TA', words: ['Taza', 'Tambor', 'Tabla', 'Talla']),
    Letter(char: 'TE', words: ['Tele', 'Teléfono', 'Templo', 'Tenedor']),
    Letter(char: 'TI', words: ['Tijera', 'Tigre', 'Timón', 'Tiza']),
    Letter(char: 'TO', words: ['Toro', 'Tortuga', 'Tomate', 'Tobogán']),
    Letter(char: 'TU', words: ['Tubo', 'Tulipán', 'Túnel', 'Tumba']),
  ],
  'D': [
    Letter(char: 'DA', words: ['Dado', 'Dardo', 'Damas', 'Danza']),
    Letter(char: 'DE', words: ['Dedo', 'Delfín', 'Delantal', 'Dedal']),
    Letter(char: 'DI', words: ['Dino', 'Diente', 'Día', 'Dibujo']),
    Letter(char: 'DO', words: ['Dos', 'Domino', 'Dólar', 'Dolor']),
    Letter(char: 'DU', words: ['Duda', 'Duende', 'Ducha', 'Dulce']),
  ],
  'N': [
    Letter(char: 'NA', words: ['Nave', 'Naranja', 'Nata', 'Navaja']),
    Letter(char: 'NE', words: ['Negro', 'Nevera', 'Nevar', 'Nervios']),
    Letter(char: 'NI', words: ['Nido', 'Niño', 'Nieve', 'Niñas']),
    Letter(char: 'NO', words: ['Nota', 'Noche', 'Noria', 'Novia']),
    Letter(char: 'NU', words: ['Nube', 'Nudo', 'Nuez', 'Nuca']),
  ],
  'R': [
    Letter(char: 'RA', words: ['Rana', 'Rata', 'Rama', 'Raro']),
    Letter(char: 'RE', words: ['Reloj', 'Reno', 'Rey', 'Remo']),
    Letter(char: 'RI', words: ['Risa', 'Río', 'Rizo', 'Rímel']),
    Letter(char: 'RO', words: ['Rosa', 'Roca', 'Rollo', 'Robo']),
    Letter(char: 'RU', words: ['Rueda', 'Ruleta', 'Rubí', 'Rusia']),
  ],
  'F':[
    Letter(char: 'FA', words: ['Faro', 'Falda', 'Fases', 'Fantasma']),
    Letter(char: 'FE', words: ['Feliz', 'Feria', 'Feroz', 'Feo']),
    Letter(char: 'FI', words: ['Fila', 'Fiesta', 'Fin', 'Ficha']),
    Letter(char: 'FO', words: ['Foca', 'Foco', 'Fondo', 'Fósil']),
    Letter(char: 'FU', words: ['Fuego', 'Futbol', 'Furioso', 'Funda']),
  ],
  'B':[
    Letter(char: 'BA', words: ['Bala', 'Barco', 'Ballena', 'Bajo']),
    Letter(char: 'BE', words: ['Bebé', 'Beso', 'Bello', 'Beber']),
    Letter(char: 'BI', words: ['Bicicleta', 'Billete', 'Bingo', 'Bigote']),
    Letter(char: 'BO', words: ['Boca', 'Bola', 'Bote', 'Bolo']),
    Letter(char: 'BU', words: ['Burro', 'Búho', 'Buzo', 'Buey']),
  ],
  'V':[
    Letter(char: 'VA', words: ['Vaca', 'Vaso', 'Vago', 'Valle']),
    Letter(char: 'VE', words: ['Vela', 'Ventana', 'Verde', 'Ver']),
    Letter(char: 'VI', words: ['Vino', 'Vida', 'Viento', 'Violeta']),
    Letter(char: 'VO', words: ['Volar', 'Volcán', 'Volante', 'Votar']),
    Letter(char: 'VU', words: ['Vuelo', 'Vuelta', 'Vuestro']),
  ],
  'G':[
    Letter(char: 'GA', words: ['Gato', 'Gafas', 'Gallo', 'Gamba']),
    Letter(char: 'GE', words: ['Genio', 'Gente', 'Gel', 'Genial']),
    Letter(char: 'GI', words: ['Girasol', 'Gigante', 'Gimnasio', 'Giro']),
    Letter(char: 'GO', words: ['Goma', 'Gol', 'Gordo', 'Gorro']),
    Letter(char: 'GU', words: ['Guitarra', 'Guante', 'Guion', 'Guerra']),
  ],
  'H':[
    Letter(char: 'HA', words: ['Hada', 'Hacha', 'Hablar', 'Hambre']),
    Letter(char: 'HE', words: ['Helado', 'Hermana', 'Herida', 'Hervir']),
    Letter(char: 'HI', words: ['Hielo', 'Higo', 'Hilo', 'Hipo']),
    Letter(char: 'HO', words: ['Hoja', 'Hormiga', 'Hombre', 'Hora']),
    Letter(char: 'HU', words: ['Humo', 'Huella', 'Hueso', 'Huevo']),
  ],
  'J':[
    Letter(char: 'JA', words: ['Jabón', 'Jarra', 'Jardín', 'Japón']),
    Letter(char: 'JE', words: ['Jefe', 'Jeringa', 'Jengibre', 'Jet']),
    Letter(char: 'JI', words: ['Jirafa', 'Jinete', 'Jilguero', 'Jibia']),
    Letter(char: 'JO', words: ['Joya', 'Joven', 'Joyero', 'Jorobado']),
    Letter(char: 'JU', words: ['Jugo', 'Juguete', 'Juez', 'Julio']),
  ],
  // Añade más letras/sílabas según necesites...
};

  // Lista de oraciones simples en español (frases cortas proporcionadas)
  const List<String> simpleSentences = [
    'Yo leo.',
    'El Bebé llora.',
    'Mamá me ama.',
    'Papá huele la flor.',
    'El sapo salta.',
    'El león come carne.',
    'La abeja vuela.',
    'El árbol verde.',
    'Mi barco azul.',
    'Veo la luna.',
    'Estoy feliz.',
    'Bebo jugo.',
    'Mira ese oso.',
    'Soplo la vela.',
    'El helado frío.',
    'Beso a mi mamá.',
    'El gato de mi mamá.',
    'El perro duerme.',
    'El pollito dice pío.',
    'Mi papá trabaja.',
    'Yo uso gafas.',
  ];

// --- Mapeo por token: cada palabra de la oración intenta asociarse a un `Word` ---

String _normalizeForMatch(String input) {
  String out = input;
  const accents = 'áéíóúÁÉÍÓÚñÑüÜ';
  const replacements = 'aeiouAEIOUnNuU';
  for (int i = 0; i < accents.length; i++) {
    out = out.replaceAll(accents[i], replacements[i]);
  }
  out = out.toLowerCase();
  out = out.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  out = out.replaceAll(RegExp(r'\s+'), ' ').trim();
  return out;
}

// Mapa de excepciones para conjugaciones irregulares: {conjugated_norm: infinitive_norm}
// Añade aquí las parejas que conoces para mejorar el mapeo (ej: 'huele' -> 'oler')
const Map<String, String> _conjugationOverrides = {
  'ama': 'amar',
  'leo': 'leer',
  'huele': 'oler',
  'huelo': 'oler',
  'huelen': 'oler',
  'bebe': 'beber',
  'bebo': 'beber',
  'beben': 'beber',
  'come': 'comer',
  'como': 'comer',
  'comen': 'comer',
  'cocina': 'cocinar',
  'cocino': 'cocinar',
  'llora': 'llorar',
  'lloro': 'llorar',
  'duerme': 'dormir',
  'duermo': 'dormir',
  'dice': 'decir',
  'digo': 'decir',
  'trabaja': 'trabajar',
  'trabajo': 'trabajar',
  'sube': 'subir',
  'subo': 'subir',
  'brilla': 'brillar',
  'brillo': 'brillar',
};

List<String> _generateInfinitiveCandidates(String normToken) {
  final candidates = <String>{};

  // override directo
  if (_conjugationOverrides.containsKey(normToken)) {
    candidates.add(_conjugationOverrides[normToken]!);
  }

  // reglas heurísticas simples
  // gerundio: -ando, -iendo -> raíz + ar/er/ir
  if (normToken.endsWith('ando')) {
    final root = normToken.substring(0, normToken.length - 4);
    candidates.add(root + 'ar');
  }
  if (normToken.endsWith('iendo')) {
    final root = normToken.substring(0, normToken.length - 5);
    candidates.add(root + 'er');
    candidates.add(root + 'ir');
  }

  // participios y formas de pasado simples: -ado, -ido
  if (normToken.endsWith('ado')) {
    final root = normToken.substring(0, normToken.length - 3);
    candidates.add(root + 'ar');
  }
  if (normToken.endsWith('ido')) {
    final root = normToken.substring(0, normToken.length - 3);
    candidates.add(root + 'er');
    candidates.add(root + 'ir');
  }

  // terminaciones de presente/pasado comunes -> intentar raíz + infinitivos
  final commonEndings = ['o', 'as', 'es', 'a', 'an', 'en', 'amos', 'emos', 'imos', 'aron', 'ieron'];
  for (final end in commonEndings) {
    if (normToken.endsWith(end) && normToken.length > end.length + 1) {
      final root = normToken.substring(0, normToken.length - end.length);
      candidates.add(root + 'ar');
      candidates.add(root + 'er');
      candidates.add(root + 'ir');
    }
  }

  // pequeñas variantes: quitar terminación 'e' y añadir 'er' (ej. 'huele'-> 'hueler')
  if (normToken.endsWith('e') && normToken.length > 2) {
    final root = normToken.substring(0, normToken.length - 1);
    candidates.add(root + 'ar');
    candidates.add(root + 'er');
    candidates.add(root + 'ir');
  }

  return candidates.toList();
}

class TokenPictogram {
  final String token; // palabra original tal como aparece en la oración
  final Word? match; // Word asociado si se encontró
  const TokenPictogram({required this.token, this.match});

  Future<File?> pictogramFile() async {
    if (match != null) return await match!.pictogramFile();
    // Fallback: buscar directamente en la API de Arasaac usando el token
    final slug = _normalizeForMatch(token);
    // Si hay una forma irregular conocida, priorizar el infinitivo
    final override = _conjugationOverrides[slug];
    if (override != null) {
      final overrideFile = await ArasaacApi.fetchPictogram(override);
      if (overrideFile != null) return overrideFile;
    }

    File? file = await ArasaacApi.fetchPictogram(slug);
    if (file != null) return file;

    // Si no se encuentra con la forma tal cual, generar candidatos de infinitivo
    // (reglas heurísticas + mapa de excepciones) y probarlos en la API.
    final candidates = _generateInfinitiveCandidates(slug);
    for (final c in candidates) {
      file = await ArasaacApi.fetchPictogram(c);
      if (file != null) return file;
    }

    // No se encontró pictograma
    return null;
  }

  @override
  String toString() => 'TokenPictogram(token: $token, match: ${match?.text})';
}

class SentencePictograms {
  final String text;
  final List<TokenPictogram> tokens;
  const SentencePictograms({required this.text, required this.tokens});

  Future<List<File?>> pictogramFiles() => Future.wait(tokens.map((t) => t.pictogramFile()).toList());

  @override
  String toString() => 'SentencePictograms(text: $text, tokens: $tokens)';
}

final List<Word> _combinedWords = [...words, ...vowelWords, ...syllableWords];

final RegExp _wordRegex = RegExp(r"[A-Za-zÁÉÍÓÚáéíóúÑñÜü]+", unicode: true);

final Set<String> _articles = {
  'el', 'la', 'los', 'las', 'un', 'una', 'unos', 'unas', 'mi', 'mis', 'tu', 'tus', 'su', 'sus', 'lo'
};

final List<SentencePictograms> sentencePictograms = simpleSentences.map((s) {
  final matches = _wordRegex.allMatches(s);
  final tokens = <TokenPictogram>[];
  for (final m in matches) {
    final tokenOriginal = m.group(0)!;
    final tokenNorm = _normalizeForMatch(tokenOriginal);
    Word? found;
    for (final w in _combinedWords) {
      if (_normalizeForMatch(w.text) == tokenNorm) {
        found = w;
        break;
      }
    }
    tokens.add(TokenPictogram(token: tokenOriginal, match: found));
  }

  // Post-proceso: fusionar artículo + sustantivo cuando el sustantivo tiene match
  final merged = <TokenPictogram>[];
  for (int i = 0; i < tokens.length; i++) {
    final t = tokens[i];
    final norm = _normalizeForMatch(t.token);
    if (_articles.contains(norm) && i + 1 < tokens.length) {
      final next = tokens[i + 1];
      if (next.match != null) {
        // Fusionar: token visual será 'artículo sustantivo', match apunta al sustantivo
        merged.add(TokenPictogram(token: '${t.token} ${next.token}', match: next.match));
        i++; // saltar el siguiente porque ya fue consumido
        continue;
      }
    }
    merged.add(t);
  }

  return SentencePictograms(text: s, tokens: merged);
}).toList();

// Prefetch: descargar (y opcionalmente cachear) todos los pictogramas de las
// oraciones. Útil para inicializar la app y evitar latencia en el primer uso.
Future<void> prefetchAllSentencePictograms({bool onlyMissing = true}) async {
  for (final sp in sentencePictograms) {
    for (final t in sp.tokens) {
      if (onlyMissing) {
        // Si tu ArasaacApi ya hace caching local, este await sólo descarga si falta.
        await t.pictogramFile();
      } else {
        await ArasaacApi.fetchPictogram(_normalizeForMatch(t.token));
      }
    }
  }
}