import 'dart:developer' as console;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:my_montessori/core/theme/animatic_background.dart';
import 'package:my_montessori/presentation/widgets/button_pictogram.dart';
import 'package:my_montessori/presentation/screens/level_selection.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // threshold ajustable
    final logoSize = isTablet ? 220.0 : 140.0;

    return Scaffold(
        body: Stack(
          children: [
            BackgroundAnimation(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Logo en la parte superior centrado
                  Container(
                    margin: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                    child: SvgPicture.asset(
                      'assets/svg/Logo.svg', // Ajusta la ruta según tu logo
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  // Grid de botones organizados en 2 columnas (tamaño responsivo)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        final isTablet = screenWidth > 600; // threshold ajustable
                        final horizontalPadding = isTablet ? 100.0 : 40.0;
                        final spacing = isTablet ? 80.0 : 40.0;
                        final columns = 2;
                        final buttonSize = isTablet ? 220.0 : 120.0;

                        return GridView.count(
                          crossAxisCount: columns,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                          padding: EdgeInsets.all(horizontalPadding),
                          childAspectRatio: 1.0,
                          children: [
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/aprender.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 68, 194, 193),
                              onPressed: () {
                                console.log('Aprender Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'learn_letter',
                                      assetPath: 'assets/images/pictogram_menu/aprender.png',
                                      appBarColor: Color.fromARGB(255, 68, 194, 193),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/completar.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 66, 170, 223),
                              onPressed: () {
                                console.log('Completar Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'complete_letter',
                                      assetPath: 'assets/images/pictogram_menu/completar.png',
                                      appBarColor: Color.fromARGB(255, 66, 170, 223),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/unir.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 245, 163, 35),
                              onPressed: () {
                                console.log('Unir Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'connect_letter',
                                      assetPath: 'assets/images/pictogram_menu/unir.png',
                                      appBarColor: Color.fromARGB(255, 245, 163, 35),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/seleccionar.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 234, 155, 184),
                              onPressed: () {
                                console.log('Seleccionar Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'select_word',
                                      assetPath: 'assets/images/pictogram_menu/seleccionar.png',
                                      appBarColor: Color.fromARGB(255, 234, 155, 184),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/escribir.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 174, 128, 227),
                              onPressed: () {
                                console.log('Escribir Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'practice_letter',
                                      assetPath: 'assets/images/pictogram_menu/escribir.png',
                                      appBarColor: Color.fromARGB(255, 174, 128, 227),
                                    ),
                                  ),
                                );
                              },
                            ),
                            ButtonPictogram(
                              assetPath: 'assets/images/pictogram_menu/leer.png',
                              size: buttonSize,
                              backgroundColor: const Color.fromARGB(255, 215, 68, 57),
                              onPressed: () {
                                console.log('Leer Pressed');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LevelSelectionScreen(
                                      activityId: 'speak_word',
                                      assetPath: 'assets/images/pictogram_menu/leer.png',
                                      appBarColor: Color.fromARGB(255, 215, 68, 57),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}