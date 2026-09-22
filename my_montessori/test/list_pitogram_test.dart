import 'package:flutter_test/flutter_test.dart';
import 'package:my_montessori/core/constans/list_pitogram.dart';

void main() {
  test('fusiona artículos y frases con preposiciones en las oraciones', () {
    final elNino = sentencePictograms.firstWhere((s) => s.text == 'El niño salta.');
    final mergedElNino = elNino.tokens.firstWhere((t) => t.token == 'El niño');
    expect(mergedElNino.searchKey, 'niño');

    final laNina = sentencePictograms.firstWhere((s) => s.text == 'La niña está triste.');
    final mergedLaNina = laNina.tokens.firstWhere((t) => t.token == 'La niña');
    expect(mergedLaNina.searchKey, 'niña');

    final alArbol = sentencePictograms.firstWhere((s) => s.text == 'El gato sube al árbol.');
    final mergedAlArbol = alArbol.tokens.firstWhere((t) => t.token == 'al árbol');
    expect((mergedAlArbol.searchKey ?? '').toLowerCase(), 'árbol');

    final deLaPanaderia = sentencePictograms.firstWhere((s) => s.text == 'Papá sale de la panadería.');
    expect(deLaPanaderia.tokens.any((t) => t.token == 'de la'), isTrue);
    expect(deLaPanaderia.tokens.any((t) => t.token == 'panadería'), isTrue);
  });

  test('genera candidatos de infinitivo para verbos frecuentes de las frases', () {
    expect(resolveInfinitiveCandidates('juegan'), contains('jugar'));
    expect(resolveInfinitiveCandidates('estan'), contains('estar'));
    expect(resolveInfinitiveCandidates('huele'), contains('oler'));
  });
}
