// ...existing code...
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class _CloudConfig {
  final String asset;
  final double top;
  final double left;
  final double width;
  final double opacity;
  const _CloudConfig(this.asset, this.top, this.left, this.width, this.opacity);
}

const List<_CloudConfig> _cloudsStatic = [
  _CloudConfig('assets/svg/cloud1.svg', 300.0, 0.0, 220.0, 0.9),
  _CloudConfig('assets/svg/cloud2.svg', 600.0, 160.0, 300.0, 0.85),
  _CloudConfig('assets/svg/cloud3.svg', 480.0, 90.0, 180.0, 0.95),
  _CloudConfig('assets/svg/cloud4.svg', 100.0, 250.0, 160.0, 0.8),
];

class BackgroundAnimation extends StatelessWidget {
  // ignore: use_super_parameters
  const BackgroundAnimation({Key? key}) : super(key: key);

  Widget _svg(String asset, double width) {
    return SvgPicture.asset(
      asset,
      width: width,
      fit: BoxFit.contain,
      // placeholder para evitar errores visibles mientras carga
      placeholderBuilder: (context) => SizedBox(width: width, height: width * 0.6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Stack(children: [
        // fondo plano (azul cielo)
        Container(color: const Color.fromARGB(255, 174, 220, 235)),

        // sol en posición fija
        Positioned(
          left: 20,
          top: 20,
          child: _svg('assets/svg/sun.svg', 100),
        ),

        // nubes estáticas en las posiciones definidas
        ..._cloudsStatic.map((cfg) {
          return Positioned(
            left: cfg.left,
            top: cfg.top,
            child: Opacity(
              opacity: cfg.opacity,
              child: _svg(cfg.asset, cfg.width),
            ),
          );
        }),
      ]);
    });
  }
}
// ...existing code...