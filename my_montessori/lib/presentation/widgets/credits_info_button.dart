import 'package:flutter/material.dart';

class CreditsInfoButton extends StatelessWidget {
  final String assetPath;

  const CreditsInfoButton({
    super.key,
    this.assetPath = 'assets/images/pictogram_menu/informacion_1.png',
  });
  
  static const Color _cTurquoise = Color.fromARGB(255, 68, 194, 193);
  static const Color _cBlue = Color.fromARGB(255, 66, 170, 223);
  static const Color _cOrange = Color.fromARGB(255, 245, 163, 35);
  static const Color _cPink = Color.fromARGB(255, 234, 155, 184);
  static const Color _cPurple = Color.fromARGB(255, 174, 128, 227);
  static const Color _cRed = Color.fromARGB(255, 215, 68, 57);
  static const Color _cBrownText = Color.fromARGB(255, 55, 35, 28);

  String _creditsText() {
    final year = DateTime.now().year;
    return '© $year App Montessori. Todos los derechos reservados sobre el software, diseño y contenidos propios de la aplicación.';
  }

  void _showCredits(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 460),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 250, 252, 255),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
                decoration: const BoxDecoration(
                  color: _cBlue,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(4),
                      // decoration: BoxDecoration(
                      //   color: Colors.white.withOpacity(0.9),
                      //   shape: BoxShape.circle,
                      // ),
                      child: ClipOval(
                        child: Image.asset(
                          assetPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Créditos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'App Montessori',
                        style: TextStyle(
                          color: _cBrownText,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Versión educativa para apoyo al aprendizaje infantil.',
                        style: TextStyle(
                          color: _cBrownText.withOpacity(0.86),
                          fontSize: 15,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SectionCard(
                        title: 'Desarrollo',
                        color: _cPurple,
                        text: 'Autor: Alex Contreras.\nTutor Academico: MSc. Braumalis Malave.\n\n'
                            'La aplicación ha sido desarrollada con el objetivo de proporcionar una herramienta educativa que apoye el aprendizaje infantil, siguiendo los principios pedagógicos de Montessori.',
                      ),
                      const SizedBox(height: 10),
                      _SectionCard(
                        title: 'Derechos de autor de la app',
                        color: _cOrange,
                        text: _creditsText(),
                      ),
                      const SizedBox(height: 10),
                      const _SectionCard(
                        title: 'Pictogramas',
                        color: _cPink,
                        text:
                            'Los pictogramas utilizados han sido obtenidos de ARASAAC (Centro Aragonés para la Comunicación Aumentativa y Alternativa, Gobierno de Aragón).\n\n'
                            'ARASAAC distribuye sus pictogramas bajo licencia Creative Commons BY-NC-SA; su uso en esta app se realiza con la atribución correspondiente.',
                      ),
                      const SizedBox(height: 14),
                      Center(
                        child: Wrap(
                          spacing: 8,
                          children: const [
                            _ColorDot(color: _cTurquoise),
                            _ColorDot(color: _cBlue),
                            _ColorDot(color: _cOrange),
                            _ColorDot(color: _cPink),
                            _ColorDot(color: _cPurple),
                            _ColorDot(color: _cRed),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _cRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCredits(context),
      child: Container(
        width: 46,
        height: 46,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String text;
  final Color color;

  const _SectionCard({
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.45), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: const TextStyle(
              color: Color.fromARGB(255, 55, 35, 28),
              fontSize: 13.8,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}