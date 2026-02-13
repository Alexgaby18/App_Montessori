import 'package:flutter/material.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram.dart';
import 'package:my_montessori/presentation/screens/learn/learn_letter.dart';
import 'package:my_montessori/presentation/screens/learn/easy.dart';
import 'package:my_montessori/presentation/screens/complete/complete_letter.dart';
import 'package:my_montessori/presentation/screens/complete/complete_random_letters.dart';
import 'package:my_montessori/presentation/screens/complete/complete_full_word.dart';
import 'package:my_montessori/presentation/screens/complete/complete_syllables.dart';
import 'package:my_montessori/presentation/screens/selection/selection_word.dart';
import 'package:my_montessori/presentation/screens/practice/practice_letter.dart';
import 'package:my_montessori/presentation/screens/conect/conect_letter.dart';
import 'package:my_montessori/presentation/screens/learn/hard.dart';
import 'package:my_montessori/presentation/screens/learn/learn_sentences.dart';

typedef LevelSelectedCallback = void Function(String activityId, dynamic level);

// Mapa de builders simplificado - una sola entrada por actividad
final Map<String, Widget Function(int)> _activityRouteBuilders = {
  'learn_letter': (i) => LearnLetterScreen(index: i),
  'easy': (i) => EasyLearnLetterScreen(index: i),
  'hard': (i) => HardLearnLetterScreen(index: i),
  'complete_letter': (i) => CompleteLetterScreen(index: i),
  'complete_random_letters': (i) => CompleteRandomLettersScreen(index: i),
  'complete_syllables': (i) => CompleteSyllablesScreen(index: i),
  'selection_word': (i) => SelectionWordScreen(index: i),
  'practice_letter': (i) => PracticeLetterScreen(),
  'connect_letter': (i) => ConnectLetterScreen(),
  'speak_word': (i) => LearnSentenceScreen(index: i),
  'complete_full_word': (i) => CompleteFullWordScreen(index: i),
};

class LevelSelectionScreen extends StatelessWidget {
  final String activityId;
  final String? title;
  final String? assetPath;
  final Color? appBarColor;
  final List<Map<String, dynamic>>? customLevels;
  final dynamic initialLevel;
  final LevelSelectedCallback? onLevelSelected;

  const LevelSelectionScreen({
    Key? key,
    required this.activityId,
    this.title,
    this.assetPath,
    this.appBarColor,
    this.customLevels,
    this.initialLevel,
    this.onLevelSelected,
  }) : super(key: key);

  // Configuración centralizada de actividades
  static const Map<String, Map<String, dynamic>> _activityConfig = {
    'learn_letter': {
      'title': 'Aprender letra',
      'icon': 'assets/images/pictogram_menu/learn.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'easy', // ¡Usa el mismo key que en _activityRouteBuilders!
          'asset': 'assets/images/levels/vocales.png'
        },
        {
          'label': 'Medio',
          'value': 1,
          'route': 'learn_letter',
          'asset': 'assets/images/levels/abecedario.png'
        },
        {
          'label': 'Difícil',
          'value': 1,
          'route': 'hard', // Misma actividad, diferente nivel
          'asset': 'assets/images/levels/silaba.png'
        },
        {
          'label': 'Experto',
          'value': 1,
          'route': 'speak_word', // Misma actividad, diferente nivel
          'asset': 'assets/images/levels/frase.png'
        },
      ],
    },
    'complete_letter': {
      'title': 'Completar letra',
      'icon': 'assets/images/pictogram_menu/complete.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'complete_letter',
          'asset': 'assets/images/levels/vocales.png'
        },
        {
          'label': 'Medio',
          'value': 1,
          'route': 'complete_letter_random', 
          'asset': 'assets/images/levels/nombre.png'
        },
        {
          'label': 'Difícil',
          'value': 1,
          'route': 'complete_syllables',
          'asset': 'assets/images/levels/silaba.png'
        },
        {
          'label': 'Experto',
          'value': 1,
          'route': 'complete_full_word',
          'asset': 'assets/images/levels/frase.png'
        },
      ],
    },
    'connect_letter': {
      'title': 'Conectar letras',
      'icon': 'assets/images/pictogram_menu/connect.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'connect_letter',
          'asset': 'assets/images/levels/asociar.png'
        },
        {
          'label': 'Medio',
          'value': 2,
          'route': 'connect_letter',
          'asset': 'assets/images/levels/abecedario.png'
        },
        {
          'label': 'Difícil',
          'value': 3,
          'route': 'connect_letter',
          'asset': 'assets/images/levels/silaba.png'
        },
        {
          'label': 'Experto',
          'value': 4,
          'route': 'connect_letter',
          'asset': 'assets/images/levels/palabra.png'
        },
      ],
    },
    'select_word': {
      'title': 'Seleccionar palabra',
      'icon': 'assets/images/pictogram_menu/select.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'selection_word',
          'asset': 'assets/images/levels/vocales.png'
        },
        {
          'label': 'Medio',
          'value': 2,
          'route': 'selection_word',
          'asset': 'assets/images/levels/palabra.png'
        },
        {
          'label': 'Difícil',
          'value': 3,
          'route': 'selection_word',
          'asset': 'assets/images/levels/abecedario.png'
        },
        {
          'label': 'Experto',
          'value': 4,
          'route': 'selection_word',
          'asset': 'assets/images/levels/contar.png'
        },
      ],
    },
    'practice_letter': {
      'title': 'Practicar letra',
      'icon': 'assets/images/pictogram_menu/practice.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'practice_letter',
          'asset': 'assets/images/levels/vocales.png'
        },
        {
          'label': 'Medio',
          'value': 2,
          'route': 'practice_letter',
          'asset': 'assets/images/levels/abecedario.png'
        },
        {
          'label': 'Difícil',
          'value': 3,
          'route': 'practice_letter',
          'asset': 'assets/images/levels/palabra.png'
        },
        {
          'label': 'Experto',
          'value': 4,
          'route': 'practice_letter',
          'asset': 'assets/images/levels/copiar.png'
        },
      ],
    },
    'speak_word': {
      'title': 'Pronunciar palabra',
      'icon': 'assets/images/pictogram_menu/speak.png',
      'levels': [
        {
          'label': 'Fácil',
          'value': 1,
          'route': 'speak_word',
          'asset': 'assets/images/levels/abecedario.png'
        },
        {
          'label': 'Medio',
          'value': 2,
          'route': 'speak_word',
          'asset': 'assets/images/levels/silaba.png'
        },
        {
          'label': 'Difícil',
          'value': 3,
          'route': 'speak_word',
          'asset': 'assets/images/levels/palabra.png'
        },
        {
          'label': 'Experto',
          'value': 4,
          'route': 'speak_word',
          'asset': 'assets/images/levels/frase.png'
        },
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    final config = _activityConfig[activityId] ?? {};
    final displayTitle = title ?? config['title'] ?? activityId;
    final displayAsset = assetPath ?? (config['icon'] as String?);
    final levelList = customLevels ?? (config['levels'] as List<Map<String, dynamic>>? ?? []);
    final displayAppBarColor = appBarColor ?? const Color.fromARGB(255, 68, 194, 193);

    return Scaffold(
      appBar: AppBar(
        title: Text(displayTitle),
        backgroundColor: displayAppBarColor,
      ),
      body: Stack(
        children: [
          BackgroundAnimation(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (displayAsset != null)
                  Center(
                    child: SizedBox(
                      width: 140.0,
                      height: 140.0,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: ButtonPictogram(
                          assetPath: displayAsset,
                          size: 140.0,
                          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 24),
                const SizedBox(height: 64),
                Expanded(
                  child: levelList.isEmpty
                      ? _buildNoLevelsAvailable()
                      : GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children: levelList.map((level) {
                            return _buildLevelCard(context, level);
                          }).toList(),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, Map<String, dynamic> level) {
    final label = level['label']?.toString() ?? level['value'].toString();
    final value = level['value'];
    final asset = level['asset'] as String?;
    final route = level['route'] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () => _onLevelSelected(context, level),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ButtonPictogram(
              assetPath: asset ?? '',
              size: 120.0,
              backgroundColor: Colors.white,
              onPressed: () => _onLevelSelected(context, level),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNoLevelsAvailable() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No hay niveles disponibles',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _onLevelSelected(BuildContext context, Map<String, dynamic> level) {
    final value = level['value'];
    final route = level['route'] as String?;

    // Si hay callback externo, lo usamos
    if (onLevelSelected != null) {
      onLevelSelected!(activityId, value);
      return;
    }

    // Si no hay callback, navegamos a la actividad
    if (route != null && _activityRouteBuilders.containsKey(route)) {
      _navigateToActivity(context, route, value);
    } else {
      // Si no hay ruta definida o no está en builders, cerramos con datos
      Navigator.of(context).pop({
        'activityId': activityId,
        'level': value,
        'levelData': level,
      });
    }
  }

  void _navigateToActivity(BuildContext context, String route, dynamic level) {
    final builder = _activityRouteBuilders[route];
    
    if (builder == null) {
      // Si no hay builder, no navegamos
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Actividad "$route" no disponible'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convertir nivel a índice (1-based a 0-based)
    final index = _levelToIndex(level);
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => builder(index),
        settings: RouteSettings(
          arguments: {
            'level': level,
            'activityId': activityId,
          },
        ),
      ),
    );
  }

  int _levelToIndex(dynamic level) {
    if (level is int) {
      return level - 1; // Convertir de 1-based a 0-based
    }
    if (level is String) {
      final parsed = int.tryParse(level);
      return parsed != null ? parsed - 1 : 0;
    }
    return 0;
  }
}